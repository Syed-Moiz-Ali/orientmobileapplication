package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.customer.model.dto.CustomerProfileResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import lombok.RequiredArgsConstructor;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerService {

    private final CustomerMapper customerMapper;
    private final UserMapper userMapper;

    public Customer findOrCreateCustomer(Long userId) {
        return customerMapper.findByUserId(userId).orElseGet(() -> {
            User user = userMapper.selectById(userId);
            String name = (user != null && user.getName() != null && !user.getName().isBlank())
                    ? user.getName() : "Customer";
            String phone = user != null ? user.getPhone() : "";
            Customer c = Customer.builder()
                    .userId(userId)
                    .customerName(name)
                    .phoneNumber(phone != null ? phone : "")
                    .source("SMS")
                    .build();
            customerMapper.insert(c);
            log.info("Created Customer record for userId={}", userId);
            return c;
        });
    }

    public CustomerProfileResponse getProfile(JwtUserPrincipal principal) {
        Long userId = principal.getUserId();
        if (userId == null) throw new NotFoundException("User ID not found in token");

        User user = userMapper.selectById(userId);
        if (user == null) throw new NotFoundException("User not found with id: " + userId);

        Customer customer = findOrCreateCustomer(userId);

        String name = (user.getName() != null && !user.getName().isBlank()) ? user.getName() : "Customer";
        String firstName = name.contains(" ") ? name.split(" ")[0] : name;
        String initials = getInitials(name);

        return CustomerProfileResponse.builder()
                .name(name)
                .firstName(firstName)
                .avatarInitials(initials)
                .memberId("CUST-" + String.format("%03d", customer.getId()))
                .build();
    }

    private String getInitials(String name) {
        if (name == null || name.isBlank()) return "U";
        String[] parts = name.trim().split("\\s+");
        if (parts.length == 1) return String.valueOf(parts[0].charAt(0)).toUpperCase();
        return (String.valueOf(parts[0].charAt(0)) + String.valueOf(parts[parts.length - 1].charAt(0))).toUpperCase();
    }
}
