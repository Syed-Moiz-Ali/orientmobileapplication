package com.orient.workshop.auth.service;

import com.orient.workshop.common.exception.BadRequestException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class PasswordService {

    public static final int MIN_PASSWORD_LENGTH = 8;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public String hash(String rawPassword) {
        if (rawPassword == null || rawPassword.length() < MIN_PASSWORD_LENGTH) {
            throw new BadRequestException("Password must be at least " + MIN_PASSWORD_LENGTH + " characters");
        }
        return encoder.encode(rawPassword);
    }

    public void validate(String rawPassword, String storedHash) {
        if (rawPassword == null || rawPassword.length() < MIN_PASSWORD_LENGTH
                || !encoder.matches(rawPassword, storedHash)) {
            throw new BadRequestException("Invalid email/phone or password");
        }
    }
}
