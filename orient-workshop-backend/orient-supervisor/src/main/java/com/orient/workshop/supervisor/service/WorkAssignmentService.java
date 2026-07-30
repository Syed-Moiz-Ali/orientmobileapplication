package com.orient.workshop.supervisor.service;

import com.orient.workshop.supervisor.model.dto.AssignedJobResponse;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentRequest;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentResponse;
import com.orient.workshop.supervisor.model.entity.WorkAssignment;
import com.orient.workshop.supervisor.repository.WorkAssignmentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkAssignmentService {

    private final WorkAssignmentMapper workAssignmentMapper;
    private final AtomicLong counter = new AtomicLong(0);

    @Transactional
    public WorkAssignmentResponse createAssignments(WorkAssignmentRequest req) {
        List<WorkAssignmentResponse.AssignmentResult> results = req.getItems().stream()
                .map(item -> {
                    String ref = "ASN-" + counter.incrementAndGet();
                    WorkAssignment wa = WorkAssignment.builder()
                            .assignmentRef(ref)
                            .description(item.getDescription())
                            .department(item.getDepartment())
                            .technicianName(item.getTechnicianName())
                            .dateOfWork(item.getDateOfWork() != null ? LocalDate.parse(item.getDateOfWork()) : null)
                            .statusPercent(item.getStatusPercent() != null ? item.getStatusPercent() : 0)
                            .stdTime(item.getStdTime())
                            .remarks(item.getRemarks())
                            .status("Pending")
                            .build();
                    workAssignmentMapper.insert(wa);
                    return WorkAssignmentResponse.AssignmentResult.builder()
                            .id(ref)
                            .jobCard(ref)
                            .status("Pending")
                            .build();
                }).collect(Collectors.toList());

        return WorkAssignmentResponse.builder().results(results).build();
    }

    public List<AssignedJobResponse> getAssignedJobs() {
        return workAssignmentMapper.findAll().stream()
                .map(wa -> AssignedJobResponse.builder()
                        .jobCard(wa.getAssignmentRef())
                        .customer("")
                        .vehicle("")
                        .dateAssigned(wa.getCreatedAt() != null ? wa.getCreatedAt().toLocalDate().toString() : "")
                        .done(0)
                        .total(1)
                        .status(wa.getStatus())
                        .build())
                .collect(Collectors.toList());
    }
}
