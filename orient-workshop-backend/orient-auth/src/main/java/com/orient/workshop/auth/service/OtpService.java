package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.entity.OtpRecord;
import com.orient.workshop.auth.repository.OtpRecordMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.TooManyRequestsException;
import com.orient.workshop.common.util.PhoneUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final OtpRecordMapper otpRecordMapper;
    private final Environment environment;

    // FIX (audit QA BUG-009): self-reference so REQUIRES_NEW actually applies —
    // a direct self-invocation would bypass the Spring proxy and run inside the
    // caller's transaction (which rolls back on the wrong-OTP exception).
    @Lazy
    @Autowired
    private OtpService self;

    @Value("${app.otp.expiry-minutes:5}")
    private int otpExpiryMinutes;

    @Value("${app.otp.max-attempts:5}")
    private int maxAttempts;

    /**
     * M-15: dev-only fixed OTP. When set (application-dev.yml sets it to "123456"
     * so development/demo logins keep working), generateOtp returns this value.
     * When blank (default), a SecureRandom 6-digit code is generated.
     * S-3: the fixed value is honoured ONLY when the 'dev' profile is active;
     * any other profile with app.otp.fixed-value set falls back to SecureRandom
     * and logs a warning (fail-safe, never a silent fixed code in prod).
     */
    @Value("${app.otp.fixed-value:}")
    private String fixedOtpValue;

    @Transactional
    public void sendSmsOtp(String phone) {
        otpRecordMapper.findValidByPhone(phone).ifPresent(record -> {
            if (record.getAttempts() >= maxAttempts) {
                throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
            }
        });

        String otpCode = generateOtp();
        // S-6: never log the OTP itself — only a masked confirmation.
        log.info("SMS OTP sent to {}", PhoneUtil.mask(phone));

        OtpRecord record = OtpRecord.builder()
                .phone(phone)
                // P1: store only a SHA-256 digest — a DB leak no longer yields codes.
                .otpCode(hashOtp(otpCode))
                .expiresAt(LocalDateTime.now().plusMinutes(otpExpiryMinutes))
                .build();
        otpRecordMapper.insert(record);
    }

    @Transactional
    public void sendEmailOtp(String email) {
        otpRecordMapper.findValidByEmail(email).ifPresent(record -> {
            if (record.getAttempts() >= maxAttempts) {
                throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
            }
        });

        String otpCode = generateOtp();
        // S-6: never log the OTP itself.
        log.info("Email OTP sent to {}", maskEmail(email));

        OtpRecord record = OtpRecord.builder()
                .email(email)
                .otpCode(hashOtp(otpCode))
                .expiresAt(LocalDateTime.now().plusMinutes(otpExpiryMinutes))
                .build();
        otpRecordMapper.insert(record);
    }

    public void verifySmsOtp(String phone, String otpCode) {
        OtpRecord record = otpRecordMapper.findValidByPhone(phone)
                .orElseThrow(() -> new BadRequestException("OTP not found or expired"));

        // S-6: cap verification attempts too (previously only the send path was capped).
        if (record.getAttempts() >= maxAttempts) {
            throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
        }

        // S-6 + P1: constant-time comparison against the stored digest.
        if (!constantTimeEquals(record.getOtpCode(), hashOtp(otpCode))) {
            // FIX (audit QA BUG-009): the failed-attempt counter must survive the
            // outer verifyOtp transaction rollback. AuthService.verifyOtp is
            // @Transactional and throws on the wrong OTP — a plain update here was
            // rolled back with it, so the 5-attempt cap never accumulated and OTPs
            // could be brute-forced indefinitely. REQUIRES_NEW commits independently.
            boolean capped = self.recordFailedAttempt(record.getId());
            if (capped) {
                throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
            }
            throw new BadRequestException("Invalid OTP");
        }

        otpRecordMapper.markUsed(record.getId());
    }

    public void verifyEmailOtp(String email, String otpCode) {
        OtpRecord record = otpRecordMapper.findValidByEmail(email)
                .orElseThrow(() -> new BadRequestException("OTP not found or expired"));

        // S-6: cap verification attempts.
        if (record.getAttempts() >= maxAttempts) {
            throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
        }

        if (!constantTimeEquals(record.getOtpCode(), hashOtp(otpCode))) {
            boolean capped = self.recordFailedAttempt(record.getId());
            if (capped) {
                throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
            }
            throw new BadRequestException("Invalid OTP");
        }

        otpRecordMapper.markUsed(record.getId());
    }

    /**
     * FIX (audit QA BUG-009): increments the failed-attempt counter in its own
     * transaction so it is committed even when the caller's transaction rolls
     * back. Returns true when the counter reached the cap.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    boolean recordFailedAttempt(Long recordId) {
        OtpRecord record = otpRecordMapper.selectById(recordId);
        if (record == null) return false;
        int next = record.getAttempts() + 1;
        record.setAttempts(next);
        otpRecordMapper.updateById(record);
        return next >= maxAttempts;
    }

    /**
     * P1: OTPs are never stored in plaintext — SHA-256 digest at rest.
     */
    private static String hashOtp(String otpCode) {
        if (otpCode == null) return null;
        try {
            byte[] digest = java.security.MessageDigest.getInstance("SHA-256")
                    .digest(otpCode.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(Character.forDigit((b >> 4) & 0xF, 16));
                sb.append(Character.forDigit(b & 0xF, 16));
            }
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        byte[] ba = a.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] bb = b.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        return java.security.MessageDigest.isEqual(ba, bb);
    }

    private static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return "***";
        String local = email.substring(0, email.indexOf('@'));
        String domain = email.substring(email.indexOf('@'));
        String maskedLocal = local.length() <= 2 ? "*".repeat(local.length()) : local.substring(0, 1) + "***" + local.substring(local.length() - 1);
        return maskedLocal + domain;
    }

    private String generateOtp() {
        if (fixedOtpValue != null && !fixedOtpValue.isBlank()) {
            // acceptsProfiles covers BOTH explicitly-active profiles AND the
            // default profile (spring.profiles.default=dev) — getActiveProfiles()
            // alone misses defaults, which broke login when dev was the default.
            boolean devActive = environment != null
                    && environment.acceptsProfiles(org.springframework.core.env.Profiles.of("dev"));
            if (devActive) {
                return fixedOtpValue;
            }
            // S-3: fixed OTP configured outside the dev profile — refuse silently.
            log.warn("app.otp.fixed-value is set but the 'dev' profile is NOT active; ignoring fixed OTP");
        }
        return String.format("%06d", SECURE_RANDOM.nextInt(1_000_000));
    }
}
