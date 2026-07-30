package com.orient.workshop.auth.service;

import com.orient.workshop.common.exception.BadRequestException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class PasswordService {

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public String hash(String rawPassword) {
        return encoder.encode(rawPassword);
    }

    public void validate(String rawPassword, String storedHash) {
        if (!encoder.matches(rawPassword, storedHash)) {
            throw new BadRequestException("Invalid email/phone or password");
        }
    }
}
