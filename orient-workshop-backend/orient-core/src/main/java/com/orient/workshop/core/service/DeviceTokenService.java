package com.orient.workshop.core.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.core.model.entity.DeviceToken;
import com.orient.workshop.core.repository.DeviceTokenMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;

@Service
@RequiredArgsConstructor
public class DeviceTokenService {

    private final DeviceTokenMapper deviceTokenMapper;

    @Transactional
    public void register(Long userId, String rawToken, String rawPlatform) {
        if (userId == null) {
            throw new IllegalArgumentException("An authenticated user is required");
        }
        String token = rawToken.trim();
        String platform = rawPlatform.trim().toLowerCase();

        // The legacy column/endpoint name is retained for API compatibility,
        // but this value is a Firebase Installation ID (FID). Moving it prevents
        // notifications leaking to a user who logged out of a device.
        deviceTokenMapper.delete(new LambdaQueryWrapper<DeviceToken>()
                .eq(DeviceToken::getToken, token));
        deviceTokenMapper.insert(DeviceToken.builder()
                .userId(userId)
                .token(token)
                .platform(platform)
                .build());
    }

    @Transactional
    public void removeTokens(Collection<String> tokens) {
        if (tokens == null || tokens.isEmpty()) return;
        deviceTokenMapper.delete(new LambdaQueryWrapper<DeviceToken>()
                .in(DeviceToken::getToken, tokens));
    }
}
