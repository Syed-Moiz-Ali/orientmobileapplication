package com.orient.workshop.common.constant;

public final class ApiConstants {

    private ApiConstants() {}

    public static final String AUTH_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";
    public static final String IDEMPOTENCY_KEY_HEADER = "Idempotency-Key";

    public static final int OTP_LENGTH = 6;
    public static final int OTP_EXPIRY_MINUTES = 5;
    public static final int OTP_MAX_ATTEMPTS = 5;

    public static final long ACCESS_TOKEN_EXPIRY_MS = 86_400_000;
    public static final long REFRESH_TOKEN_EXPIRY_MS = 2_592_000_000L;

    public static final String DATE_FORMAT = "yyyy-MM-dd";
    public static final String DATETIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss";
}
