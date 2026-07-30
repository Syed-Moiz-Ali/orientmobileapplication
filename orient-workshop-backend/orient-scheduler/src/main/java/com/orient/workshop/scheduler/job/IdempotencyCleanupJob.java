package com.orient.workshop.scheduler.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

@Slf4j
@Component
@RequiredArgsConstructor
public class IdempotencyCleanupJob {

    private final DataSource dataSource;

    @Scheduled(cron = "0 0 3 * * *")
    public void cleanup() {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            int deleted = stmt.executeUpdate(
                    "DELETE FROM idempotency_keys WHERE created_at < NOW() - INTERVAL 7 DAY");
            if (deleted > 0) log.info("Cleaned up {} expired idempotency keys", deleted);
        } catch (Exception e) {
            log.debug("Idempotency cleanup skipped: {}", e.getMessage());
        }
    }
}
