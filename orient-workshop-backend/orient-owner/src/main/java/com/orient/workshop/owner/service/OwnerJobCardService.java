package com.orient.workshop.owner.service;

import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.owner.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerJobCardService {

    private final JobCardMapper jobCardMapper;

    public List<OwnerJobCardResponse> getJobCards() {
        return jobCardMapper.findRecent(50, 0).stream().map(this::toOwnerCard).collect(Collectors.toList());
    }

    public List<JobStatusResponse> getJobsByStage(String stage, String search) {
        return jobCardMapper.findRecent(50, 0).stream()
                .filter(c -> stage == null || c.getStatus().equals(stage))
                .map(c -> JobStatusResponse.builder()
                        .jobCardId(c.getJobCardRef())
                        .vehicleInfo("")
                        .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                        .stage(c.getStatus())
                        .estimatedAmount(0)
                        .build())
                .collect(Collectors.toList());
    }

    public List<PendingJobResponse> getPendingJobs() {
        return jobCardMapper.findByStatus("pending", 50, 0).stream()
                .map(c -> PendingJobResponse.builder()
                        .jobCardId(c.getJobCardRef())
                        .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                        .status("pending")
                        .estimatedAmount(0)
                        .build())
                .collect(Collectors.toList());
    }

    public List<OwnerJobCardResponse> getActiveJobs() {
        return jobCardMapper.findByStatus("inProgress", 50, 0).stream()
                .map(this::toOwnerCard).collect(Collectors.toList());
    }

    private OwnerJobCardResponse toOwnerCard(JobCard c) {
        return OwnerJobCardResponse.builder()
                .id(String.valueOf(c.getId()))
                .customerName("")
                .vehicle("")
                .plateNumber("")
                .services("")
                .technician(c.getTechnician())
                .estCompletion(c.getEstimatedDelivery() != null ? c.getEstimatedDelivery().toString() : "")
                .amount(0)
                .status(c.getStatus())
                .build();
    }
}
