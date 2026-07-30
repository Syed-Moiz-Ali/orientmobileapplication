package com.orient.workshop.scheduler.job;

import com.orient.workshop.auth.repository.OtpRecordMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class OtpCleanupJob {

    private final OtpRecordMapper otpRecordMapper;

    @Scheduled(fixedRate = 900000)
    public void cleanup() {
        try {
            otpRecordMapper.deleteExpired();
        } catch (Exception e) {
            log.debug("OTP cleanup skipped: {}", e.getMessage());
        }
    }
}
