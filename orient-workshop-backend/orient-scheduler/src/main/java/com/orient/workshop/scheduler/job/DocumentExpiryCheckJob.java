package com.orient.workshop.scheduler.job;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * P2 (audit): the plan-mandated document-expiry job was MISSING — expiring
 * employee documents (visas, licenses, insurance) never alerted anyone.
 * Now: documents expiring within 30 days trigger an owner notification.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class DocumentExpiryCheckJob {

    private final DataSource dataSource;

    @Scheduled(cron = "0 0 9 * * *")
    public void checkDocumentExpiry() {
        List<Object[]> expiring = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement("""
                     SELECT id, employee_name, document_type, expiry_date
                     FROM employee_documents
                     WHERE expiry_date IS NOT NULL
                       AND expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
                     """);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                expiring.add(new Object[]{rs.getLong("id"), rs.getString("employee_name"),
                        rs.getString("document_type"), rs.getDate("expiry_date").toLocalDate()});
            }
        } catch (Exception e) {
            log.debug("Document expiry check skipped: {}", e.getMessage());
            return;
        }
        if (expiring.isEmpty()) return;

        List<Long> ownerUserIds = ownerUserIds();
        int inserted = 0;
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement("""
                    INSERT INTO notifications (user_id, branch_id, type, title, body, is_read, created_at)
                    VALUES (?, NULL, 'reminder', 'Document expiring soon', ?, FALSE, NOW())
                    """)) {
                for (Object[] row : expiring) {
                    String body = "Document #" + row[0] + " — " + row[1]
                            + " (" + row[2] + ") expires on " + row[3];
                    for (Long userId : ownerUserIds) {
                        ps.setLong(1, userId);
                        ps.setString(2, body);
                        ps.addBatch();
                    }
                }
                int[] counts = ps.executeBatch();
                for (int c : counts) inserted += c;
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                log.debug("Document expiry notifications failed: {}", e.getMessage());
            }
        } catch (Exception e) {
            log.debug("Document expiry job failed: {}", e.getMessage());
        }
        log.info("DocumentExpiryCheckJob: {} document(s) expiring, {} notification(s) inserted", expiring.size(), inserted);
    }

    private List<Long> ownerUserIds() {
        List<Long> ids = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT id FROM users WHERE role IN ('owner','admin') AND is_active = TRUE");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) ids.add(rs.getLong(1));
        } catch (Exception e) {
            log.debug("Could not load owners: {}", e.getMessage());
        }
        return ids;
    }
}
