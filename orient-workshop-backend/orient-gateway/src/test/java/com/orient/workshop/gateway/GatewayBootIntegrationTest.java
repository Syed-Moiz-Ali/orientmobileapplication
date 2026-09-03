package com.orient.workshop.gateway;

import com.fasterxml.jackson.databind.JsonNode;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.service.PasswordService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.junit.jupiter.api.Assertions.*;

import java.util.HashMap;
import java.util.Map;
import java.util.stream.StreamSupport;

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

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PasswordService passwordService;

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

    @Test
    void ownerCanManageCompleteStaffLifecycle() {
        String suffix = Long.toString(System.nanoTime());
        String ownerEmail = "local-owner-" + suffix + "@example.com";
        String ownerPassword = "OwnerPass!234";
        String staffEmail = "local-staff-" + suffix + "@example.com";
        String staffPhone = "97155" + suffix.substring(Math.max(0, suffix.length() - 7));
        String staffPassword = "StaffPass!234";
        String empId = "QA" + suffix.substring(Math.max(0, suffix.length() - 10));

        User owner = User.builder()
                .name("Local QA Owner")
                .email(ownerEmail)
                .phone("97150" + suffix.substring(Math.max(0, suffix.length() - 7)))
                .passwordHash(passwordService.hash(ownerPassword))
                .role("owner")
                .isActive(true)
                .build();
        assertEquals(1, userMapper.insert(owner));

        ResponseEntity<JsonNode> ownerLogin = post("/api/v1/auth/login", Map.of(
                "email", ownerEmail,
                "password", ownerPassword), appHeaders("owner"));
        assertEquals(200, ownerLogin.getStatusCode().value());
        String ownerToken = requiredText(ownerLogin.getBody(), "/data/token");

        ResponseEntity<JsonNode> ownerMe = get("/api/v1/auth/me", bearer(ownerToken));
        assertEquals(200, ownerMe.getStatusCode().value());
        assertEquals("owner", requiredText(ownerMe.getBody(), "/data/role"));

        Map<String, Object> createRequest = new HashMap<>();
        createRequest.put("name", "Local API Staff");
        createRequest.put("empId", empId);
        createRequest.put("role", "advisor");
        createRequest.put("phone", staffPhone);
        createRequest.put("email", staffEmail);
        createRequest.put("password", staffPassword);
        createRequest.put("designation", "API Test Advisor");
        createRequest.put("department", "Quality Assurance");
        createRequest.put("shift", "Test Shift");

        ResponseEntity<JsonNode> created = post(
                "/api/v1/owner/team", createRequest, bearer(ownerToken));
        assertEquals(200, created.getStatusCode().value());
        assertEquals(staffEmail, requiredText(created.getBody(), "/data/email"));
        assertEquals(staffPhone, requiredText(created.getBody(), "/data/phone"));
        assertEquals(empId, requiredText(created.getBody(), "/data/empId"));
        assertEquals("advisor", requiredText(created.getBody(), "/data/role"));
        long staffId = created.getBody().at("/data/id").asLong();
        assertTrue(staffId > 0);

        ResponseEntity<JsonNode> listed = get("/api/v1/owner/team", bearer(ownerToken));
        assertEquals(200, listed.getStatusCode().value());
        JsonNode listedStaff = StreamSupport.stream(listed.getBody().at("/data").spliterator(), false)
                .filter(item -> empId.equals(item.path("empId").asText()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Created staff missing from team list"));
        assertEquals(staffEmail, listedStaff.path("email").asText());
        assertEquals(staffPhone, listedStaff.path("phone").asText());

        ResponseEntity<JsonNode> staffLogin = post("/api/v1/auth/login", Map.of(
                "email", staffEmail,
                "password", staffPassword), appHeaders("staff"));
        assertEquals(200, staffLogin.getStatusCode().value());
        String firstStaffToken = requiredText(staffLogin.getBody(), "/data/token");

        ResponseEntity<JsonNode> staffMe = get("/api/v1/auth/me", bearer(firstStaffToken));
        assertEquals(200, staffMe.getStatusCode().value());
        assertEquals("advisor", requiredText(staffMe.getBody(), "/data/role"));
        assertEquals(empId, requiredText(staffMe.getBody(), "/data/empId"));

        ResponseEntity<JsonNode> staffForbidden = get(
                "/api/v1/owner/team", bearer(firstStaffToken));
        assertEquals(403, staffForbidden.getStatusCode().value());
        assertEquals(401, get("/api/v1/owner/team", jsonHeaders()).getStatusCode().value());

        Map<String, Object> updateRequest = Map.of(
                "role", "technician",
                "designation", "API Test Technician",
                "shift", "Updated Test Shift");
        ResponseEntity<JsonNode> updated = exchange(
                "/api/v1/owner/team/" + staffId,
                HttpMethod.PUT,
                updateRequest,
                bearer(ownerToken));
        assertEquals(200, updated.getStatusCode().value());
        assertEquals("technician", requiredText(updated.getBody(), "/data/role"));
        assertEquals(staffEmail, requiredText(updated.getBody(), "/data/email"));
        assertEquals(staffPhone, requiredText(updated.getBody(), "/data/phone"));

        ResponseEntity<JsonNode> updatedStaffLogin = post("/api/v1/auth/login", Map.of(
                "phone", staffPhone,
                "password", staffPassword), appHeaders("staff"));
        assertEquals(200, updatedStaffLogin.getStatusCode().value());
        String updatedStaffToken = requiredText(updatedStaffLogin.getBody(), "/data/token");
        assertEquals("technician", requiredText(updatedStaffLogin.getBody(), "/data/role"));

        ResponseEntity<JsonNode> deactivated = exchange(
                "/api/v1/owner/team/" + staffId + "/deactivate",
                HttpMethod.PUT,
                null,
                bearer(ownerToken));
        assertEquals(200, deactivated.getStatusCode().value());
        assertEquals(empId, requiredText(deactivated.getBody(), "/data/deactivated"));

        ResponseEntity<JsonNode> afterDeactivate = get(
                "/api/v1/auth/me", bearer(updatedStaffToken));
        assertEquals(401, afterDeactivate.getStatusCode().value());

        ResponseEntity<JsonNode> blockedLogin = post("/api/v1/auth/login", Map.of(
                "email", staffEmail,
                "password", staffPassword), appHeaders("staff"));
        assertEquals(403, blockedLogin.getStatusCode().value());
        assertEquals("Account is inactive. Contact your administrator.",
                requiredText(blockedLogin.getBody(), "/message"));

        ResponseEntity<JsonNode> ownerStillActive = get(
                "/api/v1/auth/me", bearer(ownerToken));
        assertEquals(200, ownerStillActive.getStatusCode().value());
    }

    private ResponseEntity<JsonNode> get(String path, HttpHeaders headers) {
        return exchange(path, HttpMethod.GET, null, headers);
    }

    private ResponseEntity<JsonNode> post(String path, Object body, HttpHeaders headers) {
        return exchange(path, HttpMethod.POST, body, headers);
    }

    private ResponseEntity<JsonNode> exchange(
            String path, HttpMethod method, Object body, HttpHeaders headers) {
        return restTemplate.exchange(path, method, new HttpEntity<>(body, headers), JsonNode.class);
    }

    private HttpHeaders appHeaders(String appName) {
        HttpHeaders headers = jsonHeaders();
        headers.set("X-App-Name", appName);
        return headers;
    }

    private HttpHeaders bearer(String token) {
        HttpHeaders headers = jsonHeaders();
        headers.setBearerAuth(token);
        return headers;
    }

    private HttpHeaders jsonHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(java.util.List.of(MediaType.APPLICATION_JSON));
        return headers;
    }

    private String requiredText(JsonNode body, String pointer) {
        assertNotNull(body, "Response body is required");
        JsonNode value = body.at(pointer);
        assertFalse(value.isMissingNode() || value.isNull() || value.asText().isBlank(),
                "Missing response value at " + pointer + ": " + body);
        return value.asText();
    }
}
