package com.orient.workshop.owner.service;

import com.orient.workshop.advisor.model.entity.RepairOrder;
import com.orient.workshop.advisor.repository.RepairOrderMapper;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.core.service.JobWorkflowService;
import com.orient.workshop.owner.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OwnerJobCardService {

    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final RepairOrderMapper repairOrderMapper;
    private final JobWorkflowService jobWorkflowService;

    public List<OwnerJobCardResponse> getJobCards() {
        return toOwnerCards(jobCardMapper.findRecent(50, 0));
    }

    /**
     * P3 (audit): CSV export of the job-card register.
     */
    public String exportCsv() {
        StringBuilder sb = new StringBuilder("job_card_id,customer,vehicle,plate,services,technician,amount,status\n");
        for (OwnerJobCardResponse c : getJobCards()) {
            sb.append(esc(c.getId())).append(',')
                    .append(esc(c.getCustomerName())).append(',')
                    .append(esc(c.getVehicle())).append(',')
                    .append(esc(c.getPlateNumber())).append(',')
                    .append(esc(c.getServices())).append(',')
                    .append(esc(c.getTechnician())).append(',')
                    .append(c.getAmount()).append(',')
                    .append(esc(c.getStatus()))
                    .append('\n');
        }
        return sb.toString();
    }

    private static String esc(String s) {
        if (s == null) return "";
        return "\"" + s.replace("\"", "\"\"") + "\"";
    }

    public List<JobStatusResponse> getJobsByStage(String stage, String search) {
        // FIX (audit P1): blank vehicle/amount fields + null-status NPE.
        List<JobCard> cards = jobCardMapper.findRecent(50, 0).stream()
                .filter(c -> stage == null || stage.isBlank() || stage.equalsIgnoreCase(c.getStatus()))
                .filter(c -> search == null || search.isBlank()
                        || c.getJobCardRef().toLowerCase().contains(search.toLowerCase()))
                .collect(Collectors.toList());
        if (cards.isEmpty()) return List.of();

        Map<Long, Vehicle> vehicles = loadVehicles(cards);
        Map<Long, Double> amounts = loadAmounts(cards);
        return cards.stream()
                .map(c -> {
                    Vehicle v = c.getVehicleId() != null ? vehicles.get(c.getVehicleId()) : null;
                    return JobStatusResponse.builder()
                            .jobCardId(c.getJobCardRef())
                            .vehicleInfo(vehicleLabel(v))
                            .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                            .stage(c.getStatus())
                            .estimatedAmount(amounts.getOrDefault(c.getId(), 0.0).intValue())
                            .build();
                })
                .collect(Collectors.toList());
    }

    public List<PendingJobResponse> getPendingJobs() {
        List<JobCard> cards = jobCardMapper.findByStatus("pending", 50, 0);
        Map<Long, Double> amounts = loadAmounts(cards);
        return cards.stream()
                .map(c -> PendingJobResponse.builder()
                        .jobCardId(c.getJobCardRef())
                        .createdDate(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                        .status("pending")
                        .estimatedAmount(amounts.getOrDefault(c.getId(), 0.0).intValue())
                        .build())
                .collect(Collectors.toList());
    }

    public List<OwnerJobCardResponse> getActiveJobs() {
        return toOwnerCards(jobCardMapper.findByStatus("inProgress", 50, 0));
    }

    /**
     * P1 (audit): owner can advance a job card status (e.g. mark complete).
     * Accepts the DB id or the ref.
     */
    @org.springframework.transaction.annotation.Transactional
    public void updateStatus(String id, String status) {
        if (status == null || status.isBlank()) {
            throw new com.orient.workshop.common.exception.BadRequestException("status is required");
        }
        JobCard card;
        if (id.matches("\\d+")) {
            card = jobCardMapper.selectById(Long.valueOf(id));
        } else {
            card = jobCardMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<JobCard>()
                    .eq("job_card_ref", id));
        }
        if (card == null) {
            throw new com.orient.workshop.common.exception.NotFoundException("Job card not found: " + id);
        }
        if ("completed".equals(status)) {
            jobWorkflowService.approveQc(card.getId(), null, null);
        } else if ("delivered".equals(status)) {
            jobWorkflowService.deliverById(card.getId(), null, null);
        } else if ("cancelled".equals(status)) {
            jobWorkflowService.cancel(card.getId(), null, null);
        } else {
            throw new com.orient.workshop.common.exception.BadRequestException(
                    "Owner status changes must use completed, delivered, or cancelled workflow commands");
        }
    }

    // FIX (audit P1): owner job cards previously returned blank customer,
    // vehicle, plate, services and zero amounts — real joins now.
    private List<OwnerJobCardResponse> toOwnerCards(List<JobCard> cards) {
        if (cards.isEmpty()) return List.of();
        Map<Long, Customer> customers = loadCustomers(cards);
        Map<Long, Vehicle> vehicles = loadVehicles(cards);
        Map<Long, Double> amounts = loadAmounts(cards);
        return cards.stream()
                .map(c -> {
                    Customer customer = c.getCustomerId() != null ? customers.get(c.getCustomerId()) : null;
                    Vehicle v = c.getVehicleId() != null ? vehicles.get(c.getVehicleId()) : null;
                    return OwnerJobCardResponse.builder()
                            .id(String.valueOf(c.getId()))
                            .jobCardRef(c.getJobCardRef())
                            .customerName(customer != null && customer.getCustomerName() != null
                                    ? customer.getCustomerName() : "")
                            .vehicle(vehicleLabel(v))
                            .plateNumber(v != null && v.getPlateNumber() != null ? v.getPlateNumber() : "")
                            .services(c.getTag() != null ? c.getTag() : "")
                            .technician(c.getTechnician() != null ? c.getTechnician() : "")
                            .estCompletion(c.getEstimatedDelivery() != null ? c.getEstimatedDelivery().toString() : "")
                            .amount(amounts.getOrDefault(c.getId(), 0.0))
                            .status(c.getStatus())
                            .build();
                })
                .collect(Collectors.toList());
    }

    private Map<Long, Customer> loadCustomers(List<JobCard> cards) {
        List<Long> ids = cards.stream().map(JobCard::getCustomerId)
                .filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (ids.isEmpty()) return Collections.emptyMap();
        return customerMapper.selectBatchIds(ids).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));
    }

    private Map<Long, Vehicle> loadVehicles(List<JobCard> cards) {
        List<Long> ids = cards.stream().map(JobCard::getVehicleId)
                .filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (ids.isEmpty()) return Collections.emptyMap();
        return vehicleMapper.selectBatchIds(ids).stream()
                .collect(Collectors.toMap(Vehicle::getId, Function.identity()));
    }

    private Map<Long, Double> loadAmounts(List<JobCard> cards) {
        if (cards.isEmpty()) return Collections.emptyMap();
        return cards.stream().collect(Collectors.toMap(
                JobCard::getId,
                c -> {
                    List<RepairOrder> ros = repairOrderMapper.findByJobCardId(c.getId());
                    if (ros.isEmpty()) return 0.0;
                    // latest repair order's server-computed grand total
                    return ros.get(0).getGrandTotal() != null ? ros.get(0).getGrandTotal() : 0.0;
                }));
    }

    private String vehicleLabel(Vehicle v) {
        if (v == null) return "";
        return ((v.getMake() != null ? v.getMake() : "")
                + " " + (v.getModel() != null ? v.getModel() : "")).trim();
    }
}
