package com.orient.workshop.auth.config;

import com.orient.workshop.auth.filter.JwtAuthenticationFilter;
import com.orient.workshop.auth.filter.RateLimitFilter;
import com.orient.workshop.common.constant.RoleConstants;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Security configuration.
 *
 * Authorization matrix (role names are matched as ROLE_&lt;ROLE&gt; authorities set by
 * JwtAuthenticationFilter; see RoleConstants for the canonical role names):
 *
 * <pre>
 * Path                            Roles allowed
 * ----------------------------------------------------------------
 * /auth/**                        permitAll (login/register/otp/refresh/reset)
 * /swagger-ui/**, /v3/api-docs/** permitAll (API docs)
 * /health, /actuator/health       permitAll (liveness/readiness probes)
 * /version                        permitAll (API version metadata)
 * OPTIONS /**                     permitAll (CORS preflight)
 * GET|POST /whatsapp/webhook      permitAll (Meta webhook; signature verified by handler)
 * /customers/search, /vehicles/search  ADVISOR, SUPERVISOR, OWNER, ADMIN (PII search)
 * /customers/**                   CUSTOMER, ADVISOR, SUPERVISOR, OWNER, ADMIN
 * /technician/** (singular)       TECHNICIAN, SUPERVISOR, OWNER, ADMIN
 * /branches/**                    OWNER, ADMIN
 * /inspections/**, /repair-orders/**  ADVISOR, SUPERVISOR, OWNER, ADMIN
 * /bookings/**, /services/types, /feedback/**  CUSTOMER + staff
 * /work-assignments, /jobs/complete, /departments  TECHNICIAN, SUPERVISOR, OWNER, ADMIN
 * /sync/**                        ADVISOR, SUPERVISOR, TECHNICIAN, OWNER, ADMIN (staff only)
 * /whatsapp/send, /whatsapp/messages  ADVISOR, SUPERVISOR, OWNER, ADMIN
 * /owner/**                       OWNER, ADMIN
 * /supervisor/**                  SUPERVISOR, OWNER, ADMIN
 * /technicians/**                 TECHNICIAN, SUPERVISOR, OWNER, ADMIN
 * /advisor/**                     ADVISOR, SUPERVISOR, OWNER, ADMIN
 * /staff/**                       all staff roles
 * /crm/**                         CRM_DASHBOARD, OWNER, ADMIN
 * /customer/** (singular legacy)  CUSTOMER, ADVISOR, OWNER, ADMIN
 * /media/**, /notifications/**    any authenticated user
 * everything else                 any authenticated user
 * </pre>
 *
 * S-1: this matrix is the primary authorization gate. Method security is
 * enabled so per-controller {@code @PreAuthorize} can be layered on top for
 * object-level rules (e.g. feedback moderation).
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * H-2: RateLimitFilter is deliberately NOT a {@code @Component} (avoids double
     * registration as a servlet-context filter). It is created here and registered
     * exactly once, inside the security chain via addFilterBefore.
     */
    @Bean
    public RateLimitFilter rateLimitFilter(
            @Value("${app.rate-limit.capacity:100}") int capacity,
            @Value("${app.rate-limit.refill-period-minutes:1}") int refillPeriodMinutes,
            @Value("${app.rate-limit.auth-capacity:20}") int authCapacity) {
        return new RateLimitFilter(capacity, refillPeriodMinutes, authCapacity);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, RateLimitFilter rateLimitFilter) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .headers(headers -> headers
                        .httpStrictTransportSecurity(hsts -> hsts.maxAgeInSeconds(31536000).includeSubDomains(true))
                        .frameOptions(frame -> frame.deny())
                        .addHeaderWriter((req, res) -> {
                            res.setHeader("X-Content-Type-Options", "nosniff");
                            res.setHeader("X-XSS-Protection", "1; mode=block");
                            res.setHeader("Cache-Control", "no-store");
                            res.setHeader("Content-Security-Policy", "default-src 'self'");
                        }))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/auth/**").permitAll()
                        // FIX (audit): the container error dispatch must not be
                        // re-authorized — previously a denied request's error page
                        // request itself hit anyRequest().authenticated() and the
                        // client saw 401 instead of the real 403.
                        .requestMatchers("/error").permitAll()
                        .requestMatchers("/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
                        .requestMatchers("/health", "/actuator/health", "/version").permitAll()
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/whatsapp/webhook").permitAll()
                        .requestMatchers(HttpMethod.POST, "/whatsapp/webhook").permitAll()
                        // S-1: customer/vehicle PII search is staff-only (advisor intake,
                        // supervisor dispatch, owner lookup). Must precede the broad rules.
                        .requestMatchers("/customers/search", "/vehicles/search")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        // S-1: plural /customers/** (all customer controllers) and singular
                        // /technician/** (parts requests / escalations) previously fell through
                        // to "any authenticated" because the matrix only listed singular
                        // /customer/** and plural /technicians/**.
                        .requestMatchers("/customers/**")
                        .hasAnyRole(role(RoleConstants.CUSTOMER), role(RoleConstants.ADVISOR),
                                role(RoleConstants.SUPERVISOR), role(RoleConstants.OWNER),
                                role(RoleConstants.ADMIN))
                        .requestMatchers("/technician/**")
                        .hasAnyRole(role(RoleConstants.TECHNICIAN), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        // S-4: branch (org topology) management is OWNER/ADMIN only.
                        .requestMatchers("/branches/**")
                        .hasAnyRole(role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        // S-1: core workshop workflow surfaces are staff-only.
                        .requestMatchers("/inspections/**", "/repair-orders/**")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/bookings/**", "/services/types", "/feedback/**")
                        .hasAnyRole(role(RoleConstants.CUSTOMER), role(RoleConstants.ADVISOR),
                                role(RoleConstants.SUPERVISOR), role(RoleConstants.OWNER),
                                role(RoleConstants.ADMIN))
                        .requestMatchers("/work-assignments", "/jobs/complete", "/departments")
                        .hasAnyRole(role(RoleConstants.TECHNICIAN), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        // S-5: /sync/** mutates job cards and inspections — staff only,
                        // never customers (was any-authenticated).
                        .requestMatchers("/sync/**")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.TECHNICIAN), role(RoleConstants.OWNER),
                                role(RoleConstants.ADMIN))
                        // WhatsApp business-initiated sends and history are staff-only;
                        // the signature-verified webhook remains permitAll (handled above).
                        .requestMatchers("/whatsapp/send", "/whatsapp/messages")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/owner/**")
                        .hasAnyRole(role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/supervisor/**")
                        .hasAnyRole(role(RoleConstants.SUPERVISOR), role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/technicians/**")
                        .hasAnyRole(role(RoleConstants.TECHNICIAN), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/advisor/**")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/staff/**")
                        .hasAnyRole(role(RoleConstants.ADVISOR), role(RoleConstants.SUPERVISOR),
                                role(RoleConstants.TECHNICIAN), role(RoleConstants.OWNER),
                                role(RoleConstants.ADMIN))
                        .requestMatchers("/crm/**")
                        .hasAnyRole(role(RoleConstants.CRM_DASHBOARD), role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/customer/**")
                        .hasAnyRole(role(RoleConstants.CUSTOMER), role(RoleConstants.ADVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/media/**", "/notifications/**").authenticated()
                        .anyRequest().authenticated()
                )
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint((request, response, authException) ->
                                response.sendError(jakarta.servlet.http.HttpServletResponse.SC_UNAUTHORIZED))
                        // Authenticated but insufficient role -> 403 (not 401).
                        .accessDeniedHandler((request, response, accessDeniedException) ->
                                response.sendError(jakarta.servlet.http.HttpServletResponse.SC_FORBIDDEN))
                )
                .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    private static String role(String role) {
        return role.toUpperCase();
    }
}
