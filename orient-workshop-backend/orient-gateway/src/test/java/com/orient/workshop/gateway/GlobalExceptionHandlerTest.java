package com.orient.workshop.gateway;

import com.orient.workshop.common.exception.GlobalExceptionHandler;
import com.orient.workshop.common.response.ApiResponse;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void wrongHttpMethodReturnsFriendly405WithAllowedMethods() {
        HttpRequestMethodNotSupportedException exception =
                new HttpRequestMethodNotSupportedException("GET", List.of("POST"));

        ResponseEntity<ApiResponse<Map<String, List<String>>>> response =
                handler.handleMethodNotAllowed(exception);

        assertEquals(405, response.getStatusCode().value());
        assertEquals(List.of("POST"), response.getHeaders().get(HttpHeaders.ALLOW));
        assertNotNull(response.getBody());
        assertEquals(405, response.getBody().getCode());
        assertEquals("HTTP method GET is not allowed for this endpoint", response.getBody().getMessage());
        assertEquals(List.of("POST"), response.getBody().getData().get("allowedMethods"));
    }

    @Test
    void missingBodyReturnsFriendly400() {
        HttpMessageNotReadableException exception =
                new HttpMessageNotReadableException("Required request body is missing");

        ResponseEntity<ApiResponse<Void>> response = handler.handleUnreadableBody(exception);

        assertEquals(400, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals(400, response.getBody().getCode());
        assertEquals("Request body is required", response.getBody().getMessage());
    }

    @Test
    void malformedJsonReturnsFriendly400() {
        HttpMessageNotReadableException exception =
                new HttpMessageNotReadableException("Unexpected end-of-input");

        ResponseEntity<ApiResponse<Void>> response = handler.handleUnreadableBody(exception);

        assertEquals(400, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Malformed JSON request body", response.getBody().getMessage());
    }
}
