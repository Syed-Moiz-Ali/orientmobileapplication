package com.orient.workshop.owner.service;

import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.owner.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
@RequiredArgsConstructor
public class OwnerDashboardService {

    private final JobCardMapper jobCardMapper;

    public List<KpiCardResponse> getKpis() {
        int totalJobs = (int) jobCardMapper.countAll();
        int activeJobs = jobCardMapper.countOpen();
        int completedToday = jobCardMapper.countCompletedToday();

        return List.of(
            kpi("Active Jobs", String.valueOf(activeJobs), "+12 today"),
            kpi("New Jobs", "23", "Today"),
            kpi("Cancelled Jobs", "100", "Total"),
            kpi("Total Jobs", String.valueOf(totalJobs), "All time"),
            kpi("Total Sales", "AED 50K", "This month"),
            kpi("Total Purchases", "AED 30K", "This month"),
            kpi("Receivables", "AED 4K", "Overdue"),
            kpi("Payables", "AED 15K", "Due"),
            kpi("Total Profit", "AED 20K", "Net"),
            kpi("Total Cash", "AED 45K", "In hand"),
            kpi("Total Bank", "AED 30K", "In bank"),
            kpi("Inventory Value", "AED 85K", "Stock"),
            kpi("Commission", "AED 1,500", "Due"),
            kpi("Invoice Revenue", "AED 25K", "This month"),
            kpi("Parts Revenue", "AED 18K", "This month"),
            kpi("Labour Revenue", "AED 7K", "This month")
        );
    }

    public List<TrendPointResponse> getSalesTrend() {
        String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul"};
        long[] values = {45000,52000,48000,61000,55000,58000,50000};
        return trendData(months, values);
    }

    public List<TrendPointResponse> getProfitTrend() {
        String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul"};
        long[] values = {12000,15000,11000,18000,14000,16000,13000};
        return trendData(months, values);
    }

    public List<TrendPointResponse> getExpensesTrend() {
        String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul"};
        long[] values = {33000,37000,37000,43000,41000,42000,37000};
        return trendData(months, values);
    }

    public List<JobCardRegisterResponse> getJobCardRegister() {
        return List.of(
            register("Open", 45, 120),
            register("Check-In", 12, 89),
            register("Invoice Number", 8, 95),
            register("Invoice Service", 5, 78),
            register("Park Fee", 3, 112)
        );
    }

    public List<TopSalesCategoryResponse> getTopSales() {
        return List.of(
            topSales("Customer Wise", item(1,"ABC Motors","AED 125,000"), item(2,"Dubai Auto Services","AED 98,000")),
            topSales("Brand/Model Wise", item(1,"Toyota Camry","AED 45,000"), item(2,"BMW 3 Series","AED 38,000")),
            topSales("Advisor Wise", item(1,"John Smith","AED 65,000"), item(2,"Sarah Lee","AED 52,000")),
            topSales("Profit Wise", item(1,"Full Service","AED 28,000"), item(2,"Engine Repair","AED 22,000")),
            topSales("Sales Value Wise", item(1,"ABC Motors","AED 125,000"), item(2,"Dubai Auto Services","AED 98,000")),
            topSales("Spare Parts Profit Wise", item(1,"Brake Pads","AED 12,000"), item(2,"Oil Filters","AED 8,500")),
            topSales("Labour Profit Wise", item(1,"Engine Overhaul","AED 15,000"), item(2,"AC Repair","AED 11,000")),
            topSales("Department Wise", item(1,"Engine","AED 45,000"), item(2,"AC & Cooling","AED 32,000"))
        );
    }

    private KpiCardResponse kpi(String label, String value, String sub) {
        return KpiCardResponse.builder().label(label).value(value).sub(sub).build();
    }
    private List<TrendPointResponse> trendData(String[] months, long[] values) {
        return IntStream.range(0, months.length)
                .mapToObj(i -> TrendPointResponse.builder().month(months[i]).value(values[i]).build())
                .collect(Collectors.toList());
    }
    private JobCardRegisterResponse register(String label, int open, int completed) {
        return JobCardRegisterResponse.builder().label(label).open(open).completed(completed).total(open+completed).build();
    }
    private TopSalesCategoryResponse topSales(String title, TopSalesCategoryResponse.TopSalesItem... items) {
        return TopSalesCategoryResponse.builder().title(title).items(List.of(items)).build();
    }
    private TopSalesCategoryResponse.TopSalesItem item(int sno, String desc, String value) {
        return TopSalesCategoryResponse.TopSalesItem.builder().sno(sno).description(desc).value(value).build();
    }
}
