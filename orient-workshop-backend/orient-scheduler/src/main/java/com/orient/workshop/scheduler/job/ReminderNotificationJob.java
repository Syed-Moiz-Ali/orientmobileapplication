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
 * P2 (audit): the plan-mandated reminder job was MISSING — due reminders were
 * decorative and never notified anyone. Now: for every reminder that is due
 * (or overdue) and not completed/deleted, a notification is emitted to all
 * active advisors.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ReminderNotificationJob {

    private final DataSource dataSource;

    @Scheduled(cron = "0 30 8 * * *")
    public void notifyDueReminders() {
        String sql = """
                SELECT r.id, r.customer_name, r.task, r.due_date
                FROM reminders r
                WHERE r.is_completed = FALSE AND r.deleted = FALSE
                  AND r.due_date IS NOT NULL AND r.due_date <> ''
                  AND COALESCE(STR_TO_DATE(r.due_date, '%%Y-%%m-%%d'),
                               STR_TO_DATE(r.due_date, '%%d/%%m/%%Y')) <= DATE_ADD(CURDATE(), INTERVAL 3 DAY)
                """;
        List<Object[]> due = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                due.add(new Object[]{rs.getLong("id"), rs.getString("customer_name"),
                        rs.getString("task"), rs.getString("due_date")});
            }
        } catch (Exception e) {
            log.debug("Reminder notification check skipped: {}", e.getMessage());
            return;
        }
        if (due.isEmpty()) return;

        List<Long> advisorUserIds = advisorUserIds();
        int inserted = 0;
        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement("""
                    INSERT INTO notifications (user_id, branch_id, type, title, body, is_read, created_at)
                    VALUES (?, NULL, 'reminder', 'Follow-up reminder', ?, FALSE, NOW())
                    """)) {
                for (Object[] row : due) {
                    String body = "Reminder #" + row[0] + " for " + row[1]
                            + (row[2] != null && !row[2].toString().isBlank() ? " — " + row[2] : "")
                            + " (due " + row[3] + ")";
                    for (Long userId : advisorUserIds) {
                        ps.setLong(1, userId);
                        ps.setString(2, body.length() > 500 ? body.substring(0, 500) : body);
                        ps.addBatch();
                    }
                }
                int[] counts = ps.executeBatch();
                for (int c : counts) inserted += c;
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                log.debug("Reminder notifications failed: {}", e.getMessage());
            }
        } catch (Exception e) {
            log.debug("Reminder notification job failed: {}", e.getMessage());
        }
        log.info("ReminderNotificationJob: {} reminder(s) due, {} notification(s) inserted", due.size(), inserted);
    }

    private List<Long> advisorUserIds() {
        List<Long> ids = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT user_id FROM staff WHERE role = 'advisor' AND is_active = TRUE AND user_id IS NOT NULL");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) ids.add(rs.getLong(1));
        } catch (Exception e) {
            log.debug("Could not load advisors: {}", e.getMessage());
        }
        return ids;
    }
}
