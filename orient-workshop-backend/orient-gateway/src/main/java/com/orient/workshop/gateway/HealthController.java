package com.orient.workshop.gateway;

import com.orient.workshop.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

@Tag(name = "System")
@RestController
@RequiredArgsConstructor
public class HealthController {

    private final DataSource dataSource;
    private final ObjectProvider<RedisConnectionFactory> redisFactoryProvider;

    /**
     * Real liveness/readiness: pings the DataSource (SELECT 1) and Redis when
     * present. Returns 503 with status DOWN when any required dependency fails.
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Map<String, Object>>> health() {
        Map<String, Object> details = new LinkedHashMap<>();
        boolean up = true;

        try (Connection conn = dataSource.getConnection();
             Statement st = conn.createStatement()) {
            st.execute("SELECT 1");
            details.put("database", "UP");
        } catch (Exception e) {
            details.put("database", "DOWN");
            up = false;
        }

        RedisConnectionFactory redisFactory = redisFactoryProvider.getIfAvailable();
        if (redisFactory != null) {
            try (RedisConnection conn = redisFactory.getConnection()) {
                conn.ping();
                details.put("redis", "UP");
            } catch (Exception e) {
                details.put("redis", "DOWN");
                up = false;
            }
        }

        details.put("status", up ? "UP" : "DOWN");
        details.put("service", "orient-workshop-backend");
        details.put("version", "1.0.0-SNAPSHOT");

        if (!up) {
            return ResponseEntity
                    .status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error(503, "Service unhealthy", details));
        }
        return ResponseEntity.ok(ApiResponse.success(details));
    }
}
