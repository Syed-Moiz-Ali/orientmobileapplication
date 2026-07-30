package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.entity.OtpRecord;
import com.orient.workshop.auth.repository.OtpRecordMapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.TooManyRequestsException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private final OtpRecordMapper otpRecordMapper;

    @Value("${app.otp.expiry-minutes:5}")
    private int otpExpiryMinutes;

    @Value("${app.otp.max-attempts:5}")
    private int maxAttempts;

    @Transactional
    public void sendSmsOtp(String phone) {
        otpRecordMapper.findValidByPhone(phone).ifPresent(record -> {
            if (record.getAttempts() >= maxAttempts) {
                throw new TooManyRequestsException("Too many OTP attempts. Please try later.");
            }
        });

        String otpCode = generateOtp();
        log.info("SMS OTP for {}: {}", phone, otpCode);

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
        return "123456";
    }
}
