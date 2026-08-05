package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
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

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingMapper bookingMapper;
    private final CustomerService customerService;
    private final NotificationService notificationService;

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

        return IdResponse.builder().id(ref).build();
    }

    private BookingResponse toResponse(Booking b) {
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("d MMM yyyy");
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
        return BookingResponse.builder()
                .service(b.getServiceType())
                .vehicleName(b.getVehicleName())
                .plateNumber(b.getPlateNumber())
                .date(b.getBookingDate() != null ? b.getBookingDate().format(dateFmt) : "")
                .time(b.getBookingDate() != null ? b.getBookingDate().format(timeFmt) : "")
                .status(b.getStatus())
                .build();
    }
}
