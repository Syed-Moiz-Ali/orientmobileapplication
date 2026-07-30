package com.orient.workshop.advisor.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.advisor.model.dto.JobCardDetailResponse;
import com.orient.workshop.advisor.model.dto.JobCardResponse;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.common.response.PageResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class JobCardService {

    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;

    public PageResponse<JobCardResponse> listJobCards(String status, String search, int page, int limit) {
        int offset = (page - 1) * limit;
        List<JobCard> cards;

        if (search != null && !search.isBlank()) {
            LambdaQueryWrapper<JobCard> q = new LambdaQueryWrapper<JobCard>()
                    .like(JobCard::getJobCardRef, search);
            cards = jobCardMapper.selectList(q);
        } else if (status != null && !status.isBlank()) {
            cards = jobCardMapper.findByStatus(status, limit, offset);
        } else {
            cards = jobCardMapper.findRecent(limit, offset);
        }

        long total = jobCardMapper.countAll();

        List<JobCardResponse> items = cards.stream().map(this::toResponse).collect(Collectors.toList());
        return PageResponse.of(items, page, limit, total);
    }

    public JobCardDetailResponse getJobCard(Long id) {
        JobCard card = jobCardMapper.selectById(id);
        if (card == null) throw new NotFoundException("Job card not found");

        return toDetailResponse(card);
    }

    @Transactional
    public void updateStatus(Long id, String status) {
        JobCard card = jobCardMapper.selectById(id);
        if (card == null) throw new NotFoundException("Job card not found");
        card.setStatus(status);
        jobCardMapper.updateById(card);
    }

    @Transactional
    public void assignTechnician(Long id, String technician) {
        JobCard card = jobCardMapper.selectById(id);
        if (card == null) throw new NotFoundException("Job card not found");
        card.setTechnician(technician);
        jobCardMapper.updateById(card);
    }

    private JobCardResponse toResponse(JobCard c) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String custName = "";
        if (c.getCustomerId() != null) {
            Customer cust = customerMapper.selectById(c.getCustomerId());
            if (cust != null) custName = cust.getCustomerName();
        }
        String vehicleInfo = "";
        if (c.getVehicleId() != null) {
            Vehicle v = vehicleMapper.selectById(c.getVehicleId());
            if (v != null) vehicleInfo = v.getMake() + " " + v.getModel();
        }
        return JobCardResponse.builder()
                .id(c.getJobCardRef())
                .customerName(custName)
                .vehicleInfo(vehicleInfo)
                .time(c.getCreatedAt() != null ? c.getCreatedAt().format(DateTimeFormatter.ofPattern("hh:mm a")) : "")
                .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().format(fmt) : "")
                .lastUpdated(c.getUpdatedAt() != null ? c.getUpdatedAt().format(fmt) : "")
                .status(c.getStatus())
                .technician(c.getTechnician() != null ? c.getTechnician() : "")
                .build();
    }

    private JobCardDetailResponse toDetailResponse(JobCard c) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return JobCardDetailResponse.builder()
                .id(c.getJobCardRef())
                .status(c.getStatus())
                .technician(c.getTechnician())
                .notes(c.getNotes())
                .tag(c.getTag())
                .customerRequests(c.getCustomerRequests())
                .garageRecommendations(c.getGarageRecommendations())
                .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().format(fmt) : "")
                .lastUpdated(c.getUpdatedAt() != null ? c.getUpdatedAt().format(fmt) : "")
                .estimatedDelivery(c.getEstimatedDelivery() != null ? c.getEstimatedDelivery().toString() : "")
                .build();
    }
}
