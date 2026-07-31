package com.orient.workshop.crm.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class TeamMemberResponse {
    private String name;
    private String role;
    private String designation;
    private int leadsHandled;
    private int wonDeals;
}
