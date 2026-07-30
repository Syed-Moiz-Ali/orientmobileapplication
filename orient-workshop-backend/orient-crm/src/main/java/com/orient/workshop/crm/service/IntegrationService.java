package com.orient.workshop.crm.service;

import com.orient.workshop.crm.model.dto.IntegrationResponse;
import com.orient.workshop.crm.repository.CrmIntegrationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class IntegrationService {

    private final CrmIntegrationMapper integrationMapper;

    public List<IntegrationResponse> getIntegrations() {
        return integrationMapper.selectList(null).stream()
                .map(i -> IntegrationResponse.builder().name(i.getName()).connected(i.getConnected() != null && i.getConnected()).build())
                .collect(Collectors.toList());
    }
}
