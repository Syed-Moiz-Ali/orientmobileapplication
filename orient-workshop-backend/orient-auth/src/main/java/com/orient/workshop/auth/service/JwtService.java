package com.orient.workshop.auth.service;

import com.orient.workshop.auth.model.dto.TokenResponse;
import com.orient.workshop.auth.model.entity.RefreshTokenEntity;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.RefreshTokenMapper;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.util.JwtUtil;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class JwtService {

    private final JwtUtil jwtUtil;
    private final UserMapper userMapper;
    private final RefreshTokenMapper refreshTokenMapper;

    @Transactional
    public TokenResponse createTokenPair(User user) {
        String accessToken = jwtUtil.generateAccessToken(user.getId(), user.getPhone(), user.getRole(), user.getBranchId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        RefreshTokenEntity entity = RefreshTokenEntity.builder()
                .userId(user.getId())
                .token(refreshToken)
                .expiresAt(LocalDateTime.now().plusDays(30))
                .build();
        refreshTokenMapper.insert(entity);

        return TokenResponse.builder()
                .role(user.getRole())
                .token(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    @Transactional
    public TokenResponse refreshAccessToken(String refreshTokenValue) {
        if (!jwtUtil.validateToken(refreshTokenValue) || !jwtUtil.isRefreshToken(refreshTokenValue)) {
            throw new BadRequestException("Invalid refresh token");
        }

        RefreshTokenEntity storedToken = refreshTokenMapper.findValidByToken(refreshTokenValue)
                .orElseThrow(() -> new UnauthorizedException("Refresh token expired or revoked"));

        Long userId = jwtUtil.getUserIdFromToken(refreshTokenValue);
        User user = userMapper.selectById(userId);
        if (user == null || !user.getIsActive()) {
            throw new UnauthorizedException("User not found or inactive");
        }

        refreshTokenMapper.revokeById(storedToken.getId());
        return createTokenPair(user);
    }

    @Transactional
    public void revokeRefreshToken(String refreshTokenValue) {
        if (refreshTokenValue != null && !refreshTokenValue.isEmpty()) {
            refreshTokenMapper.findValidByToken(refreshTokenValue)
                    .ifPresent(token -> refreshTokenMapper.revokeById(token.getId()));
        }
    }

    @Transactional
    public void revokeAllUserTokens(Long userId) {
        refreshTokenMapper.revokeByUserId(userId);
    }
}
