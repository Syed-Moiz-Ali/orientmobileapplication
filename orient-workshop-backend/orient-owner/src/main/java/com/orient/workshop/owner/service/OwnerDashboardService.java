package com.orient.workshop.owner.service;

import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.owner.model.dto.*;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.repository.InvoiceMapper;
import com.orient.workshop.owner.repository.OwnerStatsMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerDashboardService {

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("MMM d");
    private static final int TOP_N = 5;

    private final JobCardMapper jobCardMapper;
    private final InvoiceMapper invoiceMapper;
    private final OwnerStatsMapper ownerStatsMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;

    public List<KpiCardResponse> getKpis() {
        int totalJobs = (int) jobCardMapper.countAll();
        int activeJobs = jobCardMapper.countOpen();
        int cancelled = jobCardMapper.countCancelled();
        int newToday = jobCardMapper.countToday();

        BigDecimal invoiceRevenue = ownerStatsMapper.sumInvoiceAmount();
        BigDecimal receivables = ownerStatsMapper.sumOutstandingAmount();
        BigDecimal partsRevenue = ownerStatsMapper.sumPartsTotal();
        BigDecimal labourRevenue = ownerStatsMapper.sumServicesTotal();

        // FIX (audit P0): removed 7 hardcoded "0" KPIs (purchases, payables,
        // profit, cash, bank, inventory, commission) and the duplicated
        // "Total Sales" card. Every card shown is now computed from real data;
        // unbacked metrics are simply absent until their tables exist.
        return List.of(
            kpi("Active Jobs", String.valueOf(activeJobs), "Open job cards"),
            kpi("New Jobs", String.valueOf(newToday), "Today"),
            kpi("Cancelled Jobs", String.valueOf(cancelled), "Total"),
            kpi("Total Jobs", String.valueOf(totalJobs), "All time"),
            kpi("Invoice Revenue", formatCurrency(invoiceRevenue), "All time"),
            kpi("Receivables", formatCurrency(receivables), "Unpaid"),
            kpi("Parts Revenue", formatCurrency(partsRevenue), "Repair orders"),
            kpi("Labour Revenue", formatCurrency(labourRevenue), "Repair orders")
        );
    }

    public List<TrendPointResponse> getSalesTrend() {
        Map<LocalDate, BigDecimal> byDay = new HashMap<>();
        for (Invoice inv : invoiceMapper.selectList(null)) {
            if (inv.getCreatedAt() == null || inv.getAmount() == null) continue;
            LocalDate day = inv.getCreatedAt().toLocalDate();
            byDay.merge(day, inv.getAmount(), BigDecimal::add);
        }
        return dailyTrend(lastDays(7), day -> byDay.getOrDefault(day, BigDecimal.ZERO).longValue());
    }

    /**
     * FIX (audit P0): this endpoint previously returned completed-JOB COUNTS
     * mislabeled as profit — a materially misleading chart. Without a cost
     * ledger there is no true profit; return daily invoice revenue instead
     * (real, computed data).
     */
    public List<TrendPointResponse> getProfitTrend() {
        Map<LocalDate, BigDecimal> byDay = new HashMap<>();
        for (Invoice inv : invoiceMapper.selectList(null)) {
            if (inv.getCreatedAt() == null || inv.getAmount() == null) continue;
            LocalDate day = inv.getCreatedAt().toLocalDate();
            byDay.merge(day, inv.getAmount(), BigDecimal::add);
        }
        return dailyTrend(lastDays(7), day -> byDay.getOrDefault(day, BigDecimal.ZERO).longValue());
    }

    public List<TrendPointResponse> getExpensesTrend() {
        // No cost/expense ledger exists yet — an honest all-zero series.
        return dailyTrend(lastDays(7), day -> 0L);
    }

    /**
     * P3 (audit): AI-lite revenue forecast — a transparent 7-day moving
     * average of invoice revenue projected 30 days forward. Clearly labelled
     * as an estimate, not a promise.
     */
    public Map<String, Object> getForecast() {
        Map<LocalDate, BigDecimal> byDay = new HashMap<>();
        for (Invoice inv : invoiceMapper.selectList(null)) {
            if (inv.getCreatedAt() == null || inv.getAmount() == null) continue;
            byDay.merge(inv.getCreatedAt().toLocalDate(), inv.getAmount(), BigDecimal::add);
        }
        LocalDate today = LocalDate.now();
        BigDecimal sevenDayTotal = BigDecimal.ZERO;
        int daysWithData = 0;
        for (int i = 6; i >= 0; i--) {
            BigDecimal v = byDay.getOrDefault(today.minusDays(i), BigDecimal.ZERO);
            sevenDayTotal = sevenDayTotal.add(v);
            if (v.compareTo(BigDecimal.ZERO) > 0) daysWithData++;
        }
        if (daysWithData == 0) {
            return Map.of("method", "7-day moving average", "daysWithData", 0,
                    "dailyAverage", "0.00", "forecast30Days", "0.00", "note", "no revenue data yet");
        }
        BigDecimal dailyAverage = sevenDayTotal.divide(BigDecimal.valueOf(7), 2, RoundingMode.HALF_UP);
        BigDecimal forecast = dailyAverage.multiply(BigDecimal.valueOf(30)).setScale(2, RoundingMode.HALF_UP);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("method", "7-day moving average of invoice revenue");
        result.put("daysWithData", daysWithData);
        result.put("dailyAverage", dailyAverage.toPlainString());
        result.put("forecast30Days", forecast.toPlainString());
        result.put("note", "Estimate — replace with a model when more history exists");
        return result;
    }

    public List<JobCardRegisterResponse> getJobCardRegister() {
        List<JobCard> cards = jobCardMapper.findRecent(50, 0);
        if (cards.isEmpty()) return List.of();
        return cards.stream()
                .map(c -> {
                    boolean open = c.getStatus() == null
                            || (!"completed".equals(c.getStatus()) && !"cancelled".equals(c.getStatus()));
                    boolean completed = "completed".equals(c.getStatus());
                    return register(c.getJobCardRef(), open ? 1 : 0, completed ? 1 : 0);
                })
                .collect(Collectors.toList());
    }

    public List<TopSalesCategoryResponse> getTopSales() {
        List<Invoice> invoices = invoiceMapper.selectList(null);
        Map<Long, String> customerNames = loadCustomerNames();

        List<TopSalesCategoryResponse.TopSalesItem> byCustomer = topByInvoiceField(invoices,
                inv -> customerNames.getOrDefault(inv.getCustomerId(), "Customer #" + inv.getCustomerId()));

        List<TopSalesCategoryResponse.TopSalesItem> byAdvisor = topByInvoiceField(invoices,
                inv -> advisorForJob(inv.getJobCardId()));

        List<TopSalesCategoryResponse.TopSalesItem> byBrand = topByInvoiceField(invoices,
                inv -> vehicleForJob(inv.getJobCardId()));

        List<TopSalesCategoryResponse.TopSalesItem> bySalesValue = topRepairOrdersByCustomer();

        List<TopSalesCategoryResponse.TopSalesItem> byParts = ownerStatsMapper.topParts(TOP_N).stream()
                .map(r -> item(str(r.get("name")), dec(r.get("value"))))
                .collect(Collectors.toList());

        List<TopSalesCategoryResponse.TopSalesItem> byLabour = ownerStatsMapper.topLabour(TOP_N).stream()
                .map(r -> item(str(r.get("name")), dec(r.get("value"))))
                .collect(Collectors.toList());

        List<TopSalesCategoryResponse.TopSalesItem> byDepartment = ownerStatsMapper.revenueByDepartment(TOP_N).stream()
                .map(r -> item(str(r.get("name")), dec(r.get("value"))))
                .collect(Collectors.toList());

        return List.of(
                topSales("Customer Wise", byCustomer),
                topSales("Brand/Model Wise", byBrand),
                topSales("Advisor Wise", byAdvisor),
                topSales("Sales Value Wise", bySalesValue),
                topSales("Spare Parts Revenue Wise", byParts),
                topSales("Labour Revenue Wise", byLabour),
                topSales("Department Wise", byDepartment)
        );
    }

    // ===== helpers =====

    private Map<Long, String> loadCustomerNames() {
        return customerMapper.selectList(null).stream()
                .collect(Collectors.toMap(Customer::getId,
                        c -> c.getCustomerName() != null && !c.getCustomerName().isBlank()
                                ? c.getCustomerName() : "Customer #" + c.getId()));
    }

    private List<TopSalesCategoryResponse.TopSalesItem> topByInvoiceField(
            List<Invoice> invoices, Function<Invoice, String> keyFn) {
        Map<String, BigDecimal> totals = new LinkedHashMap<>();
        for (Invoice inv : invoices) {
            String key = keyFn.apply(inv);
            if (key == null || key.isBlank()) continue;
            totals.merge(key, inv.getAmount() != null ? inv.getAmount() : BigDecimal.ZERO, BigDecimal::add);
        }
        return totals.entrySet().stream()
                .sorted(Map.Entry.<String, BigDecimal>comparingByValue().reversed())
                .limit(TOP_N)
                .map(e -> item(e.getKey(), e.getValue()))
                .collect(Collectors.toList());
    }

    private List<TopSalesCategoryResponse.TopSalesItem> topRepairOrdersByCustomer() {
        List<Map<String, Object>> rows = ownerStatsMapper.salesValueByCustomer(TOP_N);
        return rows.stream()
                .map(r -> item(str(r.get("name")), dec(r.get("value"))))
                .collect(Collectors.toList());
    }

    private String advisorForJob(Long jobCardId) {
        if (jobCardId == null) return null;
        JobCard card = jobCardMapper.selectById(jobCardId);
        if (card == null || card.getTechnician() == null || card.getTechnician().isBlank()) return null;
        return card.getTechnician();
    }

    private String vehicleForJob(Long jobCardId) {
        if (jobCardId == null) return null;
        JobCard card = jobCardMapper.selectById(jobCardId);
        if (card == null || card.getVehicleId() == null) return null;
        Vehicle v = vehicleMapper.selectById(card.getVehicleId());
        if (v == null) return null;
        return (v.getMake() != null ? v.getMake() : "") + " " + (v.getModel() != null ? v.getModel() : "");
    }

    private List<TrendPointResponse> dailyTrend(List<LocalDate> days, Function<LocalDate, Long> fn) {
        return days.stream()
                .map(d -> TrendPointResponse.builder().month(d.format(DAY_FMT)).value(fn.apply(d)).build())
                .collect(Collectors.toList());
    }

    private List<LocalDate> lastDays(int n) {
        List<LocalDate> days = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int i = n - 1; i >= 0; i--) days.add(today.minusDays(i));
        return days;
    }

    private KpiCardResponse kpi(String label, String value, String sub) {
        return KpiCardResponse.builder().label(label).value(value).sub(sub).build();
    }

    private JobCardRegisterResponse register(String label, int open, int completed) {
        return JobCardRegisterResponse.builder().label(label).open(open).completed(completed).total(open + completed).build();
    }

    private TopSalesCategoryResponse topSales(String title, List<TopSalesCategoryResponse.TopSalesItem> items) {
        return TopSalesCategoryResponse.builder().title(title).items(items).build();
    }

    private TopSalesCategoryResponse.TopSalesItem item(String description, BigDecimal value) {
        return TopSalesCategoryResponse.TopSalesItem.builder()
                .description(description)
                .value(formatCurrency(value))
                .build();
    }

    private String formatCurrency(BigDecimal v) {
        BigDecimal value = v != null ? v : BigDecimal.ZERO;
        return "AED " + NumberFormat.getNumberInstance(Locale.US).format(value.setScale(2, RoundingMode.HALF_UP));
    }

    private String str(Object o) { return o != null ? o.toString() : ""; }

    private BigDecimal dec(Object o) {
        if (o == null) return BigDecimal.ZERO;
        if (o instanceof BigDecimal b) return b;
        if (o instanceof Number n) return BigDecimal.valueOf(n.doubleValue());
        try { return new BigDecimal(o.toString()); } catch (Exception e) { return BigDecimal.ZERO; }
    }
}
