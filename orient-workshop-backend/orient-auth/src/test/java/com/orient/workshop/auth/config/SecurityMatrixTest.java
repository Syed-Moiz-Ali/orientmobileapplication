package com.orient.workshop.auth.config;

import com.orient.workshop.auth.filter.JwtAuthenticationFilter;
import com.orient.workshop.auth.filter.RateLimitFilter;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.util.JwtUtil;
import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * S-1 regression suite: the RBAC matrix must keep the documented path/role
 * rules. Every controller-level path is exercised here as a matcher contract
 * (no controllers are loaded — a passing matcher yields 404, a denied request
 * yields 401/403, which is what we assert).
 */
@WebMvcTest
@ContextConfiguration(classes = SecurityConfig.class)
@Import(SecurityConfig.class)
class SecurityMatrixTest {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mockMvc;

    @MockBean
    private JwtUtil jwtUtil;
    @MockBean
    private UserMapper userMapper;
    // The real JwtAuthenticationFilter is mocked so the chain passes through
    // (no DB access); the RateLimitFilter bean from SecurityConfig is real —
    // a mocked filter would swallow the chain and return empty 200s.
    @MockBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @BeforeEach
    void setUp() throws Exception {
        mockMvc = MockMvcBuilders.webAppContextSetup(context)
                .apply(springSecurity())
                .build();
        // The mocked JWT filter must pass the request through the chain so the
        // authorization rules (and this test's role post-processors) run.
        doAnswer(invocation -> {
            invocation.getArgument(2, FilterChain.class)
                    .doFilter(invocation.getArgument(0), invocation.getArgument(1));
            return null;
        }).when(jwtAuthenticationFilter).doFilter(any(), any(), any());
    }

    // ---------- permitAll ----------

    @Test
    void authEndpointsArePermitAll() throws Exception {
        mockMvc.perform(post("/auth/send-otp"))
                .andExpect(status().isNotFound()); // passes security, no controller
    }

    @Test
    void healthIsPermitAll() throws Exception {
        mockMvc.perform(get("/health")).andExpect(status().isNotFound());
    }

    // ---------- unauthenticated -> 401 ----------

    @Test
    void syncRequiresAuthentication() throws Exception {
        mockMvc.perform(post("/sync/inspections/1")).andExpect(status().isUnauthorized());
    }

    @Test
    void branchesRequireAuthentication() throws Exception {
        mockMvc.perform(post("/branches")).andExpect(status().isUnauthorized());
    }

    @Test
    void customersRequireAuthentication() throws Exception {
        mockMvc.perform(get("/customers/profile")).andExpect(status().isUnauthorized());
    }

    @Test
    void inspectionsRequireAuthentication() throws Exception {
        mockMvc.perform(post("/inspections")).andExpect(status().isUnauthorized());
    }

    @Test
    void repairOrdersRequireAuthentication() throws Exception {
        mockMvc.perform(post("/repair-orders")).andExpect(status().isUnauthorized());
    }

    @Test
    void ownerRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/owner/dashboard/kpis")).andExpect(status().isUnauthorized());
    }

    // ---------- CUSTOMER role ----------

    @Test
    void customerCanAccessCustomerPortal() throws Exception {
        mockMvc.perform(get("/customers/profile").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isNotFound()); // matcher passes
    }

    @Test
    void customerCannotManageBranches() throws Exception {
        mockMvc.perform(post("/branches").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    @Test
    void customerCannotCallSync() throws Exception {
        mockMvc.perform(post("/sync/inspections/1").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    @Test
    void customerCannotCreateInspections() throws Exception {
        mockMvc.perform(post("/inspections").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    @Test
    void customerCannotAccessOwnerDashboard() throws Exception {
        mockMvc.perform(get("/owner/dashboard/kpis").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    @Test
    void customerCannotSearchPii() throws Exception {
        mockMvc.perform(get("/customers/search").with(user("u").roles("CUSTOMER")))
                .andExpect(status().isForbidden());
    }

    // ---------- staff roles ----------

    @Test
    void advisorCanAccessCustomerSearch() throws Exception {
        mockMvc.perform(get("/customers/search").with(user("u").roles("ADVISOR")))
                .andExpect(status().isNotFound());
    }

    @Test
    void technicianCanAccessSync() throws Exception {
        mockMvc.perform(post("/sync/inspections/1").with(user("u").roles("TECHNICIAN")))
                .andExpect(status().isNotFound());
    }

    @Test
    void technicianCannotAccessOwnerDashboard() throws Exception {
        mockMvc.perform(get("/owner/dashboard/kpis").with(user("u").roles("TECHNICIAN")))
                .andExpect(status().isForbidden());
    }

    @Test
    void advisorCannotManageBranches() throws Exception {
        mockMvc.perform(post("/branches").with(user("u").roles("ADVISOR")))
                .andExpect(status().isForbidden());
    }

    // ---------- OWNER role ----------

    @Test
    void ownerCanAccessBranchesAndSyncAndOwner() throws Exception {
        mockMvc.perform(post("/branches").with(user("u").roles("OWNER")))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/sync/inspections/1").with(user("u").roles("OWNER")))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/owner/dashboard/kpis").with(user("u").roles("OWNER")))
                .andExpect(status().isNotFound());
    }

    @Test
    void ownerCanManageBranches() throws Exception {
        mockMvc.perform(post("/branches").with(user("u").roles("OWNER")))
                .andExpect(status().isNotFound());
    }
}
