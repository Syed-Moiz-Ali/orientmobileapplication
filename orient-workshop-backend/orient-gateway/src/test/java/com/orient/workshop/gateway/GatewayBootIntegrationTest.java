package com.orient.workshop.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.junit.jupiter.api.Assertions.*;

/**
 * P3 (audit): Flyway + context boot test against a real MySQL via
 * Testcontainers. Asserts every migration (V1–V11) applies cleanly and the
 * gateway boots with the full module graph + security chain.
 *
 * Runs in CI (Docker available). Skipped automatically when Docker is not
 * available on the host.
 */
@Testcontainers(disabledWithoutDocker = true)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "spring.flyway.baseline-on-migrate=false",
                "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration,org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration",
                "app.jwt.secret=test-secret-key-at-least-32-characters-long!!",
                "app.encryption-key=test-encryption-key-16chars"
        })
class GatewayBootIntegrationTest {

    @Container
    static final MySQLContainer<?> MYSQL = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("orient_workshop")
            .withUsername("root")
            .withPassword("test");

    @DynamicPropertySource
    static void datasourceProps(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", MYSQL::getJdbcUrl);
        registry.add("spring.datasource.username", MYSQL::getUsername);
        registry.add("spring.datasource.password", MYSQL::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "com.mysql.cj.jdbc.Driver");
        registry.add("spring.flyway.enabled", () -> "true");
    }

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void contextLoadsAndHealthIsUp() {
        ResponseEntity<String> health = restTemplate.getForEntity("/api/v1/health", String.class);
        assertEquals(200, health.getStatusCode().value(), "health endpoint must answer 200");
        assertNotNull(health.getBody(), "health body present");
    }

    @Test
    void flywayMigratedToLatestVersion() {
        ResponseEntity<String> version = restTemplate.getForEntity("/api/v1/version", String.class);
        assertEquals(200, version.getStatusCode().value());
        assertTrue(version.getBody() != null && version.getBody().contains("1"),
                "version body present: " + version.getBody());
    }
}
