package com.orient.workshop.scheduler.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

@Slf4j
@Component
@RequiredArgsConstructor
public class InvoiceOverdueJob {

    private final DataSource dataSource;

    @Scheduled(cron = "0 0 0 * * *")
    @SchedulerLock(name = "InvoiceOverdue", lockAtMostFor = "15m", lockAtLeastFor = "5s")
    public void updateOverdueInvoices() {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            int updated = stmt.executeUpdate(
                    "UPDATE invoices SET status = 'overdue' WHERE status = 'unpaid' AND due_date < CURDATE()");
            if (updated > 0) log.info("Marked {} invoices as overdue", updated);
        } catch (Exception e) {
            log.debug("Invoice overdue check skipped: {}", e.getMessage());
        }
    }
}
