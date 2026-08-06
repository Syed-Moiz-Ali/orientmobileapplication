package com.orient.workshop.auth.filter;

import com.orient.workshop.core.model.entity.ApiKey;
import com.orient.workshop.core.repository.ApiKeyMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Optional;

/**
 * P3 (audit): server-to-server API keys. When the X-API-Key header is present,
 * the key is hashed and validated against api_keys; a successful match
 * authenticates as an ApiKeyPrincipal with the key's role (owner scope by
 * default). The JWT filter then falls through untouched.
 * Excluded for /auth/** — login endpoints must never accept API keys.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ApiKeyFilter extends OncePerRequestFilter {

    private final ApiKeyMapper apiKeyMapper;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return request.getRequestURI().contains("/auth/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String apiKey = request.getHeader("X-API-Key");
        if (apiKey == null || apiKey.isBlank() || SecurityContextHolder.getContext().getAuthentication() != null) {
            filterChain.doFilter(request, response);
            return;
        }
        try {
            Optional<ApiKey> match = apiKeyMapper.findByHash(hash(apiKey));
            if (match.isPresent() && Boolean.TRUE.equals(match.get().getIsActive())) {
                ApiKey key = match.get();
                apiKeyMapper.touch(key.getId());
                String role = key.getRole() != null && !key.getRole().isBlank() ? key.getRole() : "owner";
                ApiKeyPrincipal principal = ApiKeyPrincipal.builder()
                        .keyId(key.getId())
                        .name(key.getName())
                        .role(role)
                        .build();
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(principal, null,
                                List.of(new SimpleGrantedAuthority("ROLE_" + role.toUpperCase())));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } else {
                log.warn("API key rejected: prefix {}", apiKey.length() > 12 ? apiKey.substring(0, 12) : "?");
            }
        } catch (Exception e) {
            log.warn("API key validation failed: {}", e.getMessage());
        }
        filterChain.doFilter(request, response);
    }

    public static String hash(String raw) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(Character.forDigit((b >> 4) & 0xF, 16));
                sb.append(Character.forDigit(b & 0xF, 16));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
