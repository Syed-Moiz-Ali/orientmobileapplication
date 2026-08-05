package com.orient.workshop.supervisor.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.repository.JobCardMapper;
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
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkAssignmentService {

    private final WorkAssignmentMapper workAssignmentMapper;
    private final JobCardMapper jobCardMapper;

    @Transactional
    public WorkAssignmentResponse createAssignments(JwtUserPrincipal principal, WorkAssignmentRequest req) {
        if (req.getItems() == null || req.getItems().isEmpty()) {
            throw new BadRequestException("At least one assignment item is required");
        }
        List<WorkAssignmentResponse.AssignmentResult> results = req.getItems().stream()
                .map(item -> {
                    JobCard card = resolveJobCard(item.getJobCardId(), principal);
                    LocalDate dateOfWork = DateParse.parseLocalDate(item.getDateOfWork(), "dateOfWork");

                    String ref = IdGenerator.shortRef("ASN");
                    WorkAssignment wa = WorkAssignment.builder()
                            .assignmentRef(ref)
                            .jobCardId(card.getId())
                            .branchId(principal != null ? principal.getBranchId() : null)
                            .description(item.getDescription())
                            .department(item.getDepartment())
                            .technicianName(item.getTechnicianName())
                            .dateOfWork(dateOfWork)
                            .statusPercent(item.getStatusPercent() != null ? item.getStatusPercent() : 0)
                            .stdTime(item.getStdTime())
                            .remarks(item.getRemarks())
                            .status("Pending")
                            .build();
                    workAssignmentMapper.insert(wa);
                    return WorkAssignmentResponse.AssignmentResult.builder()
                            .id(ref)
                            .jobCard(card.getJobCardRef())
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

    private JobCard resolveJobCard(String jobCardId, JwtUserPrincipal principal) {
        if (jobCardId == null || jobCardId.isBlank()) {
            throw new BadRequestException("jobCardId is required for each assignment item");
        }
        Long id;
        try {
            id = Long.parseLong(jobCardId);
        } catch (NumberFormatException e) {
            throw new BadRequestException("Invalid jobCardId '" + jobCardId + "'");
        }
        JobCard card = jobCardMapper.selectById(id);
        if (card == null) {
            throw new BadRequestException("Job card not found with id: " + id);
        }
        if (principal != null && principal.getBranchId() != null
                && card.getBranchId() != null && !principal.getBranchId().equals(card.getBranchId())) {
            throw new BadRequestException("Job card " + id + " belongs to a different branch");
        }
        return card;
    }
}
