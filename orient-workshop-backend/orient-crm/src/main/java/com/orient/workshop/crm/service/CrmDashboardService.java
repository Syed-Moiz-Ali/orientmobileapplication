package com.orient.workshop.crm.service;

import com.orient.workshop.core.repository.FeedbackMapper;
import com.orient.workshop.crm.model.dto.*;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.TextStyle;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CrmDashboardService {

    private final FeedbackMapper feedbackMapper;
    private final LeadMapper leadMapper;

    public List<CrmKpiResponse> getKpis() {
        long total = leadMapper.countAll();
        long active = leadMapper.countByStatus("ACTIVE");
        long won = leadMapper.countByStatus("WON");
        long lost = leadMapper.countByStatus("LOST");
        long unanswered = leadMapper.countByStatus("UNANSWERED");
        long noResponse = leadMapper.countByStatus("NO_RESPONSE");

        NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
        return List.of(
            kpi("Total Leads", nf.format(total), ""),
            kpi("Active Leads", nf.format(active), ""),
            kpi("Won", nf.format(won), ""),
            kpi("Lost", nf.format(lost), ""),
            kpi("Unanswered", nf.format(unanswered), ""),
            kpi("No Response", nf.format(noResponse), "")
        );
    }

    public List<ChannelResponse> getChannels() {
        return leadMapper.groupBySource().stream()
                .map(row -> channel(str(row.get("name")), num(row.get("cnt"))))
                .collect(Collectors.toList());
    }

    public List<ConversionTrendResponse> getConversionTrend() {
        List<Map<String, Object>> rows = leadMapper.groupByMonthStatus();
        Map<String, Map<String, Long>> byMonth = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            String month = str(row.get("month"));
            String status = str(row.get("status")).toUpperCase();
            long cnt = num(row.get("cnt"));
            byMonth.computeIfAbsent(month, k -> new HashMap<>()).merge(status, cnt, Long::sum);
        }
        if (byMonth.isEmpty()) return List.of();

        // fill last 6 months (including current)
        Map<String, String> monthNames = new LinkedHashMap<>();
        LocalDate now = LocalDate.now();
        for (int i = 5; i >= 0; i--) {
            LocalDate d = now.minus(i, ChronoUnit.MONTHS);
            String key = d.getMonth().getDisplayName(TextStyle.SHORT, Locale.US);
            monthNames.put(key, key);
        }
        List<ConversionTrendResponse> result = new ArrayList<>();
        for (String key : monthNames.keySet()) {
            Map<String, Long> m = byMonth.getOrDefault(key, new HashMap<>());
            long active = m.getOrDefault("ACTIVE", 0L) + m.getOrDefault("UNANSWERED", 0L);
            result.add(trend(key,
                    m.getOrDefault("WON", 0L).intValue(),
                    m.getOrDefault("LOST", 0L).intValue(),
                    (int) active));
        }
        return result;
    }

    public List<SalespersonPerfResponse> getSalespersonPerformance() {
        Map<String, Long> handled = leadMapper.groupByAssignee().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));
        Map<String, Long> won = leadMapper.groupByAssigneeWon().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));
        return handled.entrySet().stream()
                .map(e -> perf(e.getKey(), e.getValue().intValue(),
                        won.getOrDefault(e.getKey(), 0L).intValue()))
                .collect(Collectors.toList());
    }

    public List<ResponseTimeResponse> getResponseTimes() {
        return List.of();
    }

    public List<LeadSourceResponse> getLeadSources() {
        List<Map<String, Object>> rows = leadMapper.groupBySource();
        long total = rows.stream().mapToLong(r -> num(r.get("cnt"))).sum();
        if (total == 0) return List.of();
        return rows.stream()
                .map(r -> ls(str(r.get("name")), (int) Math.round(num(r.get("cnt")) * 100.0 / total)))
                .collect(Collectors.toList());
    }

    public KeyMetricResponse getKeyMetrics() {
        long total = leadMapper.countAll();
        long won = leadMapper.countByStatus("WON");
        double winRate = total > 0 ? Math.round(won * 1000.0 / total) / 10.0 : 0.0;
        double avgRating = feedbackMapper.selectList(null).stream()
                .mapToInt(com.orient.workshop.core.model.entity.Feedback::getRating)
                .average().orElse(0.0);
        return KeyMetricResponse.builder()
                .winRate(winRate)
                .avgResponseTime("")
                .satisfaction(Math.round(avgRating * 10) / 10.0)
                .roi(0)
                .build();
    }

    private CrmKpiResponse kpi(String label, String value, String change) {
        return CrmKpiResponse.builder().label(label).value(value).change(change).build();
    }
    private ChannelResponse channel(String name, long count) {
        return ChannelResponse.builder().name(name).count((int) count).build();
    }
    private ConversionTrendResponse trend(String month, int won, int lost, int active) {
        return ConversionTrendResponse.builder().month(month).won(won).lost(lost).active(active).build();
    }
    private SalespersonPerfResponse perf(String name, int leads, int won) {
        return SalespersonPerfResponse.builder().name(name).leads(leads).won(won).build();
    }
    private LeadSourceResponse ls(String label, int percent) {
        return LeadSourceResponse.builder().label(label).percent(percent).build();
    }

    private String str(Object o) { return o != null ? o.toString() : ""; }
    private long num(Object o) { return o instanceof Number n ? n.longValue() : 0L; }
}
