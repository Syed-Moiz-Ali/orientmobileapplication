package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.dto.TokenResponse;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.util.PhoneUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final OtpService otpService;
    private final JwtService jwtService;
    private final PasswordService passwordService;

    // ========== OTP (unified sms + email) ==========

    public void sendOtp(String type, String phone, String email) {
        switch (type) {
            case "sms" -> {
                if (phone == null || phone.isBlank())
                    throw new BadRequestException("Phone is required for sms OTP");
                otpService.sendSmsOtp(PhoneUtil.normalize(phone));
            }
            case "email" -> {
                if (email == null || email.isBlank())
                    throw new BadRequestException("Email is required for email OTP");
                otpService.sendEmailOtp(email.trim().toLowerCase());
            }
            default -> throw new BadRequestException("Invalid OTP type. Use 'sms' or 'email'");
        }
    }

    @Transactional
    public TokenResponse verifyOtp(String type, String phone, String email, String otpCode) {
        User user = switch (type) {
            case "sms" -> {
                if (phone == null || phone.isBlank())
                    throw new BadRequestException("Phone is required for sms OTP");
                String normalizedPhone = PhoneUtil.normalize(phone);
                otpService.verifySmsOtp(normalizedPhone, otpCode);
                yield findOrCreateUserByPhone(normalizedPhone);
            }
            case "email" -> {
                if (email == null || email.isBlank())
                    throw new BadRequestException("Email is required for email OTP");
                String normalizedEmail = email.trim().toLowerCase();
                otpService.verifyEmailOtp(normalizedEmail, otpCode);
                yield findOrCreateUserByEmail(normalizedEmail);
            }
            default -> throw new BadRequestException("Invalid OTP type. Use 'sms' or 'email'");
        };
        return jwtService.createTokenPair(user);
    }

    // ========== PASSWORD ==========

    @Transactional
    public TokenResponse register(String name, String email, String phone, String rawPassword, String role) {
        if (email != null && !email.isBlank() && userMapper.findByEmail(email.trim().toLowerCase()).isPresent()) {
            throw new BadRequestException("Email already registered");
        }
        String normalizedPhone = (phone != null && !phone.isBlank()) ? PhoneUtil.normalize(phone) : null;
        if (normalizedPhone != null && userMapper.findByPhone(normalizedPhone).isPresent()) {
            throw new BadRequestException("Phone already registered");
        }

        String resolvedRole = (role != null && !role.isBlank()) ? role : "customer";

        User user = User.builder()
                .name(name)
                .email(email != null ? email.trim().toLowerCase() : null)
                .phone(normalizedPhone)
                .passwordHash(passwordService.hash(rawPassword))
                .role(resolvedRole)
                .build();
        userMapper.insert(user);

        return jwtService.createTokenPair(user);
    }

    @Transactional
    public TokenResponse loginWithPassword(String email, String phone, String rawPassword) {
        User user;

        if (email != null && !email.isBlank()) {
            user = userMapper.findByEmail(email.trim().toLowerCase())
                    .orElseThrow(() -> new BadRequestException("Invalid email/phone or password"));
        } else if (phone != null && !phone.isBlank()) {
            user = userMapper.findByPhone(PhoneUtil.normalize(phone))
                    .orElseThrow(() -> new BadRequestException("Invalid email/phone or password"));
        } else {
            throw new BadRequestException("Email or phone is required");
        }

        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            throw new BadRequestException("This account uses OTP login. Please use OTP instead.");
        }

        passwordService.validate(rawPassword, user.getPasswordHash());
        return jwtService.createTokenPair(user);
    }

    // ========== FORGOT / RESET PASSWORD ==========

    @Transactional
    public void resetPassword(String type, String phone, String email, String otp, String newPassword) {
        User user;
        switch (type) {
            case "sms" -> {
                if (phone == null || phone.isBlank())
                    throw new BadRequestException("Phone is required for sms");
                String normalizedPhone = PhoneUtil.normalize(phone);
                otpService.verifySmsOtp(normalizedPhone, otp);
                user = userMapper.findByPhone(normalizedPhone)
                        .orElseThrow(() -> new BadRequestException("User not found with phone: " + normalizedPhone));
            }
            case "email" -> {
                if (email == null || email.isBlank())
                    throw new BadRequestException("Email is required for email");
                String normalizedEmail = email.trim().toLowerCase();
                otpService.verifyEmailOtp(normalizedEmail, otp);
                user = userMapper.findByEmail(normalizedEmail)
                        .orElseThrow(() -> new BadRequestException("User not found with email: " + normalizedEmail));
            }
            default -> throw new BadRequestException("Invalid type. Use 'sms' or 'email'");
        }
        user.setPasswordHash(passwordService.hash(newPassword));
        userMapper.updateById(user);
        jwtService.revokeAllUserTokens(user.getId());
    }

    // ========== SHARED ==========

    public TokenResponse refreshToken(String refreshToken) {
        return jwtService.refreshAccessToken(refreshToken);
    }

    public void logout(String refreshToken) {
        jwtService.revokeRefreshToken(refreshToken);
    }

    private User findOrCreateUserByPhone(String phone) {
        return userMapper.findByPhone(phone)
                .orElseGet(() -> {
                    User newUser = User.builder()
                            .phone(phone)
                            .name("")
                            .role(resolveDefaultRole(phone))
                            .build();
                    userMapper.insert(newUser);
                    return newUser;
                });
    }

    private User findOrCreateUserByEmail(String email) {
        return userMapper.findByEmail(email)
                .orElseGet(() -> {
                    User newUser = User.builder()
                            .email(email)
                            .name("")
                            .role("customer")
                            .build();
                    userMapper.insert(newUser);
                    return newUser;
                });
    }

    private String resolveDefaultRole(String phone) {
        String cleaned = phone.replaceAll("[^0-9]", "");
        String suffix = cleaned.length() >= 3
                ? cleaned.substring(cleaned.length() - 3)
                : cleaned;
        return switch (suffix) {
            case "001" -> "advisor";
            case "002" -> "supervisor";
            case "003" -> "technician";
            case "004" -> "customer";
            case "005" -> "owner";
            case "006" -> "crmDashboard";
            default -> "customer";
        };
    }
}
