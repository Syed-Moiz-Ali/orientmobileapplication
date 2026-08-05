package com.orient.workshop.auth.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.util.JwtUtil;
import com.orient.workshop.common.constant.ApiConstants;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String token = extractToken(request);

        if (token != null && jwtUtil.validateToken(token)) {
            try {
                Long userId = jwtUtil.getUserIdFromToken(token);
                String role = jwtUtil.getRoleFromToken(token);
                String phone = jwtUtil.getPhoneFromToken(token);

                // H-3: always re-check the user against the DB so deactivated users and
                // stale roles are rejected immediately (single query per request).
                User user = userMapper.selectById(userId);
                if (user == null || !Boolean.TRUE.equals(user.getIsActive())
                        || role == null || !role.equalsIgnoreCase(user.getRole())) {
                    SecurityContextHolder.clearContext();
                    sendUnauthorized(response);
                    return;
                }

                List<SimpleGrantedAuthority> authorities = List.of(
                        new SimpleGrantedAuthority("ROLE_" + role.toUpperCase())
                );

                Long branchId = jwtUtil.getBranchIdFromToken(token);
                JwtUserPrincipal principal = JwtUserPrincipal.builder()
                        .userId(userId).phone(phone).role(role).branchId(branchId)
                        .build();

                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(principal, null, authorities);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } catch (Exception e) {
                log.warn("Failed to parse JWT: {}", e.getMessage());
                SecurityContextHolder.clearContext();
                sendUnauthorized(response);
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private void sendUnauthorized(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        Map<String, Object> body = new java.util.LinkedHashMap<>();
        body.put("code", 401);
        body.put("message", "Unauthorized");
        body.put("timestamp", System.currentTimeMillis());
        response.getWriter().write(objectMapper.writeValueAsString(body));
    }

    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader(ApiConstants.AUTH_HEADER);
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(ApiConstants.BEARER_PREFIX)) {
            return bearerToken.substring(ApiConstants.BEARER_PREFIX.length());
        }
        return null;
    }
}
