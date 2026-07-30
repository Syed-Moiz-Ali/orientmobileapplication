package com.orient.workshop.crm.service;

import com.orient.workshop.core.repository.FeedbackMapper;
import com.orient.workshop.crm.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CrmDashboardService {

    private final FeedbackMapper feedbackMapper;

    public List<CrmKpiResponse> getKpis() {
        return List.of(
            kpi("Messages", "1,847", "+12.5%"),
            kpi("Active Leads", "347", "-3.2%"),
            kpi("Unanswered", "23", "-8.1%"),
            kpi("Won", "89", "+15.3%"),
            kpi("Lost", "45", "+2.1%"),
            kpi("No Response", "134", "+5.7%")
        );
    }

    public List<ChannelResponse> getChannels() {
        return List.of(
            channel("WhatsApp Lite", 420), channel("WhatsApp Cloud", 380),
            channel("Instagram", 290), channel("SMS", 215),
            channel("Live Chat", 180), channel("Google Ads", 145),
            channel("Website", 120), channel("Email", 97)
        );
    }

    public List<ConversionTrendResponse> getConversionTrend() {
        return List.of(
            trend("Jan", 45, 22, 180), trend("Feb", 52, 18, 195),
            trend("Mar", 48, 25, 210), trend("Apr", 61, 20, 185),
            trend("May", 55, 28, 200), trend("Jun", 58, 24, 190),
            trend("Jul", 50, 30, 175)
        );
    }

    public List<SalespersonPerfResponse> getSalespersonPerformance() {
        return List.of(perf("Ahmed Al Maktoum", 85, 32), perf("Fatima Hassan", 72, 28));
    }

    public List<ResponseTimeResponse> getResponseTimes() {
        return List.of(
            rt("< 5 min", 320), rt("5-15 min", 245), rt("15-30 min", 180),
            rt("30-60 min", 95), rt("> 60 min", 60)
        );
    }

    public List<LeadSourceResponse> getLeadSources() {
        return List.of(
            ls("WhatsApp", 35), ls("Instagram", 20), ls("Website", 18),
            ls("Google Ads", 15), ls("Referral", 12)
        );
    }

    public KeyMetricResponse getKeyMetrics() {
        double avgRating = feedbackMapper.selectList(null).stream()
                .mapToInt(com.orient.workshop.core.model.entity.Feedback::getRating)
                .average().orElse(4.7);
        return KeyMetricResponse.builder()
                .winRate(38.2).avgResponseTime("4.5 min")
                .satisfaction(Math.round(avgRating * 10) / 10.0)
                .roi(285).build();
    }

    private CrmKpiResponse kpi(String label, String value, String change) {
        return CrmKpiResponse.builder().label(label).value(value).change(change).build();
    }
    private ChannelResponse channel(String name, int count) {
        return ChannelResponse.builder().name(name).count(count).build();
    }
    private ConversionTrendResponse trend(String month, int won, int lost, int active) {
        return ConversionTrendResponse.builder().month(month).won(won).lost(lost).active(active).build();
    }
    private SalespersonPerfResponse perf(String name, int leads, int won) {
        return SalespersonPerfResponse.builder().name(name).leads(leads).won(won).build();
    }
    private ResponseTimeResponse rt(String label, int count) {
        return ResponseTimeResponse.builder().label(label).count(count).build();
    }
    private LeadSourceResponse ls(String label, int percent) {
        return LeadSourceResponse.builder().label(label).percent(percent).build();
    }
}
