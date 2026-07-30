package com.orient.workshop.common.constant;

public final class RoleConstants {

    private RoleConstants() {}

    public static final String OWNER = "owner";
    public static final String ADVISOR = "advisor";
    public static final String TECHNICIAN = "technician";
    public static final String CUSTOMER = "customer";
    public static final String SUPERVISOR = "supervisor";
    public static final String CRM_DASHBOARD = "crmDashboard";

    public static final String[] ALL_ROLES = {
            OWNER, ADVISOR, TECHNICIAN, CUSTOMER, SUPERVISOR, CRM_DASHBOARD
    };
}
