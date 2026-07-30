package com.orient.workshop.customer.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


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
}

