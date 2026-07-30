package com.orient.workshop.common.util;

public final class PhoneUtil {

    private static final String UAE_COUNTRY_CODE = "971";
    private static final int PHONE_MIN_LENGTH = 8;
    private static final int PHONE_MAX_LENGTH = 15;

    private PhoneUtil() {}

    public static String normalize(String phone) {
        if (phone == null) return null;
        String cleaned = phone.replaceAll("[^0-9]", "");
        if (cleaned.startsWith("00")) {
            cleaned = cleaned.substring(2);
        }
        if (cleaned.startsWith("0") && !cleaned.startsWith("971")) {
            cleaned = UAE_COUNTRY_CODE + cleaned.substring(1);
        }
        return cleaned;
    }

    public static boolean isValid(String phone) {
        if (phone == null) return false;
        String cleaned = normalize(phone);
        return cleaned.length() >= PHONE_MIN_LENGTH && cleaned.length() <= PHONE_MAX_LENGTH;
    }

    public static String mask(String phone) {
        String normalized = normalize(phone);
        if (normalized == null) return null;
        int len = normalized.length();
        if (len <= 4) return normalized;
        return normalized.substring(0, len - 4).replaceAll(".", "*")
                + normalized.substring(len - 4);
    }
}
