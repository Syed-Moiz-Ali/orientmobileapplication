package com.orient.workshop.crm.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.crm.model.dto.TeamMemberResponse;
import com.orient.workshop.crm.repository.LeadMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamService {

    private final StaffMapper staffMapper;
    private final LeadMapper leadMapper;

    public List<TeamMemberResponse> getTeamMembers() {
        List<Staff> staff = staffMapper.selectList(
                new QueryWrapper<Staff>().eq("is_active", true)
                        .and(w -> w.like("role", "sales").or().eq("role", "advisor").or().eq("role", "supervisor")));

        Map<String, Long> handled = leadMapper.groupByAssignee().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));
        Map<String, Long> won = leadMapper.groupByAssigneeWon().stream()
                .collect(Collectors.toMap(r -> str(r.get("name")), r -> num(r.get("cnt"))));

        return staff.stream()
                .map(s -> TeamMemberResponse.builder()
                        .name(s.getName())
                        .role(s.getRole())
                        .designation(s.getDesignation() != null ? s.getDesignation() : "")
                        .leadsHandled(handled.getOrDefault(s.getName(), 0L).intValue())
                        .wonDeals(won.getOrDefault(s.getName(), 0L).intValue())
                        .build())
                .collect(Collectors.toList());
    }

    private String str(Object o) { return o != null ? o.toString() : ""; }
    private long num(Object o) { return o instanceof Number n ? n.longValue() : 0L; }
}
