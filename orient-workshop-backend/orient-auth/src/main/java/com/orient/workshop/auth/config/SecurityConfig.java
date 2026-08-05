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
 * /owner/**                       OWNER, ADMIN
 * /supervisor/**                  SUPERVISOR, OWNER, ADMIN
 * /technicians/**                 TECHNICIAN, SUPERVISOR, OWNER, ADMIN
 * /advisor/**                     ADVISOR, SUPERVISOR, OWNER, ADMIN
 * /crm/**                         CRM_DASHBOARD, OWNER, ADMIN
 * /customer/**                    CUSTOMER, ADVISOR, OWNER, ADMIN
 * /sync/**                        any authenticated user
 * /media/**                       any authenticated user
 * everything else                 any authenticated user
 * </pre>
 *
 * The remaining role-gated prefixes (e.g. /branches, /inspections, /repair-orders,
 * /bookings, /feedback) are owned by other modules; per-module ownership enforcement
 * can be layered on top with {@code @PreAuthorize} (method security is enabled below).
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
                        .requestMatchers("/swagger-ui.html", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
                        .requestMatchers("/health", "/actuator/health", "/version").permitAll()
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/whatsapp/webhook").permitAll()
                        .requestMatchers(HttpMethod.POST, "/whatsapp/webhook").permitAll()
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
                        .requestMatchers("/crm/**")
                        .hasAnyRole(role(RoleConstants.CRM_DASHBOARD), role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/customer/**")
                        .hasAnyRole(role(RoleConstants.CUSTOMER), role(RoleConstants.ADVISOR),
                                role(RoleConstants.OWNER), role(RoleConstants.ADMIN))
                        .requestMatchers("/sync/**", "/media/**").authenticated()
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
