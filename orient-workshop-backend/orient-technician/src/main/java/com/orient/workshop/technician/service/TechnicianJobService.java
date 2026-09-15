package com.orient.workshop.technician.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.technician.model.dto.*;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.model.entity.TechnicianTask;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.core.repository.TechnicianTaskMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TechnicianJobService {

    private static final DateTimeFormatter TASK_TIME_FMT = DateTimeFormatter.ofPattern("hh:mm a", Locale.ENGLISH);

    private final JobCardMapper jobCardMapper;
    private final TechnicianTaskMapper taskMapper;
    private final StaffMapper staffMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;

    public List<AssignedJobResponse> getAssignedJobs(JwtUserPrincipal principal) {
        Staff staff = resolveStaff(principal);
        List<JobCard> cards = jobCardMapper.selectList(
                new LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getTechnician, staff.getName())
                        .eq(staff.getBranchId() != null, JobCard::getBranchId, staff.getBranchId()));
        return cards.stream()
            .map(c -> {
                Vehicle vehicle = c.getVehicleId() == null ? null : vehicleMapper.selectById(c.getVehicleId());
                Customer customer = c.getCustomerId() == null ? null : customerMapper.selectById(c.getCustomerId());
                return AssignedJobResponse.builder()
                        .id(String.valueOf(c.getId()))
                .customerName(customer == null ? "" : customer.getCustomerName())
                .customerPhone(customer == null ? "" : nullToEmpty(customer.getPhoneNumber()))
                .customerEmail(customer == null ? "" : nullToEmpty(customer.getEmail()))
                .vehicle(vehicle == null ? "" : vehicleLabel(vehicle))
                .plateNumber(vehicle == null ? "" : vehiclePlate(vehicle))
                .service(c.getTag() == null ? "Repair work" : c.getTag())
                        .amount("")
                        .status(c.getStatus())
                .build();
            })
                .collect(Collectors.toList());
    }

    @Transactional
    public void updateAssignedJobStatus(String id, JwtUserPrincipal principal, String status) {
        Staff staff = resolveStaff(principal);
        JobCard card = null;
        try {
            Long numericId = Long.parseLong(id);
            card = jobCardMapper.selectById(numericId);
        } catch (NumberFormatException ignored) {}
        if (card == null) {
            card = jobCardMapper.selectOne(new LambdaQueryWrapper<JobCard>().eq(JobCard::getJobCardRef, id));
        }
        if (card == null) throw new NotFoundException("Job card not found: " + id);
        if (!ownsJob(card, staff)) {
            throw new ForbiddenException("Job card is not assigned to the current user");
        }
        card.setStatus(status);
        jobCardMapper.updateById(card);
    }

    public List<TechnicianJobResponse> getJobs(JwtUserPrincipal principal, String status) {
        Staff staff = resolveStaff(principal);
        LambdaQueryWrapper<JobCard> q = new LambdaQueryWrapper<JobCard>()
                .eq(JobCard::getTechnician, staff.getName())
                .eq(staff.getBranchId() != null, JobCard::getBranchId, staff.getBranchId());
        if (status != null && !status.isBlank()) {
            q.eq(JobCard::getStatus, status);
        }
        q.orderByDesc(JobCard::getCreatedAt).last("LIMIT 100");
        List<JobCard> cards = jobCardMapper.selectList(q);
        return cards.stream()
                .map(c -> toJobResponse(c, taskMapper.findByJobCardNo(c.getJobCardRef()).stream()
                        // Per-item assignment: show only the logged-in tech's items.
                        .filter(t -> t.getEmpId() == null || t.getEmpId().isBlank()
                                || staff.getEmpId().equals(t.getEmpId()))
                        .collect(Collectors.toList())))
                .collect(Collectors.toList());
    }

    public TechnicianJobResponse searchJob(JwtUserPrincipal principal, String q) {
        Staff staff = resolveStaff(principal);
        List<JobCard> cards = jobCardMapper.selectList(
                new LambdaQueryWrapper<JobCard>()
                        .like(JobCard::getJobCardRef, q)
                        .eq(JobCard::getTechnician, staff.getName())
                        .last("LIMIT 1"));
        if (cards.isEmpty()) throw new NotFoundException("Job not found");
        return toJobResponse(cards.get(0));
    }

    @Transactional
    public void updateNotes(JwtUserPrincipal principal, String jobCardNo, String notes) {
        Staff staff = resolveStaff(principal);
        JobCard card = jobCardMapper.selectOne(
                new LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getJobCardRef, jobCardNo));
        if (card == null) throw new NotFoundException("Job card not found");
        if (!ownsJob(card, staff)) {
            throw new ForbiddenException("Job card is not assigned to the current user");
        }
        card.setNotes(notes);
        jobCardMapper.updateById(card);
    }

    public ProductivityResponse getProductivity(JwtUserPrincipal principal) {
        Staff staff = resolveStaff(principal);
        List<JobCard> assigned = jobCardMapper.selectList(
                new LambdaQueryWrapper<JobCard>()
                        .eq(JobCard::getTechnician, staff.getName())
                        .eq(staff.getBranchId() != null, JobCard::getBranchId, staff.getBranchId()));

        List<TechnicianTask> tasks = taskMapper.selectList(
                new LambdaQueryWrapper<TechnicianTask>()
                        .eq(TechnicianTask::getEmpId, staff.getEmpId()));

        long total = tasks.size();
        long completed = tasks.stream().filter(t -> "completed".equals(t.getStatus())).count();
        long inProgress = tasks.stream().filter(t -> "inProgress".equals(t.getStatus())).count();
        long completedToday = tasks.stream()
                .filter(t -> "completed".equals(t.getStatus()))
                .filter(t -> t.getUpdatedAt() != null && t.getUpdatedAt().toLocalDate().equals(LocalDate.now()))
                .count();

        long totalMinutes = 0;
        for (TechnicianTask t : tasks) {
            if (!"completed".equals(t.getStatus())) continue;
            long mins = taskMinutes(t.getStartTime(), t.getEndTime());
            if (mins > 0) totalMinutes += mins;
        }

        int efficiency = total > 0 ? (int) Math.round(completed * 100.0 / total) : 0;
        double avgMinutes = completed > 0 ? totalMinutes / (double) completed : 0;
        String avgTimePerJob = String.format("%.1f hrs", avgMinutes / 60.0);
        String totalHoursWorked = formatMinutes(totalMinutes);

        return ProductivityResponse.builder()
                .assignedJobs(assigned.size())
                .inProgress((int) inProgress)
                .completedToday((int) completedToday)
                .efficiency(efficiency)
                .avgTimePerJob(avgTimePerJob)
                .totalHoursWorked(totalHoursWorked)
                .build();
    }

    private long taskMinutes(String startTime, String endTime) {
        if (startTime == null || endTime == null || startTime.isBlank() || endTime.isBlank()) return 0;
        try {
            LocalTime start = LocalTime.parse(startTime.trim(), TASK_TIME_FMT);
            LocalTime end = LocalTime.parse(endTime.trim(), TASK_TIME_FMT);
            long mins = Duration.between(start, end).toMinutes();
            if (mins < 0) mins += 12 * 60;
            return mins;
        } catch (DateTimeParseException e) {
            return 0;
        }
    }

    private String formatMinutes(long minutes) {
        long h = minutes / 60;
        long m = minutes % 60;
        if (h == 0 && m == 0) return "0m";
        if (h == 0) return m + "m";
        return h + "h " + m + "m";
    }

    private Staff resolveStaff(JwtUserPrincipal principal) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        return staffMapper.findByUserId(principal.getUserId())
                .orElseThrow(() -> new ForbiddenException(
                        "No staff record linked to the authenticated user"));
    }

    private boolean ownsJob(JobCard card, Staff staff) {
        return card.getTechnician() != null && card.getTechnician().equals(staff.getName());
    }

    private TechnicianJobResponse toJobResponse(JobCard c) {
        return toJobResponse(c, taskMapper.findByJobCardNo(c.getJobCardRef()));
    }

    private TechnicianJobResponse toJobResponse(JobCard c, List<TechnicianTask> tasks) {
        List<TaskResponse> taskResponses = tasks.stream()
                .map(t -> TaskResponse.builder()
                        .id(t.getTaskRef())
                        .description(t.getDescription())
                        .status(t.getStatus())
                        .startTime(t.getStartTime() != null ? t.getStartTime() : "")
                        .endTime(t.getEndTime() != null ? t.getEndTime() : "")
                        .build())
                .collect(Collectors.toList());

        Vehicle vehicle = c.getVehicleId() == null ? null : vehicleMapper.selectById(c.getVehicleId());
        Customer customer = c.getCustomerId() == null ? null : customerMapper.selectById(c.getCustomerId());

        return TechnicianJobResponse.builder()
                .jobCardNo(c.getJobCardRef())
                .dateOfWork(c.getCreatedAt() != null ? c.getCreatedAt().toLocalDate().toString() : "")
                .startTime("")
            .vehicleBrand(vehicle == null ? "" : nullToEmpty(vehicle.getMake()))
            .vehicleModel(vehicle == null ? "" : nullToEmpty(vehicle.getModel()))
            .plateNumber(vehicle == null ? "" : vehiclePlate(vehicle))
            .customerName(customer == null ? "" : nullToEmpty(customer.getCustomerName()))
            .customerPhone(customer == null ? "" : nullToEmpty(customer.getPhoneNumber()))
                .status(c.getStatus())
                .tasks(taskResponses)
                .notes(c.getNotes() != null ? c.getNotes() : "")
                .build();
    }

    private String vehicleLabel(Vehicle vehicle) {
        return (nullToEmpty(vehicle.getMake()) + " " + nullToEmpty(vehicle.getModel())).trim();
    }

    private String vehiclePlate(Vehicle vehicle) {
        String plate = nullToEmpty(vehicle.getPlateNumber());
        return plate.isBlank() ? nullToEmpty(vehicle.getRegistrationNumber()) : plate;
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
