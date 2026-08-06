package com.orient.workshop.supervisor.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.*;
import com.orient.workshop.core.repository.*;
import com.orient.workshop.core.service.NotificationService;
import com.orient.workshop.owner.service.InvoiceService;
import com.orient.workshop.supervisor.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Phase 1/3 — supervisor routing: unassigned bookings & breakdowns are queued
 * here; supervisor assigns an advisor. Also the completion-review gate:
 * jobs whose work items are all completed are approved or sent back.
 */
@Service
@RequiredArgsConstructor
public class SupervisorQueueService {

    private static final DateTimeFormatter DATE_TIME_FMT =
            DateTimeFormatter.ofPattern("d MMM yyyy · hh:mm a");

    private final BookingMapper bookingMapper;
    private final BreakdownMapper breakdownMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final StaffMapper staffMapper;
    private final JobCardMapper jobCardMapper;
    private final TechnicianTaskMapper taskMapper;
    private final NotificationService notificationService;
    private final InvoiceService invoiceService;
    private final com.orient.workshop.core.service.ActivityService activityService;
    private final com.orient.workshop.core.service.WebhookService webhookService;

    // ---------- Booking queue ----------

    public List<BookingQueueResponse> getBookingQueue() {
        List<Booking> bookings = bookingMapper.findUnassigned();
        if (bookings.isEmpty()) return List.of();
        Map<Long, Customer> customers = customersByIds(bookings.stream()
                .map(Booking::getCustomerId).collect(Collectors.toSet()));
        return bookings.stream().map(b -> {
            Customer c = customers.get(b.getCustomerId());
            return BookingQueueResponse.builder()
                    .id(b.getId())
                    .bookingRef(b.getBookingRef())
                    .customerName(c != null ? c.getCustomerName() : "")
                    .phone(c != null ? c.getPhoneNumber() : "")
                    .vehicleName(b.getVehicleName() != null ? b.getVehicleName() : "")
                    .plateNumber(b.getPlateNumber() != null ? b.getPlateNumber() : "")
                    .serviceType(b.getServiceType() != null ? b.getServiceType() : "")
                    .bookingDate(b.getBookingDate() != null ? b.getBookingDate().format(DATE_TIME_FMT) : "")
                    .dateKey(b.getBookingDate() != null ? b.getBookingDate().toLocalDate().toString() : "")
                    .notes(b.getNotes())
                    .status(b.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    @Transactional
    public void assignBooking(Long bookingId, AssignAdvisorRequest req) {
        Staff advisor = resolveAdvisor(req);
        Booking booking = bookingMapper.selectById(bookingId);
        if (booking == null) throw new NotFoundException("Booking not found");

        booking.setAdvisorId(advisor.getId());
        booking.setStatus("confirmed");
        bookingMapper.updateById(booking);

        Customer customer = booking.getCustomerId() != null
                ? customerMapper.selectById(booking.getCustomerId()) : null;
        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), booking.getBranchId(),
                    "bookingAssigned", "Booking confirmed",
                    "Your booking " + booking.getBookingRef() + " for " + booking.getServiceType()
                            + " is confirmed with advisor " + advisor.getName() + ".");
        }
        if (advisor.getUserId() != null) {
            notificationService.emit(advisor.getUserId(), advisor.getBranchId(),
                    "bookingAssigned", "New booking assigned",
                    booking.getServiceType() + " · " + booking.getVehicleName()
                            + (booking.getPlateNumber() != null && !booking.getPlateNumber().isBlank()
                            ? " · " + booking.getPlateNumber() : "")
                            + (booking.getBookingDate() != null
                            ? " · " + booking.getBookingDate().format(DATE_TIME_FMT) : ""));
        }
    }

    // ---------- Breakdown queue ----------

    public List<BreakdownQueueResponse> getBreakdownQueue() {
        List<Breakdown> breakdowns = breakdownMapper.findUnassigned();
        if (breakdowns.isEmpty()) return List.of();
        Map<Long, Customer> customers = customersByIds(breakdowns.stream()
                .map(Breakdown::getCustomerId).collect(Collectors.toSet()));
        return breakdowns.stream().map(b -> {
            Customer c = customers.get(b.getCustomerId());
            return BreakdownQueueResponse.builder()
                    .id(b.getId())
                    .breakdownRef(b.getBreakdownRef())
                    .customerName(c != null ? c.getCustomerName() : "")
                    .phone(c != null ? c.getPhoneNumber() : "")
                    .issue(b.getIssue())
                    .vehicleName(b.getVehicleName() != null ? b.getVehicleName() : "")
                    .vehiclePlate(b.getVehiclePlate() != null ? b.getVehiclePlate() : "")
                    .location(b.getLocation())
                    .status(b.getStatus())
                    .build();
        }).collect(Collectors.toList());
    }

    @Transactional
    public void assignBreakdown(Long breakdownId, AssignAdvisorRequest req) {
        Staff advisor = resolveAdvisor(req);
        Breakdown breakdown = breakdownMapper.selectById(breakdownId);
        if (breakdown == null) throw new NotFoundException("Breakdown not found");

        breakdown.setAdvisorId(advisor.getId());
        breakdown.setStatus("dispatched");
        breakdownMapper.updateById(breakdown);

        Customer customer = breakdown.getCustomerId() != null
                ? customerMapper.selectById(breakdown.getCustomerId()) : null;
        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), null,
                    "breakdownAssigned", "Breakdown assistance on the way",
                    "Advisor " + advisor.getName() + " is handling your request " + breakdown.getBreakdownRef() + ".");
        }
        if (advisor.getUserId() != null) {
            notificationService.emit(advisor.getUserId(), advisor.getBranchId(),
                    "breakdownAssigned", "Breakdown assigned to you",
                    breakdown.getIssue() + (breakdown.getLocation() != null
                            ? " · " + breakdown.getLocation() : ""));
        }
    }

    // ---------- Completion review ----------

    public List<AwaitingCompletionResponse> getAwaitingCompletion() {
        List<JobCard> cards = jobCardMapper.findAwaitingSupervisor();
        if (cards.isEmpty()) return List.of();
        Map<Long, Customer> customers = customersByIds(cards.stream()
                .map(JobCard::getCustomerId).collect(Collectors.toSet()));
        Map<Long, Vehicle> vehicles = cards.stream()
                .map(JobCard::getVehicleId).filter(java.util.Objects::nonNull).collect(Collectors.toSet()).isEmpty()
                ? Map.of()
                : vehicleMapper.selectBatchIds(cards.stream()
                        .map(JobCard::getVehicleId).filter(java.util.Objects::nonNull).collect(Collectors.toSet()))
                .stream().collect(Collectors.toMap(Vehicle::getId, Function.identity()));

        return cards.stream().map(c -> {
            List<TechnicianTask> tasks = taskMapper.findByJobCardNo(c.getJobCardRef());
            long done = tasks.stream().filter(t -> "completed".equals(t.getStatus())).count();
            return AwaitingCompletionResponse.builder()
                    .jobCardId(c.getId())
                    .jobCardRef(c.getJobCardRef())
                    .customerName(customers.get(c.getCustomerId()) != null
                            ? customers.get(c.getCustomerId()).getCustomerName() : "")
                    .vehicleInfo(vehicleInfo(vehicles.get(c.getVehicleId())))
                    .technician(c.getTechnician() != null ? c.getTechnician() : "")
                    .done((int) done)
                    .total(tasks.size())
                    .updatedAt(c.getUpdatedAt() != null ? c.getUpdatedAt().format(DATE_TIME_FMT) : "")
                    .items(tasks.stream().map(t -> AwaitingCompletionResponse.WorkItemDetail.builder()
                            .id(t.getId())
                            .taskRef(t.getTaskRef())
                            .description(t.getDescription())
                            .itemType(t.getItemType() != null ? t.getItemType() : "WORK")
                            .status(t.getStatus())
                            .empId(t.getEmpId())
                            .empName(empName(t.getEmpId()))
                            .startTime(t.getStartTime() != null ? t.getStartTime() : "")
                            .endTime(t.getEndTime() != null ? t.getEndTime() : "")
                            .qty(t.getQty() != null ? t.getQty() : 1)
                            .rate(t.getRate() != null ? t.getRate() : 0)
                            .rejectReason(t.getRejectReason() != null ? t.getRejectReason() : "")
                            .build()).collect(Collectors.toList()))
                    .build();
        }).collect(Collectors.toList());
    }

    @Transactional
    public void approveCompletion(Long jobCardId) {
        JobCard card = requireAwaiting(jobCardId);
        card.setStatus("completed");
        jobCardMapper.updateById(card);

        Customer customer = card.getCustomerId() != null ? customerMapper.selectById(card.getCustomerId()) : null;
        if (customer != null && customer.getUserId() != null) {
            notificationService.emit(customer.getUserId(), card.getBranchId(),
                    "completionApproved", "Your car is ready!",
                    card.getJobCardRef() + " has been checked and approved. You can collect your car.");
        }

        // Phase 4 — invoice is raised automatically from the repair order totals.
        invoiceService.createFromJobCard(jobCardId);

        // P1: activity feed writer.
        activityService.log("invoice", "Invoice raised",
                "Invoice for completed job " + card.getJobCardRef(), null);

        // P3: outbound webhook (job.completed).
        webhookService.dispatch("job.completed", Map.of("jobCardRef", card.getJobCardRef()));
    }

    @Transactional
    public void rejectCompletion(Long jobCardId, RejectCompletionRequest req) {
        JobCard card = requireAwaiting(jobCardId);
        String reason = req != null && req.getReason() != null ? req.getReason().trim() : "";
        if (reason.isBlank()) reason = "Work needs revision";

        card.setStatus("inProgress");
        jobCardMapper.updateById(card);

        List<TechnicianTask> tasks = taskMapper.findByJobCardNo(card.getJobCardRef());
        for (TechnicianTask t : tasks) {
            if (!"completed".equals(t.getStatus())) continue;
            t.setStatus("pending");
            t.setRejectReason(reason);
            taskMapper.updateById(t);
            Staff tech = t.getEmpId() != null ? staffMapper.findByEmpId(t.getEmpId()).orElse(null) : null;
            if (tech != null && tech.getUserId() != null) {
                notificationService.emit(tech.getUserId(), card.getBranchId(),
                        "completionRejected", "Work sent back for revision",
                        card.getJobCardRef() + " · " + t.getDescription() + " — " + reason);
            }
        }
    }

    @Transactional
    public void qcReview(String jobCardRef, QcReviewRequest req) {
        JobCard card = jobCardMapper.selectOne(new LambdaQueryWrapper<JobCard>().eq(JobCard::getJobCardRef, jobCardRef));
        if (card == null) {
            throw new NotFoundException("Job card not found");
        }

        // Fix: 'qualityCheckPassed' is now a valid ENUM value (V6) — the QC
        // approve action previously crashed with 409 on every call.
        if (!List.of("awaitingSupervisor", "qualityCheck").contains(card.getStatus())) {
            throw new BadRequestException("QC review requires a job awaiting completion (current: " + card.getStatus() + ")");
        }

        if ("approve".equalsIgnoreCase(req.getAction())) {
            card.setStatus("qualityCheckPassed");
        } else if ("reject".equalsIgnoreCase(req.getAction())) {
            card.setStatus("inProgress");
        } else {
            throw new BadRequestException("Invalid action. Must be 'approve' or 'reject'.");
        }

        jobCardMapper.updateById(card);
    }

    // ---------- helpers ----------

    public List<AssignableStaffResponse> getAssignableAdvisors() {
        List<Staff> advisors = staffMapper.selectList(
                new LambdaQueryWrapper<Staff>()
                        .eq(Staff::getRole, "advisor")
                        .eq(Staff::getIsActive, true)
                        .orderByAsc(Staff::getName));
        return AssignableStaffResponse.ofList(advisors);
    }

    private Staff resolveAdvisor(AssignAdvisorRequest req) {
        if (req == null || req.getAdvisorId() == null) {
            throw new BadRequestException("advisorId is required");
        }
        Staff advisor = staffMapper.selectById(req.getAdvisorId());
        if (advisor == null) {
            throw new BadRequestException("Advisor not found with id: " + req.getAdvisorId());
        }
        return advisor;
    }

    private JobCard requireAwaiting(Long jobCardId) {
        JobCard card = jobCardMapper.selectById(jobCardId);
        if (card == null) throw new NotFoundException("Job card not found");
        if (!"awaitingSupervisor".equals(card.getStatus())) {
            throw new BadRequestException("Job card is not awaiting supervisor review");
        }
        return card;
    }

    private Map<Long, Customer> customersByIds(java.util.Set<Long> ids) {
        if (ids.isEmpty()) return Map.of();
        return customerMapper.selectBatchIds(ids).stream()
                .collect(Collectors.toMap(Customer::getId, Function.identity()));
    }

    private String vehicleInfo(Vehicle v) {
        if (v == null) return "";
        return ((v.getMake() != null ? v.getMake() : "") + " " + (v.getModel() != null ? v.getModel() : "")).trim();
    }

    private String empName(String empId) {
        if (empId == null || empId.isBlank()) return "";
        return staffMapper.findByEmpId(empId).map(Staff::getName).orElse("");
    }
}
