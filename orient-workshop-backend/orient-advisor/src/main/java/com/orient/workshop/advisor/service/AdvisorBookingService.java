package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.AdvisorBookingResponse;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.advisor.model.dto.CheckInRequest;
import com.orient.workshop.advisor.model.dto.CheckInResponse;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdvisorBookingService {

    private static final DateTimeFormatter DATE_TIME_FMT =
            DateTimeFormatter.ofPattern("d MMM yyyy · hh:mm a");

    private final BookingMapper bookingMapper;
    private final CustomerMapper customerMapper;
    private final StaffMapper staffMapper;
    private final JobCardMapper jobCardMapper;

    public List<AdvisorBookingResponse> getAssignedBookings(JwtUserPrincipal principal) {
        Staff me = resolveAdvisor(principal);
        List<Booking> bookings = bookingMapper.findOpenByAdvisorId(me.getId());
        if (bookings.isEmpty()) return List.of();

        Map<Long, Customer> customers = customerMapper.selectBatchIds(
                        bookings.stream().map(Booking::getCustomerId).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(Customer::getId, Function.identity()));

        return bookings.stream().map(b -> {
            Customer c = customers.get(b.getCustomerId());
            return AdvisorBookingResponse.builder()
                    .id(b.getId())
                    .bookingRef(b.getBookingRef())
                    .customerName(c != null ? c.getCustomerName() : "")
                    .phone(c != null ? c.getPhoneNumber() : "")
                    .vehicleName(b.getVehicleName() != null ? b.getVehicleName() : "")
                    .plateNumber(b.getPlateNumber() != null ? b.getPlateNumber() : "")
                    .serviceType(b.getServiceType() != null ? b.getServiceType() : "")
                    .bookingDate(b.getBookingDate() != null ? b.getBookingDate().format(DATE_TIME_FMT) : "")
                    .notes(b.getNotes())
                    .status(b.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    private Staff resolveAdvisor(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return staffMapper.findByUserId(principal.getUserId())
                .orElseThrow(() -> new ForbiddenException("No staff record linked to the authenticated user"));
    }

    @Transactional
    public CheckInResponse checkIn(Long bookingId, CheckInRequest request, JwtUserPrincipal principal) {
        Booking booking = bookingMapper.selectById(bookingId);
        if (booking == null) {
            throw new NotFoundException("Booking not found");
        }

        // Fix: only the booking's assigned advisor may check it in.
        Staff me = resolveAdvisor(principal);
        if (booking.getAdvisorId() != null && !booking.getAdvisorId().equals(me.getId())) {
            throw new ForbiddenException("Booking is assigned to another advisor");
        }

        // Fix: job_card_ref is NOT NULL UNIQUE — generate it BEFORE insert
        // (previously the insert failed on every check-in).
        String ref = IdGenerator.shortRef("JC");
        JobCard jobCard = JobCard.builder()
                .jobCardRef(ref)
                .customerId(booking.getCustomerId())
                .vehicleId(booking.getVehicleId())
                .branchId(booking.getBranchId())
                .status("vehicleReceived")
                .tag(booking.getServiceType())
                .notes(request.getNotes())
                .createdDate(LocalDateTime.now())
                .build();

        jobCardMapper.insert(jobCard);

        booking.setStatus("vehicle_received");
        booking.setJobCardId(jobCard.getId());
        bookingMapper.updateById(booking);

        return CheckInResponse.builder()
                .jobCardId(jobCard.getId())
                .jobCardRef(jobCard.getJobCardRef())
                .status(jobCard.getStatus())
                .build();
    }
}
