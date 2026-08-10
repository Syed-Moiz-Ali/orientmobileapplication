package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.customer.model.dto.BookingAvailabilityResponse;
import com.orient.workshop.customer.model.dto.BookingResponse;
import com.orient.workshop.customer.model.dto.CreateBookingRequest;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingMapper bookingMapper;
    private final CustomerService customerService;
    private final NotificationService notificationService;
    private final com.orient.workshop.core.service.ActivityService activityService;
    private final com.orient.workshop.core.service.WebhookService webhookService;

    // P3: per-workshop capacity is configurable (was hardcoded 8).
    @org.springframework.beans.factory.annotation.Value("${app.booking.workshop-capacity:8}")
    private int workshopCapacity;

    public List<BookingResponse> getBookings(JwtUserPrincipal principal) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());
        List<Booking> bookings = principal.getBranchId() != null
                ? bookingMapper.findByCustomerIdAndBranch(customer.getId(), principal.getBranchId())
                : bookingMapper.findByCustomerId(customer.getId());
        return bookings.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public IdResponse createBooking(JwtUserPrincipal principal, CreateBookingRequest req) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());

        String ref = IdGenerator.shortRef("BK");

        LocalDateTime bookingDate = req.getBookingDate() != null
                ? DateParse.parseLocalDateTime(req.getBookingDate(), "bookingDate")
                : LocalDateTime.now();

        Booking booking = Booking.builder()
                .bookingRef(ref)
                .customerId(customer.getId())
                .branchId(principal.getBranchId())
                .vehicleId(req.getVehicleId() != null ? Long.parseLong(req.getVehicleId()) : null)
                .vehicleName(req.getVehicleName())
                .plateNumber(req.getPlateNumber())
                .serviceType(req.getServiceType())
                .bookingDate(bookingDate)
                .notes(req.getNotes())
                .status("pending")
                .build();
        bookingMapper.insert(booking);

        notificationService.emit(principal.getUserId(), principal.getBranchId(),
                "bookingReceived", "Booking received",
                "Your booking " + ref + " for " + req.getServiceType()
                        + " has been received. We'll confirm shortly.");

        // P1: activity feed writer (was empty — nothing ever logged).
        activityService.log("job_card", "Booking received",
                "Booking " + ref + " for " + req.getServiceType()
                        + (req.getPlateNumber() != null && !req.getPlateNumber().isBlank()
                        ? " (" + req.getPlateNumber() + ")" : ""),
                principal != null ? principal.getUserId() : null);

        // P3: outbound webhook (booking.created).
        webhookService.dispatch("booking.created", Map.of(
                "bookingRef", ref,
                "serviceType", req.getServiceType(),
                "plateNumber", req.getPlateNumber() != null ? req.getPlateNumber() : "",
                "bookingDate", bookingDate != null ? bookingDate.toString() : ""));

        return IdResponse.builder().id(String.valueOf(booking.getId())).bookingRef(ref).build();
    }

    public BookingAvailabilityResponse getAvailability(String dateStr, String serviceType, Long branchId) {
        LocalDate date = LocalDate.parse(dateStr);
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);

        // P3 (audit): availability was branch-blind — multi-branch workshops
        // double-booked bays across branches. Filter by the requested branch.
        List<Booking> bookings;
        if (branchId != null && branchId > 0) {
            bookings = bookingMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Booking>()
                            .eq("branch_id", branchId)
                            .between("booking_date", startOfDay, endOfDay)
                            .ne("status", "cancelled")
            );
        } else {
            bookings = bookingMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Booking>()
                            .between("booking_date", startOfDay, endOfDay)
                            .ne("status", "cancelled")
            );
        }

        List<String> bookedSlots = new ArrayList<>();
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
        for (Booking b : bookings) {
            if (b.getBookingDate() != null) {
                bookedSlots.add(b.getBookingDate().format(timeFmt));
            }
        }

        List<String> allSlots = new ArrayList<>();
        for (int h = 9; h <= 17; h++) {
            allSlots.add(String.format("%02d:00", h));
        }

        List<String> availableSlots = new ArrayList<>(allSlots);
        availableSlots.removeAll(bookedSlots);

        return BookingAvailabilityResponse.builder()
                .date(dateStr)
                .serviceType(serviceType)
                .availableSlots(availableSlots)
                .bookedSlots(bookedSlots)
                .workshopCapacity(workshopCapacity)
                .bookedCount(bookings.size())
                .build();
    }

    @Transactional
    public BookingResponse updateStatus(Long bookingId, String status, JwtUserPrincipal principal) {
        Booking booking = bookingMapper.selectById(bookingId);
        if (booking == null) {
            throw new com.orient.workshop.common.exception.NotFoundException("Booking not found");
        }

        // S-4: IDOR fix — only the booking's owner (resolved customer) may change
        // its status. Previously any authenticated user could mutate any booking.
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());
        if (booking.getCustomerId() == null || !customer.getId().equals(booking.getCustomerId())) {
            throw new com.orient.workshop.common.exception.ForbiddenException("Booking does not belong to this customer");
        }

        List<String> validStatuses = List.of("confirmed", "vehicle_received", "in_service", "completed", "cancelled");
        if (!validStatuses.contains(status)) {
            throw new com.orient.workshop.common.exception.BadRequestException("Invalid status: " + status);
        }

        booking.setStatus(status);
        bookingMapper.updateById(booking);
        return toResponse(booking);
    }

    private BookingResponse toResponse(Booking b) {
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("d MMM yyyy");
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
        return BookingResponse.builder()
                .id(b.getId())
                .bookingRef(b.getBookingRef())
                .service(b.getServiceType())
                .vehicleName(b.getVehicleName())
                .plateNumber(b.getPlateNumber())
                .date(b.getBookingDate() != null ? b.getBookingDate().format(dateFmt) : "")
                .time(b.getBookingDate() != null ? b.getBookingDate().format(timeFmt) : "")
                .status(b.getStatus())
                .build();
    }
}
