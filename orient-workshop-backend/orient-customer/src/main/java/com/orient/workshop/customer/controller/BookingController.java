package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;
import com.orient.workshop.customer.model.dto.BookingAvailabilityResponse;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.customer.model.dto.BookingResponse;
import com.orient.workshop.customer.model.dto.CreateBookingRequest;
import com.orient.workshop.customer.model.dto.IdResponse;
import com.orient.workshop.customer.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Customer Portal")
@RestController
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @GetMapping("/customers/bookings")
    public ApiResponse<List<BookingResponse>> getBookings(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                           @RequestParam(defaultValue = "1") int page,
                                                           @RequestParam(defaultValue = "20") int size) {
        List<BookingResponse> bookings = bookingService.getBookings(principal);
        return ApiResponse.success(bookings);
    }

    @PostMapping("/bookings")
    public ApiResponse<IdResponse> createBooking(@AuthenticationPrincipal JwtUserPrincipal principal,
                                                   @Valid @RequestBody CreateBookingRequest request) {
        IdResponse response = bookingService.createBooking(principal, request);
        return ApiResponse.success(response);
    }

    @GetMapping("/bookings/availability")
    public ApiResponse<BookingAvailabilityResponse> getAvailability(
            @RequestParam String date,
            @RequestParam(required = false) String serviceType,
            @RequestParam(required = false) Long branchId) {
        return ApiResponse.success(bookingService.getAvailability(date, serviceType, branchId));
    }

    @PutMapping("/customers/bookings/{bookingId}/status")
    public ApiResponse<BookingResponse> updateBookingStatus(
            @PathVariable Long bookingId,
            @RequestBody(required = false) java.util.Map<String, String> body,
            @RequestParam(required = false) String status,
            @AuthenticationPrincipal JwtUserPrincipal principal) {
        // FIX (audit QA BUG-010): the customer app sends ?status=cancelled as a
        // query param with no body; the Postman collection and older clients use
        // {"status": ...}. Accept both so the cancel flow works end-to-end.
        String resolved = (body != null && body.get("status") != null && !body.get("status").isBlank())
                ? body.get("status")
                : status;
        return ApiResponse.success(bookingService.updateStatus(bookingId, resolved, principal));
    }
}

