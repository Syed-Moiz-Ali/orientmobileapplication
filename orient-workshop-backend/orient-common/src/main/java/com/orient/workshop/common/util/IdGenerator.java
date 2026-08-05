package com.orient.workshop.common.util;

import java.security.SecureRandom;
import java.util.UUID;

/**
 * Collision-safe reference generators. Replaces System.currentTimeMillis()%10000 style
 * counters and in-memory counters with cryptographically random short references.
 */
public final class IdGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char[] HEX = "0123456789abcdef".toCharArray();

    private IdGenerator() {
    }

    /** 8 random hex chars, e.g. "3f9a2c1d". */
    public static String shortSuffix() {
        byte[] bytes = new byte[4];
        RANDOM.nextBytes(bytes);
        char[] out = new char[8];
        for (int i = 0; i < 4; i++) {
            out[i * 2] = HEX[(bytes[i] >> 4) & 0x0F];
            out[i * 2 + 1] = HEX[bytes[i] & 0x0F];
        }
        return new String(out);
    }

    /** Prefixed reference, e.g. shortRef("BK") -> "BK-3f9a2c1d". */
    public static String shortRef(String prefix) {
        return prefix + "-" + shortSuffix();
    }

    public static String uuid() {
        return UUID.randomUUID().toString();
    }
}
