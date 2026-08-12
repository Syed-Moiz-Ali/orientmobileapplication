package com.orient.workshop.auth.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.auth.model.dto.MeResponse;
import com.orient.workshop.auth.model.dto.TokenResponse;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.common.constant.RoleConstants;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.exception.TooManyRequestsException;
import com.orient.workshop.common.util.PhoneUtil;
import com.orient.workshop.core.model.entity.Branch;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.BranchMapper;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.StaffMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final int MAX_FAILURES = 5;
    private static final long BASE_LOCK_SECONDS = 30;
    private static final long MAX_LOCK_SECONDS = 900;
    private static final long ATTEMPT_TTL_MILLIS = 30 * 60 * 1000L;
    private static final int MAX_ATTEMPT_TRACKER_SIZE = 100_000;

    private final UserMapper userMapper;
    private final OtpService otpService;
    private final JwtService jwtService;
    private final PasswordService passwordService;
    private final StaffMapper staffMapper;
    private final CustomerMapper customerMapper;
    private final BranchMapper branchMapper;

    private final Map<String, LoginAttempt> loginAttempts = new ConcurrentHashMap<>();

    // ========== SESSION (GET /auth/me) ==========

    /**
     * Unified session/profile for any authenticated role, resolved from the JWT.
     * Invalid/inactive users never reach here (JwtAuthenticationFilter rejects
     * them with 401), so this always returns a valid profile.
     */
    public MeResponse getMe(JwtUserPrincipal principal) {
        Long userId = principal.getUserId();
        if (userId == null) {
            throw new BadRequestException("User ID not found in token");
        }

        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new NotFoundException("User not found with id: " + userId);
        }

        Long branchId = user.getBranchId() != null ? user.getBranchId() : principal.getBranchId();
        MeResponse.MeResponseBuilder builder = MeResponse.builder()
                .userId(user.getId())
                .name(user.getName())
                .phone(user.getPhone())
                .email(user.getEmail())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .branchId(branchId);

        // Staff record (advisor / supervisor / technician / owner with staff entry)
        Staff staff = staffMapper.findByUserId(userId).orElse(null);
        if (staff != null) {
            builder.staffId(staff.getId())
                    .empId(staff.getEmpId())
                    .avatarInitials(staff.getAvatarInitials())
                    .shift(staff.getShift())
                    .designation(staff.getDesignation())
                    .department(staff.getDepartment())
                    .name(staff.getName() != null && !staff.getName().isBlank() ? staff.getName() : user.getName());
            if (staff.getBranchId() != null) {
                branchId = staff.getBranchId();
                builder.branchId(branchId);
            }
        }

        // Customer record
        Customer customer = customerMapper.findByUserId(userId).orElse(null);
        if (customer != null) {
            builder.customerId(customer.getId())
                    .memberId("CUST-" + String.format("%03d", customer.getId()))
                    .name(customer.getCustomerName() != null && !customer.getCustomerName().isBlank()
                            ? customer.getCustomerName() : user.getName());
        }

        if (branchId != null && branchId > 0) {
            Branch branch = branchMapper.selectById(branchId);
            if (branch != null) {
                builder.branchName(branch.getName());
            }
        }

        MeResponse response = builder.build();
        if (response.getAvatarInitials() == null || response.getAvatarInitials().isBlank()) {
            response.setAvatarInitials(getInitials(response.getName() != null ? response.getName() : "U"));
        }
        return response;
    }

    private String getInitials(String name) {
        if (name == null || name.isBlank()) return "U";
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) return String.valueOf(parts[0].charAt(0)).toUpperCase();
        return (String.valueOf(parts[0].charAt(0)) + String.valueOf(parts[parts.length - 1].charAt(0))).toUpperCase();
    }

    // ========== OTP (unified sms + email) ==========

    public void sendOtp(String type, String phone, String email) {
        switch (type) {
            case "sms" -> {
                if (phone == null || phone.isBlank())
                    throw new BadRequestException("Phone is required for sms OTP");
                String normalized = PhoneUtil.normalize(phone);
                // FIX (audit QA BUG-005): reject invalid phones — previously any
                // non-blank value got an OTP record (abuse / invalid SMS targets).
                if (!PhoneUtil.isValid(normalized)) {
                    throw new BadRequestException("Invalid phone number");
                }
                otpService.sendSmsOtp(normalized);
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
                // FIX (audit QA BUG-005): reject invalid phones at verification too.
                if (!PhoneUtil.isValid(normalizedPhone)) {
                    throw new BadRequestException("Invalid phone number");
                }
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

        // CR-5: self-service registration may only create customer accounts.
        // Staff roles are provisioned by an admin flow.
        String resolvedRole = RoleConstants.CUSTOMER;
        if (role != null && !role.isBlank()) {
            String normalizedRole = role.trim().toLowerCase();
            if (!RoleConstants.CUSTOMER.equals(normalizedRole)) {
                throw new BadRequestException("Role '" + role + "' is not allowed for self-registration");
            }
            resolvedRole = normalizedRole;
        }

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
        String identifier = resolveIdentifier(email, phone);
        LoginAttempt attempt = loginAttempts.computeIfAbsent(identifier, k -> new LoginAttempt());
        long now = System.currentTimeMillis();
        evictExpiredAttempts(now);

        if (attempt.isLocked(now)) {
            throw new TooManyRequestsException("Too many failed attempts. Try again in a while.");
        }

        try {
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
            loginAttempts.remove(identifier);
            return jwtService.createTokenPair(user);
        } catch (BadRequestException e) {
            int failures = attempt.recordFailure(now);
            if (failures >= MAX_FAILURES) {
                log.warn("Login lockout for {} after {} failures", maskIdentifier(identifier), failures);
            }
            throw e;
        }
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
                        .orElseThrow(() -> {
                            // S-14: generic message — never confirm account existence.
                            log.info("reset-password: no account for masked phone {}", PhoneUtil.mask(normalizedPhone));
                            return new BadRequestException("If an account exists, a reset code was sent");
                        });
            }
            case "email" -> {
                if (email == null || email.isBlank())
                    throw new BadRequestException("Email is required for email");
                String normalizedEmail = email.trim().toLowerCase();
                otpService.verifyEmailOtp(normalizedEmail, otp);
                user = userMapper.findByEmail(normalizedEmail)
                        .orElseThrow(() -> {
                            // S-14: generic message — never confirm account existence.
                            log.info("reset-password: no account for email {}", maskEmail(normalizedEmail));
                            return new BadRequestException("If an account exists, a reset code was sent");
                        });
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
                    // S-2: OTP self-service accounts are ALWAYS customers.
                    // Privileged roles (advisor/supervisor/technician/owner/crm)
                    // require an existing staff record provisioned by an admin flow.
                    User newUser = User.builder()
                            .phone(phone)
                            .name("")
                            .role(RoleConstants.CUSTOMER)
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

    // S-2 (resolved): new OTP users are always customers; privileged roles
    // require an admin-provisioned staff record (see findOrCreateUserByPhone).

    // ========== LOGIN FAILURE BACKOFF ==========

    private String resolveIdentifier(String email, String phone) {
        if (email != null && !email.isBlank()) return "email:" + email.trim().toLowerCase();
        if (phone != null && !phone.isBlank()) return "phone:" + PhoneUtil.normalize(phone);
        return "unknown:" + System.identityHashCode(this);
    }

    private String maskIdentifier(String identifier) {
        if (identifier.startsWith("phone:")) {
            return "phone:" + PhoneUtil.mask(identifier.substring("phone:".length()));
        }
        return identifier;
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "***";
        String local = email.substring(0, email.indexOf('@'));
        String domain = email.substring(email.indexOf('@'));
        String maskedLocal = local.length() <= 2 ? "*".repeat(local.length()) : local.substring(0, 1) + "***" + local.substring(local.length() - 1);
        return maskedLocal + domain;
    }

    private void evictExpiredAttempts(long now) {
        if (loginAttempts.size() < MAX_ATTEMPT_TRACKER_SIZE) return;
        loginAttempts.entrySet().removeIf(e -> e.getValue().isExpired(now));
        if (loginAttempts.size() >= MAX_ATTEMPT_TRACKER_SIZE) {
            // Bound the tracker even under a burst of distinct identifiers:
            // drop the oldest quarter without mercy (a fresh login simply starts over).
            loginAttempts.entrySet().removeIf(e -> e.getValue().lastFailureAtMillis < now - ATTEMPT_TTL_MILLIS / 4);
        }
    }

    private static final class LoginAttempt {
        private int failures;
        private long lastFailureAtMillis;
        private long lockedUntilMillis;

        synchronized boolean isLocked(long now) {
            return now < lockedUntilMillis;
        }

        synchronized boolean isExpired(long now) {
            return failures == 0 || now - lastFailureAtMillis > ATTEMPT_TTL_MILLIS;
        }

        synchronized int recordFailure(long now) {
            failures++;
            lastFailureAtMillis = now;
            if (failures >= MAX_FAILURES) {
                long exponent = Math.min(failures - MAX_FAILURES, 5);
                long lockSeconds = Math.min(BASE_LOCK_SECONDS * (1L << exponent), MAX_LOCK_SECONDS);
                lockedUntilMillis = now + lockSeconds * 1000L;
            }
            return failures;
        }
    }
}
