package com.orient.workshop.gateway;

import com.orient.workshop.common.api.ApiVersionInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Registers the API version negotiation interceptor for every request.
 * The URL version itself comes from server.servlet.context-path
 * (default /api/v1, overridable via API_CONTEXT_PATH).
 */
@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private final ApiVersionInterceptor apiVersionInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(apiVersionInterceptor);
    }
}
