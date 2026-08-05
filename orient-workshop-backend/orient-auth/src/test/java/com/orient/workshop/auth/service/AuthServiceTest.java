package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.dto.TokenResponse;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.core.repository.BranchMapper;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.StaffMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserMapper userMapper;
    @Mock private OtpService otpService;
    @Mock private JwtService jwtService;
    @Mock private PasswordService passwordService;
    @Mock private StaffMapper staffMapper;
    @Mock private CustomerMapper customerMapper;
    @Mock private BranchMapper branchMapper;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(userMapper, otpService, jwtService, passwordService,
                staffMapper, customerMapper, branchMapper);
    }

    @Test
    void sendOtp_sms_shouldNormalizePhone() {
        authService.sendOtp("sms", "0501234567", null);
        verify(otpService).sendSmsOtp("971501234567");
    }

    @Test
    void sendOtp_email_shouldCallEmailOtp() {
        authService.sendOtp("email", null, "test@test.com");
        verify(otpService).sendEmailOtp("test@test.com");
    }

    @Test
    void verifyOtp_sms_shouldCreateUser() {
        doNothing().when(otpService).verifySmsOtp(anyString(), anyString());
        when(userMapper.findByPhone(anyString())).thenReturn(Optional.empty());
        when(jwtService.createTokenPair(any(User.class))).thenReturn(
                TokenResponse.builder().role("customer").token("tok").refreshToken("ref").build());

        TokenResponse result = authService.verifyOtp("sms", "971501234567", null, "123456");

        assertNotNull(result);
        assertEquals("customer", result.getRole());
    }

    @Test
    void verifyOtp_email_shouldCreateUser() {
        doNothing().when(otpService).verifyEmailOtp(anyString(), anyString());
        when(userMapper.findByEmail(anyString())).thenReturn(Optional.empty());
        when(jwtService.createTokenPair(any(User.class))).thenReturn(
                TokenResponse.builder().role("customer").token("tok").refreshToken("ref").build());

        TokenResponse result = authService.verifyOtp("email", null, "a@b.com", "123456");

        assertNotNull(result);
        assertEquals("customer", result.getRole());
    }

    @Test
    void register_shouldHashPassword() {
        when(userMapper.findByEmail(anyString())).thenReturn(Optional.empty());
        when(passwordService.hash("mypass")).thenReturn("hashed_pass");
        when(jwtService.createTokenPair(any(User.class))).thenReturn(
                TokenResponse.builder().role("customer").token("tok").refreshToken("ref").build());

        authService.register("Ahmed", "a@b.com", null, "mypass", null);

        verify(passwordService).hash("mypass");
    }
}
