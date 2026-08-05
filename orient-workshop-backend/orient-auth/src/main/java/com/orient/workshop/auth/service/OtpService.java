package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.entity.OtpRecord;
import com.orient.workshop.auth.repository.OtpRecordMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.TooManyRequestsException;
import com.orient.workshop.common.util.PhoneUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final OtpRecordMapper otpRecordMapper;

    @Value("${app.otp.expiry-minutes:5}")
    private int otpExpiryMinutes;

    @Value("${app.otp.max-attempts:5}")
    private int maxAttempts;

    /**
     * M-15: dev-only fixed OTP. When set (application-dev.yml sets it to "123456"
     * so development/demo logins keep working), generateOtp returns this value.
     * When blank (default), a SecureRandom 6-digit code is generated.
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
        log.info("SMS OTP for {}: {}", PhoneUtil.mask(phone), otpCode);

        OtpRecord record = OtpRecord.builder()
                .phone(phone)
                .otpCode(otpCode)
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
        log.info("Email OTP for {}: {}", email, otpCode);

        OtpRecord record = OtpRecord.builder()
                .email(email)
                .otpCode(otpCode)
                .expiresAt(LocalDateTime.now().plusMinutes(otpExpiryMinutes))
                .build();
        otpRecordMapper.insert(record);
    }

    public void verifySmsOtp(String phone, String otpCode) {
        OtpRecord record = otpRecordMapper.findValidByPhone(phone)
                .orElseThrow(() -> new BadRequestException("OTP not found or expired"));

        if (!record.getOtpCode().equals(otpCode)) {
            record.setAttempts(record.getAttempts() + 1);
            otpRecordMapper.updateById(record);
            throw new BadRequestException("Invalid OTP");
        }

        otpRecordMapper.markUsed(record.getId());
    }

    public void verifyEmailOtp(String email, String otpCode) {
        OtpRecord record = otpRecordMapper.findValidByEmail(email)
                .orElseThrow(() -> new BadRequestException("OTP not found or expired"));

        if (!record.getOtpCode().equals(otpCode)) {
            record.setAttempts(record.getAttempts() + 1);
            otpRecordMapper.updateById(record);
            throw new BadRequestException("Invalid OTP");
        }

        otpRecordMapper.markUsed(record.getId());
    }

    private String generateOtp() {
        if (fixedOtpValue != null && !fixedOtpValue.isBlank()) {
            return fixedOtpValue;
        }
        return String.format("%06d", SECURE_RANDOM.nextInt(1_000_000));
    }
}
