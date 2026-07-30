package com.orient.workshop.advisor.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.advisor.model.dto.RepairOrderRequest;
import com.orient.workshop.advisor.model.dto.RepairOrderResponse;
import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class RepairOrderService {

    private final RepairOrderMapper repairOrderMapper;
    private final JobCardMapper jobCardMapper;

    @Transactional
    public RepairOrderResponse createRepairOrder(RepairOrderRequest req) {
        if (req.getJobCardId() != null) {
            JobCard jc = jobCardMapper.selectById(Long.parseLong(req.getJobCardId()));
            if (jc == null) throw new NotFoundException("Job card not found");
        }

        String ref = "RO-" + LocalDate.now().toString() + "-" + String.format("%04d", System.currentTimeMillis() % 10000);

        RepairOrder ro = RepairOrder.builder()
                .repairOrderRef(ref)
                .jobCardId(req.getJobCardId() != null ? Long.parseLong(req.getJobCardId()) : null)
                .servicesTotal(req.getServicesTotal())
                .partsTotal(req.getPartsTotal())
                .grandTotal(req.getGrandTotal())
                .tag(req.getTag())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(req.getEstimatedDelivery() != null ? java.time.LocalDateTime.parse(req.getEstimatedDelivery()) : null)
                .notifyOwnerSmsEmail(req.getNotifyOwnerSmsEmail())
                .build();
        repairOrderMapper.insert(ro);

        return RepairOrderResponse.builder().id(ref).build();
    }
}
