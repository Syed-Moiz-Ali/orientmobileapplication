package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.ReportResponse;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final JobCardMapper jobCardMapper;

    public ReportResponse getReports(String range) {
        int total = (int) jobCardMapper.countAll();
        int completed = jobCardMapper.countCompletedToday();
        int inProgress = jobCardMapper.countInProgress();
        int cancelled = jobCardMapper.countCancelled();

        LocalDateTime cutoff = LocalDateTime.now().minusDays("month".equalsIgnoreCase(range) ? 30 : 7);
        List<JobCard> recent = jobCardMapper.selectList(null).stream()
                .filter(c -> c.getCreatedAt() != null && c.getCreatedAt().isAfter(cutoff))
                .collect(Collectors.toList());

        Map<DayOfWeek, Long> byWeekday = recent.stream()
                .filter(c -> c.getCreatedAt() != null)
                .collect(Collectors.groupingBy(c -> c.getCreatedAt().getDayOfWeek(), Collectors.counting()));

        List<ReportResponse.ActivityDto> weekDays = List.of(
                activity("Mon", byWeekday.getOrDefault(DayOfWeek.MONDAY, 0L).intValue()),
                activity("Tue", byWeekday.getOrDefault(DayOfWeek.TUESDAY, 0L).intValue()),
                activity("Wed", byWeekday.getOrDefault(DayOfWeek.WEDNESDAY, 0L).intValue()),
                activity("Thu", byWeekday.getOrDefault(DayOfWeek.THURSDAY, 0L).intValue()),
                activity("Fri", byWeekday.getOrDefault(DayOfWeek.FRIDAY, 0L).intValue()),
                activity("Sat", byWeekday.getOrDefault(DayOfWeek.SATURDAY, 0L).intValue()),
                activity("Sun", byWeekday.getOrDefault(DayOfWeek.SUNDAY, 0L).intValue())
        );

        int totalForPercent = completed + inProgress + cancelled;
        return ReportResponse.builder()
                .totalJobs(total)
                .completedJobs(completed)
                .inProgressJobs(inProgress)
                .cancelledJobs(cancelled)
                .weeklyActivity(weekDays)
                .statusBreakdown(List.of(
                        breakdown("completed", completed, totalForPercent),
                        breakdown("inProgress", inProgress, totalForPercent),
                        breakdown("cancelled", cancelled, totalForPercent)
                ))
                .build();
    }

    private ReportResponse.ActivityDto activity(String day, int count) {
        return ReportResponse.ActivityDto.builder().day(day).count(count).build();
    }

    private ReportResponse.StatusBreakdownDto breakdown(String status, int count, int total) {
        return ReportResponse.StatusBreakdownDto.builder()
                .status(status).count(count)
                .percentage(total > 0 ? Math.round((double) count / total * 1000) / 10.0 : 0)
                .build();
    }
}
