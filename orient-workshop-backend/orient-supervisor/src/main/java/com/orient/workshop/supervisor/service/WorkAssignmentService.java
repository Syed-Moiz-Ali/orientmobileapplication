package com.orient.workshop.supervisor.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.supervisor.model.dto.AssignedJobResponse;
import com.orient.workshop.supervisor.model.dto.AvailableTechnicianResponse;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentRequest;
import com.orient.workshop.supervisor.model.dto.WorkAssignmentResponse;
import com.orient.workshop.supervisor.model.entity.WorkAssignment;
import com.orient.workshop.supervisor.repository.WorkAssignmentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkAssignmentService {

    private final WorkAssignmentMapper workAssignmentMapper;
    private final JobCardMapper jobCardMapper;
    private final StaffMapper staffMapper;
    private final TechnicianTaskMapper taskMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;

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

    /**
     * FIX (audit P0): this list returned a fabricated payload (empty customer/
     * vehicle, done=0/total=1). Now joins job cards → customers/vehicles and
     * counts real completed work items per technician task.
     */
    public List<AssignedJobResponse> getAssignedJobs() {
        List<WorkAssignment> assignments = workAssignmentMapper.findAll();
        if (assignments.isEmpty()) return List.of();

        List<Long> jobCardIds = assignments.stream()
                .map(WorkAssignment::getJobCardId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        List<JobCard> cards = jobCardIds.isEmpty() ? List.of()
                : jobCardMapper.selectBatchIds(jobCardIds);
        Map<Long, JobCard> cardsById = cards.stream()
                .collect(Collectors.toMap(JobCard::getId, Function.identity()));

        List<Long> customerIds = cards.stream()
                .map(JobCard::getCustomerId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, Customer> customers = customerIds.isEmpty() ? Map.of()
                : customerMapper.selectBatchIds(customerIds).stream()
                        .collect(Collectors.toMap(Customer::getId, Function.identity()));

        List<Long> vehicleIds = cards.stream()
                .map(JobCard::getVehicleId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, Vehicle> vehicles = vehicleIds.isEmpty() ? Map.of()
                : vehicleMapper.selectBatchIds(vehicleIds).stream()
                        .collect(Collectors.toMap(Vehicle::getId, Function.identity()));

        return assignments.stream().map(wa -> {
            JobCard card = cardsById.get(wa.getJobCardId());
            Customer customer = card != null && card.getCustomerId() != null
                    ? customers.get(card.getCustomerId()) : null;
            Vehicle vehicle = card != null && card.getVehicleId() != null
                    ? vehicles.get(card.getVehicleId()) : null;
            long done = taskMapper.selectCount(
                    new LambdaQueryWrapper<TechnicianTask>()
                            .eq(TechnicianTask::getJobCardNo, card != null ? card.getJobCardRef() : "")
                            .eq(TechnicianTask::getStatus, "completed"));
            long total = taskMapper.selectCount(
                    new LambdaQueryWrapper<TechnicianTask>()
                            .eq(TechnicianTask::getJobCardNo, card != null ? card.getJobCardRef() : ""));
            return AssignedJobResponse.builder()
                    .jobCard(card != null ? card.getJobCardRef() : wa.getAssignmentRef())
                    .customer(customer != null && customer.getCustomerName() != null ? customer.getCustomerName() : "")
                    .vehicle(vehicle != null
                            ? ((vehicle.getMake() != null ? vehicle.getMake() : "")
                                    + " " + (vehicle.getModel() != null ? vehicle.getModel() : "")).trim()
                            : "")
                    .dateAssigned(wa.getCreatedAt() != null ? wa.getCreatedAt().toLocalDate().toString() : "")
                    .done((int) done)
                    .total((int) total)
                    .status(wa.getStatus())
                    .build();
        }).collect(Collectors.toList());
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

    public List<AvailableTechnicianResponse> getAvailableTechnicians() {
        List<Staff> technicians = staffMapper.selectList(
                new LambdaQueryWrapper<Staff>()
                        .in(Staff::getRole, Arrays.asList("technician", "TECHNICIAN"))
                        .eq(Staff::getIsActive, true)
        );

        return technicians.stream().map(tech -> {
            Long inProgressCount = taskMapper.selectCount(
                    new LambdaQueryWrapper<TechnicianTask>()
                            .eq(TechnicianTask::getEmpId, tech.getEmpId())
                            .eq(TechnicianTask::getStatus, "inProgress")
            );
            return AvailableTechnicianResponse.builder()
                    .id(tech.getId())
                    .name(tech.getName())
                    .empId(tech.getEmpId())
                    .currentJobs(inProgressCount != null ? inProgressCount.intValue() : 0)
                    .build();
        }).collect(Collectors.toList());
    }
}
