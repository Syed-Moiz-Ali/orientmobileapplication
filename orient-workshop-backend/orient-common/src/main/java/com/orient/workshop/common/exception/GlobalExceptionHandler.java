package com.orient.workshop.common.exception;

import com.orient.workshop.common.response.ApiResponse;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpMediaTypeNotAcceptableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** Typed domain exceptions (BadRequest, NotFound, Unauthorized, Forbidden, TooManyRequests, Conflict...). */
    @ExceptionHandler(AppException.class)
    public ResponseEntity<ApiResponse<Void>> handleAppException(AppException e) {
        log.warn("AppException: {} - {}", e.getCode(), e.getMessage());
        return ResponseEntity
                .status(HttpStatus.valueOf(e.getCode()))
                .body(ApiResponse.error(e.getCode(), e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidation(MethodArgumentNotValidException e) {
        Map<String, String> errors = new HashMap<>();
        e.getBindingResult().getFieldErrors().forEach(err ->
                errors.put(err.getField(), err.getDefaultMessage()));
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.error(400, "Validation failed", errors));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleConstraintViolation(ConstraintViolationException e) {
        Map<String, String> errors = new HashMap<>();
        e.getConstraintViolations().forEach(v ->
                errors.put(v.getPropertyPath().toString(), v.getMessage()));
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.error(400, "Validation failed", errors));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse<Map<String, List<String>>>> handleMethodNotAllowed(
            HttpRequestMethodNotSupportedException e) {
        List<String> allowedMethods = e.getSupportedHttpMethods() == null
                ? List.of()
                : e.getSupportedHttpMethods().stream()
                        .map(HttpMethod::name)
                        .sorted()
                        .toList();
        Map<String, List<String>> details = allowedMethods.isEmpty()
                ? null
                : Map.of("allowedMethods", allowedMethods);
        String message = "HTTP method " + e.getMethod() + " is not allowed for this endpoint";

        log.warn("Method not allowed: {} (allowed={})", e.getMethod(), allowedMethods);
        ResponseEntity.BodyBuilder response = ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED);
        if (!allowedMethods.isEmpty()) {
            response.allow(allowedMethods.stream().map(HttpMethod::valueOf).toArray(HttpMethod[]::new));
        }
        return response.body(ApiResponse.error(405, message, details));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResponse<Void>> handleUnreadableBody(HttpMessageNotReadableException e) {
        log.warn("Malformed request: {} - {}", e.getClass().getSimpleName(), e.getMessage());
        String message = e.getMessage() != null && e.getMessage().contains("Required request body is missing")
                ? "Request body is required"
                : "Malformed JSON request body";
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.error(400, message));
    }

    @ExceptionHandler({MethodArgumentTypeMismatchException.class,
            MissingServletRequestParameterException.class,
            MissingRequestHeaderException.class})
    public ResponseEntity<ApiResponse<Void>> handleInvalidRequestValue(Exception e) {
        log.warn("Invalid request value: {} - {}", e.getClass().getSimpleName(), e.getMessage());
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.error(400, "A required request value is missing or invalid"));
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ApiResponse<Map<String, List<String>>>> handleUnsupportedMediaType(
            HttpMediaTypeNotSupportedException e) {
        List<String> supportedTypes = e.getSupportedMediaTypes().stream()
                .map(Object::toString)
                .toList();
        String receivedType = e.getContentType() == null ? "unspecified" : e.getContentType().toString();
        return ResponseEntity
                .status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                .body(ApiResponse.error(415,
                        "Content type '" + receivedType + "' is not supported",
                        Map.of("supportedContentTypes", supportedTypes)));
    }

    @ExceptionHandler(HttpMediaTypeNotAcceptableException.class)
    public ResponseEntity<ApiResponse<Map<String, List<String>>>> handleNotAcceptable(
            HttpMediaTypeNotAcceptableException e) {
        List<String> supportedTypes = e.getSupportedMediaTypes().stream()
                .map(Object::toString)
                .toList();
        return ResponseEntity
                .status(HttpStatus.NOT_ACCEPTABLE)
                .body(ApiResponse.error(406,
                        "Requested response format is not supported",
                        Map.of("supportedResponseTypes", supportedTypes)));
    }

    // FIX (audit QA BUG-017): MediaService (and friends) reject bad input with
    // IllegalArgumentException ("File is empty", "File type not allowed"...).
    // Without this they surfaced as opaque 500s.
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException e) {
        log.warn("Invalid argument: {}", e.getMessage());
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.error(400, e.getMessage() != null ? e.getMessage() : "Invalid request"));
    }

    // FIX (audit QA BUG-006): unknown paths fell through to the static-resource
    // handler and surfaced as 500 (or 401 from the security chain) with an empty
    // body. Return a proper 404 envelope so clients can distinguish "no such
    // endpoint" from real failures.
    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleNoResource(
            org.springframework.web.servlet.resource.NoResourceFoundException e) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(404, "Endpoint not found"));
    }

    // H-7: duplicate keys / constraint violations -> 409
    @ExceptionHandler({DuplicateKeyException.class, DataIntegrityViolationException.class})
    public ResponseEntity<ApiResponse<Void>> handleDataIntegrity(Exception e) {
        log.warn("Data integrity violation: {} - {}", e.getClass().getSimpleName(), e.getMessage());
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(ApiResponse.error(409, "Resource already exists or conflicts with existing data"));
    }

    // Method-security (@PreAuthorize) denials inside controllers:
    // unauthenticated -> 401 (client should refresh/login), else 403.
    @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDenied(
            org.springframework.security.access.AccessDeniedException e) {
        org.springframework.security.core.Authentication auth =
                org.springframework.security.core.context.SecurityContextHolder
                        .getContext().getAuthentication();
        boolean authenticated = auth != null && auth.isAuthenticated()
                && !(auth instanceof org.springframework.security.authentication.AnonymousAuthenticationToken);
        log.warn("Access denied: {} (authenticated={})", e.getMessage(), authenticated);
        return ResponseEntity
                .status(authenticated ? HttpStatus.FORBIDDEN : HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(authenticated ? 403 : 401,
                        authenticated ? "Forbidden" : "Unauthorized"));
    }

    // Method-security authentication failures inside controllers -> 401
    @ExceptionHandler(org.springframework.security.core.AuthenticationException.class)
    public ResponseEntity<ApiResponse<Void>> handleAuthentication(
            org.springframework.security.core.AuthenticationException e) {
        log.warn("Authentication required: {}", e.getMessage());
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(401, "Unauthorized"));
    }

    // H-7: opaque catch-all; the real message is only logged server-side
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<String>> handleUnknown(Exception e) {
        log.error("Unhandled exception", e);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(500, "Internal server error"));
    }
}
