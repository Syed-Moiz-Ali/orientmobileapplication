package com.orient.workshop.crm.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.crm.model.dto.LeadResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MetaLeadFetcher {

    private static final String GRAPH_URL = "https://graph.facebook.com/v21.0";
    private static final String META = "META";

    private final IntegrationService integrationService;
    private final LeadService leadService;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Scheduled(fixedRateString = "${app.integration.meta.poll-interval-ms:600000}")
    public void scheduledSync() {
        try {
            if (integrationService.isConnected(META)) {
                sync(META);
            }
        } catch (Exception e) {
            log.warn("Scheduled Meta sync skipped: {}", e.getMessage());
        }
    }

    public void sync(String name) {
        Map<String, String> creds = integrationService.getCredentials(name);
        String pageId = creds.get("pageId");
        String accessToken = creds.get("accessToken");
        if (pageId == null || pageId.isBlank() || accessToken == null || accessToken.isBlank()) {
            throw new IllegalStateException("Meta credentials missing (pageId / accessToken)");
        }
        List<String> formIds = fetchLeadgenForms(pageId, accessToken);
        log.info("Meta: found {} leadgen forms for page {}", formIds.size(), pageId);
        for (String formId : formIds) {
            try {
                fetchAndStoreLeads(formId, accessToken);
            } catch (Exception e) {
                log.warn("Meta: failed to fetch leads for form {}: {}", formId, e.getMessage());
            }
        }
    }

    private List<String> fetchLeadgenForms(String pageId, String token) {
        // P2 (audit): follow paging cursors — only the first 100 forms were read.
        List<String> ids = new ArrayList<>();
        String url = GRAPH_URL + "/" + pageId + "/leadgen_forms?limit=100";
        int pages = 0;
        while (url != null && pages < 10) {
            try {
                ResponseEntity<String> resp = restTemplate.exchange(url, org.springframework.http.HttpMethod.GET,
                        authedEntity(token), String.class);
                JsonNode root = objectMapper.readTree(resp.getBody());
                JsonNode data = root.path("data");
                for (JsonNode n : data) {
                    String id = n.path("id").asText("");
                    if (!id.isEmpty()) ids.add(id);
                }
                url = nextPageUrl(root);
                pages++;
            } catch (Exception e) {
                log.error("Meta: failed to fetch leadgen forms: {}", e.getMessage());
                break;
            }
        }
        return ids;
    }

    private void fetchAndStoreLeads(String formId, String token) {
        // P2 (audit): follow paging cursors — leads beyond the first 200 were
        // silently dropped. Also uses the Authorization header instead of a
        // query-string token (token leaked into logs/proxies before).
        String url = GRAPH_URL + "/" + formId + "/leads?limit=200";
        int pages = 0;
        int stored = 0;
        while (url != null && pages < 20) {
            try {
                ResponseEntity<String> resp = restTemplate.exchange(url, org.springframework.http.HttpMethod.GET,
                        authedEntity(token), String.class);
                JsonNode root = objectMapper.readTree(resp.getBody());
                JsonNode data = root.path("data");
                for (JsonNode n : data) {
                    String externalId = n.path("id").asText("");
                    if (externalId.isEmpty()) continue;
                    LeadResponse lead = mapLead(n);
                    leadService.upsertByExternalId(externalId, lead);
                    stored++;
                }
                url = nextPageUrl(root);
                pages++;
            } catch (Exception e) {
                log.error("Meta: failed to fetch leads for form {}: {}", formId, e.getMessage());
                break;
            }
        }
        log.info("Meta: stored {} leads from form {} ({} page(s))", stored, formId, pages);
    }

    /**
     * P2 (audit): bearer token in the Authorization header — it was previously
     * placed in the URL query string where proxies/access-logs could leak it.
     */
    private org.springframework.http.HttpEntity<Void> authedEntity(String token) {
        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.setBearerAuth(token);
        return new org.springframework.http.HttpEntity<>(headers);
    }

    /**
     * P2: extracts the next paging URL from a Graph API response.
     */
    private String nextPageUrl(JsonNode root) {
        JsonNode paging = root.path("paging");
        JsonNode next = paging.path("next");
        return next.isMissingNode() || next.isNull() ? null : next.asText();
    }

    private LeadResponse mapLead(JsonNode n) {
        String fullName = "";
        String email = "";
        String phone = "";
        String created = n.path("created_time").asText("");
        JsonNode fieldData = n.path("field_data");
        for (JsonNode f : fieldData) {
            String fieldName = f.path("name").asText("").toLowerCase();
            List<String> values = new ArrayList<>();
            for (JsonNode v : f.path("values")) {
                values.add(v.asText(""));
            }
            String value = values.isEmpty() ? "" : String.join(", ", values);
            if (fieldName.contains("email")) email = value;
            else if (fieldName.contains("phone")) phone = value;
            else if (fieldName.contains("name")) fullName = value;
        }
        if (fullName.isEmpty()) fullName = n.path("full_name").asText("");
        if (email.isEmpty()) email = n.path("email").asText("");
        if (phone.isEmpty()) phone = n.path("phone_number").asText("");

        String activity = created.isEmpty() ? "Just now" : created;
        return LeadResponse.builder()
                .customerName(fullName.isEmpty() ? "Unknown Lead" : fullName)
                .phone(phone)
                .email(email)
                .source(META)
                .assignedTo("")
                .status("ACTIVE")
                .lastActivity(activity)
                .build();
    }
}
