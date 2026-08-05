package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.customer.model.dto.ActiveServiceResponse;
import com.orient.workshop.customer.model.dto.ServiceStageDto;
import com.orient.workshop.customer.model.dto.ServiceTypeResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.ServiceType;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.ServiceTypeMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ServiceTrackingService {

    private static final List<String> STAGE_ORDER = List.of(
            "pending", "inProgress", "waitingParts", "pendingApproval", "qualityCheck", "completed", "cancelled");

    private static final List<String> STAGE_LABELS = List.of(
            "Pending", "In Progress", "Waiting for Parts", "Pending Approval",
            "Quality Check", "Completed", "Cancelled");

    private final JobCardMapper jobCardMapper;
    private final ServiceTypeMapper serviceTypeMapper;
    private final CustomerService customerService;
    private final VehicleMapper vehicleMapper;
    private final TechnicianTaskMapper technicianTaskMapper;

    public ActiveServiceResponse getActiveService(JwtUserPrincipal principal) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId());

        JobCard jobCard = jobCardMapper.findActiveByCustomerId(customer.getId())
                .orElse(null);
        if (jobCard == null) {
            // 200 with an explicit flag instead of 404 — the app treats
            // "no active job" as a normal state, not an error.
            return ActiveServiceResponse.builder()
                    .hasActiveJob(false)
                    .currentStage("No Active Job")
                    .build();
        }

        String status = jobCard.getStatus() != null ? jobCard.getStatus() : "pending";
        int currentIndex = STAGE_ORDER.indexOf(status);
        if (currentIndex < 0) currentIndex = 0;

        List<TechnicianTask> tasks = jobCard.getJobCardRef() == null ? List.of()
                : technicianTaskMapper.findByJobCardNo(jobCard.getJobCardRef());

        int progressPercent;
        if (!tasks.isEmpty()) {
            long done = tasks.stream().filter(t -> "completed".equals(t.getStatus())).count();
            progressPercent = (int) Math.round(done * 100.0 / tasks.size());
        } else {
            progressPercent = "cancelled".equals(status) ? 100
                    : Math.min((int) Math.round((currentIndex + 1) * 100.0 / STAGE_ORDER.size()), 100);
        }

        Vehicle vehicle = jobCard.getVehicleId() != null ? vehicleMapper.selectById(jobCard.getVehicleId()) : null;

        return ActiveServiceResponse.builder()
                .jobCardId(jobCard.getJobCardRef())
                .plateNumber(vehicle != null && vehicle.getPlateNumber() != null ? vehicle.getPlateNumber() : "")
                .vehicleName(vehicle != null
                        ? ((vehicle.getMake() != null ? vehicle.getMake() : "") + " "
                           + (vehicle.getModel() != null ? vehicle.getModel() : "")).trim()
                        : "")
                .service(jobCard.getTag() != null ? jobCard.getTag() : "")
                .started(jobCard.getCreatedDate() != null ? jobCard.getCreatedDate().toString() : "")
                .estCompletion(jobCard.getEstimatedDelivery() != null ? jobCard.getEstimatedDelivery().toString() : "")
                .progressPercent(progressPercent)
                .currentStage(STAGE_LABELS.get(currentIndex))
                .technicianName(jobCard.getTechnician() != null ? jobCard.getTechnician() : "")
                .stages(buildStages(currentIndex, jobCard))
                .build();
    }

    public List<ServiceTypeResponse> getServiceTypes() {
        List<ServiceType> types = serviceTypeMapper.selectList(null);
        return types.stream()
                .map(t -> ServiceTypeResponse.builder()
                        .id(String.valueOf(t.getId()))
                        .name(t.getName())
                        .price(t.getPrice())
                        .duration(t.getDuration())
                        .build())
                .collect(Collectors.toList());
    }

    private List<ServiceStageDto> buildStages(int currentIndex, JobCard jobCard) {
        List<ServiceStageDto> stages = new ArrayList<>();
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("hh:mm a");
        for (int i = 0; i < STAGE_ORDER.size(); i++) {
            String stageStatus = i < currentIndex ? "done" : (i == currentIndex ? "inProgress" : "pending");
            String time = "";
            if (i == 0 && jobCard.getCreatedDate() != null) {
                time = jobCard.getCreatedDate().format(timeFmt);
            }
            stages.add(ServiceStageDto.builder()
                    .name(STAGE_LABELS.get(i))
                    .time(time)
                    .status(stageStatus)
                    .build());
        }
        return stages;
    }
}
