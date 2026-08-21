package com.orient.workshop.common.context;

/**
 * Thread-local tenant (branch) context. Populated by JwtAuthenticationFilter from the
 * authenticated user's branch claim and consumed by the MyBatis Plus tenant interceptor
 * so every qualified query is automatically scoped to the caller's branch.
 *
 * <p>Null branchId = super-user global view (owner/admin/crmDashboard with no single
 * branch, or unassigned principals). The interceptor adds no tenant clause in that case.
 */
public final class BranchContext {

    private static final ThreadLocal<Long> BRANCH_ID = new ThreadLocal<>();

    private BranchContext() {}

    public static void set(Long branchId) {
        BRANCH_ID.set(branchId);
    }

    public static Long get() {
        return BRANCH_ID.get();
    }

    /** True when the current user has no branch scope and may see across branches. */
    public static boolean isGlobal() {
        return BRANCH_ID.get() == null;
    }

    public static void clear() {
        BRANCH_ID.remove();
    }
}
