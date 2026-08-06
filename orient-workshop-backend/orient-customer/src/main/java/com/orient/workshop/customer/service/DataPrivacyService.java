package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.*;
import com.orient.workshop.core.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * P3 (audit): PDPL/GDPR data subject rights.
 * - Export: every piece of personal data the platform holds for the customer.
 * - Erase: deletes non-financial personal data and anonymises the customer
 *   record (kept so invoices/approvals/job cards keep their referential
 *   integrity — financial records are retained for accounting).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DataPrivacyService {

    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final BookingMapper bookingMapper;
    private final BreakdownMapper breakdownMapper;
    private final NotificationMapper notificationMapper;
    private final FeedbackMapper feedbackMapper;

    public Map<String, Object> export(JwtUserPrincipal principal) {
        Customer customer = resolveCustomer(principal);
        Map<String, Object> bundle = new LinkedHashMap<>();
        bundle.put("exportedAt", java.time.LocalDateTime.now().toString());
        bundle.put("customer", customer);
        bundle.put("vehicles", vehicleMapper.findByCustomerId(customer.getId()));
        bundle.put("bookings", bookingMapper.findByCustomerId(customer.getId()));
        bundle.put("breakdowns", breakdownMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Breakdown>()
                        .eq("customer_id", customer.getId())));
        bundle.put("notifications", notificationMapper.findByUserId(principal.getUserId()));
        bundle.put("feedback", feedbackMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Feedback>()
                        .eq("customer_id", customer.getId())));
        return bundle;
    }

    @Transactional
    public void erase(JwtUserPrincipal principal) {
        Customer customer = resolveCustomer(principal);
        Long customerId = customer.getId();
        Long userId = principal.getUserId();

        bookingMapper.delete(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Booking>()
                .eq("customer_id", customerId));
        breakdownMapper.delete(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Breakdown>()
                .eq("customer_id", customerId));
        feedbackMapper.delete(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Feedback>()
                .eq("customer_id", customerId));
        for (Vehicle v : vehicleMapper.findByCustomerId(customerId)) {
            vehicleMapper.deleteById(v.getId());
        }
        if (userId != null) {
            notificationMapper.delete(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Notification>()
                    .eq("user_id", userId));
        }

        // Anonymise the customer row — invoices/approvals/job_cards reference it.
        customer.setCustomerName("Deleted User");
        customer.setPhoneNumber(null);
        customer.setEmail(null);
        customer.setAddress(null);
        customer.setTaxNumber(null);
        customer.setOccupation(null);
        customer.setOrganisation(null);
        customerMapper.updateById(customer);

        log.info("Data erasure completed for customer {} (user {})", customerId, userId);
    }

    private Customer resolveCustomer(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new NotFoundException("Authenticated user not found");
        }
        return customerMapper.findByUserId(principal.getUserId())
                .orElseThrow(() -> new NotFoundException("Customer record not found"));
    }
}
