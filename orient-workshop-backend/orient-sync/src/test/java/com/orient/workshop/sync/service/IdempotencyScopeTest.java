package com.orient.workshop.sync.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class IdempotencyScopeTest {
    private static final JwtUserPrincipal USER_A_BRANCH_1 = JwtUserPrincipal.builder()
            .userId(10L).branchId(1L).role("ADVISOR").build();
    private static final JwtUserPrincipal USER_B_BRANCH_1 = JwtUserPrincipal.builder()
            .userId(20L).branchId(1L).role("ADVISOR").build();
    private static final JwtUserPrincipal USER_A_BRANCH_2 = JwtUserPrincipal.builder()
            .userId(10L).branchId(2L).role("ADVISOR").build();

    @Test
    void sameUserEndpointBranchAndKeyProducesSameScope() {
        String first = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_1.getBranchId());
        String second = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_1.getBranchId());
        assertThat(second).isEqualTo(first);
    }

    @Test
    void differentUsersWithSameKeyDoNotCollide() {
        String first = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_1.getBranchId());
        String second = IdempotencyScope.scopedHash(USER_B_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_B_BRANCH_1.getBranchId());
        assertThat(second).isNotEqualTo(first);
    }

    @Test
    void differentEndpointsWithSameKeyDoNotCollide() {
        String first = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_1.getBranchId());
        String second = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/bookings", "abc", USER_A_BRANCH_1.getBranchId());
        assertThat(second).isNotEqualTo(first);
    }

    @Test
    void differentBranchesWithSameKeyDoNotCollide() {
        String first = IdempotencyScope.scopedHash(USER_A_BRANCH_1, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_1.getBranchId());
        String second = IdempotencyScope.scopedHash(USER_A_BRANCH_2, "POST",
                "/sync/repair-orders/RO-1", "abc", USER_A_BRANCH_2.getBranchId());
        assertThat(second).isNotEqualTo(first);
    }
}
