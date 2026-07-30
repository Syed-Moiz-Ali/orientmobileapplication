package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.CustomerSearchResponse;
import com.orient.workshop.advisor.model.dto.VehicleSearchResponse;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;

    public List<CustomerSearchResponse> searchCustomers(String q) {
        return customerMapper.search(q).stream()
                .map(c -> CustomerSearchResponse.builder()
                        .customerName(c.getCustomerName())
                        .phone(c.getPhoneNumber())
                        .email(c.getEmail())
                        .build())
                .collect(Collectors.toList());
    }

    public List<VehicleSearchResponse> searchVehicles(String q) {
        return vehicleMapper.search(q).stream()
                .map(v -> VehicleSearchResponse.builder()
                        .regNo(v.getRegistrationNumber())
                        .vin(v.getVin())
                        .make(v.getMake())
                        .model(v.getModel())
                        .plateNumber(v.getPlateNumber())
                        .build())
                .collect(Collectors.toList());
    }
}
