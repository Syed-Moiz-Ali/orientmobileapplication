package com.orient.workshop.auth.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.auth.model.dto.*;
import com.orient.workshop.auth.service.AuthService;
import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Authentication")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Unified session/profile endpoint: validates the JWT (Authorization header)
     * and returns the caller identity, role and role-specific record. Clients
     * call this on splash to decide dashboard vs login.
     */
    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<MeResponse> me(@AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(authService.getMe(principal));
    }


    @PostMapping("/send-otp")
    public ApiResponse<Void> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        authService.sendOtp(request.getType(), request.getPhone(), request.getEmail());
        return ApiResponse.success("OTP sent", null);
    }

    @PostMapping("/verify-otp")
    public ApiResponse<TokenResponse> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        TokenResponse response = authService.verifyOtp(
                request.getType(), request.getPhone(), request.getEmail(), request.getOtp());
        return ApiResponse.success(response);
    }

    @PostMapping("/register")
    public ApiResponse<TokenResponse> register(@Valid @RequestBody RegisterRequest request) {
        TokenResponse response = authService.register(
                request.getName(), request.getEmail(), request.getPhone(),
                request.getPassword(), request.getRole());
        return ApiResponse.success("Registration successful", response);
    }

    @PostMapping("/login")
    public ApiResponse<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        TokenResponse response = authService.loginWithPassword(
                request.getEmail(), request.getPhone(), request.getPassword());
        return ApiResponse.success(response);
    }

    @PostMapping("/refresh")
    public ApiResponse<TokenResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse response = authService.refreshToken(request.getRefreshToken());
        return ApiResponse.success(response);
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<Void> logout(@RequestBody(required = false) RefreshTokenRequest request) {
        if (request != null) {
            authService.logout(request.getRefreshToken());
        }
        return ApiResponse.success(null);
    }

    @PostMapping("/forgot-password")
    public ApiResponse<Void> forgotPassword(@Valid @RequestBody SendOtpRequest request) {
        authService.sendOtp(request.getType(), request.getPhone(), request.getEmail());
        return ApiResponse.success("OTP sent", null);
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request.getType(), request.getPhone(), request.getEmail(),
                request.getOtp(), request.getNewPassword());
        return ApiResponse.success("Password reset successfully", null);
    }
}

