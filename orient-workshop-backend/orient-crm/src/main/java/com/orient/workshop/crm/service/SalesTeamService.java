package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.SalesTeamResponse;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SalesTeamService {

    private final LeadMapper leadMapper;

    public List<SalesTeamResponse> getSalesTeam() {
        Map<String, Long> handled = leadMapper.groupByAssignee().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));
        Map<String, Long> won = leadMapper.groupByAssigneeWon().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));
        return handled.entrySet().stream()
                .map(e -> {
                    String name = e.getKey();
                    long leads = e.getValue();
                    long wonLeads = won.getOrDefault(name, 0L);
                    double winRate = leads > 0 ? Math.round(wonLeads * 1000.0 / leads) / 10.0 : 0.0;
                    return SalesTeamResponse.builder()
                            .name(name)
                            .role("Sales")
                            .leadsHandled((int) leads)
                            .wonDeals((int) wonLeads)
                            .revenue("")
                            .winRate(winRate)
                            .build();
                })
                .collect(Collectors.toList());
    }

    private String str(Object o) { return o != null ? o.toString() : ""; }
    private long num(Object o) { return o instanceof Number n ? n.longValue() : 0L; }
}
