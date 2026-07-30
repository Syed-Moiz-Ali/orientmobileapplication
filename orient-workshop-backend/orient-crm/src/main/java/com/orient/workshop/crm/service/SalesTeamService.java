package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.SalesTeamResponse;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SalesTeamService {

    public List<SalesTeamResponse> getSalesTeam() {
        return List.of(
            team("Ahmed Al Maktoum", "Senior Sales", 85, 32, "AED 125,000", 37.6),
            team("Fatima Hassan", "Sales Executive", 72, 28, "AED 98,000", 38.9),
            team("Khalid Ali", "Junior Sales", 45, 15, "AED 52,000", 33.3)
        );
    }

    private SalesTeamResponse team(String name, String role, int leads, int won, String revenue, double winRate) {
        return SalesTeamResponse.builder().name(name).role(role).leadsHandled(leads).wonDeals(won).revenue(revenue).winRate(winRate).build();
    }
}
