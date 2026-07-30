package com.orient.workshop.auth.filter;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data @Builder @AllArgsConstructor
public class JwtUserPrincipal {
    private Long userId;
    private String phone;
    private String role;
    private Long branchId;
}
