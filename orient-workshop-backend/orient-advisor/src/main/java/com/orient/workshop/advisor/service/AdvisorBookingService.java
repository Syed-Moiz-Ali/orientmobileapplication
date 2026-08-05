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
}
