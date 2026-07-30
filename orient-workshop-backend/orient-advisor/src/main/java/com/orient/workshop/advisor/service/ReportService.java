package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.ReportResponse;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final JobCardMapper jobCardMapper;

    public ReportResponse getReports(String range) {
        int total = (int) jobCardMapper.countAll();
        int completed = jobCardMapper.countCompletedToday();
        int inProgress = jobCardMapper.countInProgress();
        int cancelled = jobCardMapper.countCancelled();

        ReportResponse.ActivityDto[] weekDays = {
                activity("Mon", 3), activity("Tue", 5), activity("Wed", 4),
                activity("Thu", 6), activity("Fri", 2), activity("Sat", 4), activity("Sun", 1)
        };

        int totalForPercent = completed + inProgress + cancelled;
        return ReportResponse.builder()
                .totalJobs(total)
                .completedJobs(completed)
                .inProgressJobs(inProgress)
                .cancelledJobs(cancelled)
                .weeklyActivity(List.of(weekDays))
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
