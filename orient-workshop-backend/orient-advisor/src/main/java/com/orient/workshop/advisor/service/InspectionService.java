package com.orient.workshop.advisor.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.dto.InspectionDraftResponse;
import com.orient.workshop.advisor.model.dto.InspectionRequest;
import com.orient.workshop.advisor.model.dto.InspectionResponse;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.ForbiddenException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.DateParse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Set;

import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.BookingMapper;
import com.orient.workshop.core.model.entity.Booking;
import com.orient.workshop.core.service.NotificationService;

@Slf4j
@Service
@RequiredArgsConstructor
public class InspectionService {

    private final InspectionMapper inspectionMapper;
    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final BookingMapper bookingMapper;
    private final NotificationService notificationService;
    private final TaskGeneratorService taskGeneratorService;
    private final ObjectMapper objectMapper;

    private static final Set<String> VALID_JOB_CARD_STATUSES = Set.of(
            "inProgress", "pendingApproval", "qualityCheck", "completed",
            "cancelled", "waitingParts", "pending", "awaitingSupervisor",
            "vehicleReceived", "waitingCustomerApproval", "delivered", "qualityCheckPassed");

    @Transactional
    public InspectionResponse createInspection(JwtUserPrincipal principal, InspectionRequest req) {
        Customer customer = resolveCustomer(principal, req);
        Vehicle vehicle = null;

        if (req.getVehicle() != null && customer != null) {
            // Fix: reuse an existing vehicle by plate/VIN instead of creating
            // a duplicate row on every intake.
            String reg = req.getVehicle().getRegistrationNumber();
            String vin = req.getVehicle().getVin();
            vehicle = vehicleMapper.findByRegOrVin(reg, vin).orElse(null);
            if (vehicle == null) {
                vehicle = Vehicle.builder()
                        .customerId(customer.getId())
                        .branchId(principal != null ? principal.getBranchId() : null)
                        .registrationNumber(reg)
                        .vin(vin)
                        .make(req.getVehicle().getMake())
                        .model(req.getVehicle().getModel())
                        .modelYear(req.getVehicle().getModelYear())
                        .vehicleColor(req.getVehicle().getVehicleColor())
                        .engineNumber(req.getVehicle().getEngineNumber())
                        .engineCapacity(req.getVehicle().getEngineCapacity())
                        .insuranceProvider(req.getVehicle().getInsuranceProvider())
                        .policyNumber(req.getVehicle().getPolicyNumber())
                        .build();
                vehicleMapper.insert(vehicle);
            } else if (vehicle.getCustomerId() == null) {
                vehicle.setCustomerId(customer.getId());
                vehicleMapper.updateById(vehicle);
            }
        }

        // Fix: reject unknown statuses before they hit the ENUM column (409).
        String status = req.getStatus() != null ? req.getStatus() : "pending";
        if (!VALID_JOB_CARD_STATUSES.contains(status)) {
            throw new BadRequestException("Invalid status: " + status
                    + ". Allowed: " + String.join(", ", VALID_JOB_CARD_STATUSES));
        }

        String jcRef = IdGenerator.shortRef("JC");
        JobCard jobCard = JobCard.builder()
                .jobCardRef(jcRef)
                .customerId(customer.getId())
                .branchId(principal != null ? principal.getBranchId() : null)
                .vehicleId(vehicle != null ? vehicle.getId() : null)
                .status(status)
                .technician(req.getTechnician())
                .tag(req.getTag())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(DateParse.parseLocalDateTime(req.getEstimatedDelivery(), "estimatedDelivery"))
                .build();
        jobCardMapper.insert(jobCard);

        String insRef = IdGenerator.shortRef("INS");
        String sectionsJson = toJson(req.getSections());

        Inspection inspection = Inspection.builder()
                .inspectionRef(insRef)
                .jobCardId(jobCard.getId())
                .referenceNumber(req.getReferenceNumber())
                .placeOfSupply(req.getPlaceOfSupply())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(DateParse.parseLocalDateTime(req.getEstimatedDelivery(), "estimatedDelivery"))
                .notifyOwnerSmsEmail(req.getNotifyOwnerSmsEmail())
                .tag(req.getTag())
                .sections(sectionsJson)
                .advisorId(principal != null ? principal.getUserId() : null)
                .build();
        inspectionMapper.insert(inspection);

        // Phase 1 — link to booking if intake started from an assigned booking
        if (req.getBookingId() != null && !req.getBookingId().isBlank()) {
            linkBooking(req.getBookingId(), jobCard.getId(), principal);
        }

        // Phase 3 — inspection items marked fair/poor become tracked work items
        taskGeneratorService.generateForJobCard(jobCard.getId());

        // FIX (audit QA BUG-014): return the numeric DB id — update/draft/summary
        // endpoints all resolve ids via selectById(Long); the previous INS-<hex>
        // ref could not be used with any of them.
        return InspectionResponse.builder().id(String.valueOf(inspection.getId())).build();
    }

    private void linkBooking(String bookingId, Long jobCardId, JwtUserPrincipal principal) {
        try {
            Long id = Long.parseLong(bookingId);
            Booking booking = bookingMapper.selectById(id);
            if (booking == null) return;
            if (principal != null && principal.getBranchId() != null
                    && booking.getBranchId() != null && !principal.getBranchId().equals(booking.getBranchId())) {
                return;
            }
            booking.setJobCardId(jobCardId);
            booking.setStatus("confirmed");
            bookingMapper.updateById(booking);
            if (principal != null && principal.getUserId() != null) {
                notificationService.emit(principal.getUserId(), booking.getBranchId(),
                        "bookingConfirmed", "Intake started",
                        "Job card created from booking " + booking.getBookingRef() + ".");
            }
        } catch (NumberFormatException e) {
            log.warn("Invalid bookingId '{}' ignored", bookingId);
        }
    }

    @Transactional
    public void updateInspection(JwtUserPrincipal principal, Long id, InspectionRequest req) {
        Inspection inspection = inspectionMapper.selectById(id);
        if (inspection == null) throw new NotFoundException("Inspection not found");
        verifyDraftOwnership(principal, id);

        if (req.getSections() != null) {
            inspection.setSections(toJson(req.getSections()));
        }
        if (req.getCustomerRequests() != null) inspection.setCustomerRequests(req.getCustomerRequests());
        if (req.getGarageRecommendations() != null) inspection.setGarageRecommendations(req.getGarageRecommendations());
        if (req.getReferenceNumber() != null) inspection.setReferenceNumber(req.getReferenceNumber());
        if (req.getPlaceOfSupply() != null) inspection.setPlaceOfSupply(req.getPlaceOfSupply());
        if (req.getEstimatedDelivery() != null) {
            inspection.setEstimatedDelivery(DateParse.parseLocalDateTime(req.getEstimatedDelivery(), "estimatedDelivery"));
        }
        if (req.getNotifyOwnerSmsEmail() != null) inspection.setNotifyOwnerSmsEmail(req.getNotifyOwnerSmsEmail());
        if (req.getTag() != null) inspection.setTag(req.getTag());
        if (inspection.getIsDraft() != null && inspection.getIsDraft()) {
            inspection.setIsDraft(false);
        }
        inspectionMapper.updateById(inspection);

        // Newly flagged fair/poor items become trackable work items
        if (inspection.getJobCardId() != null) {
            taskGeneratorService.generateForJobCard(inspection.getJobCardId());
        }
    }

    public InspectionDraftResponse getDraft(JwtUserPrincipal principal, Long id) {
        verifyDraftOwnership(principal, id);
        Inspection draft = inspectionMapper.findDraftById(id)
                .orElseThrow(() -> new NotFoundException("Draft not found"));
        return toDraftResponse(draft);
    }

    @Transactional
    public void saveDraft(JwtUserPrincipal principal, Long id, InspectionRequest req) {
        Inspection inspection = inspectionMapper.selectById(id);
        if (inspection == null) throw new NotFoundException("Inspection not found");
        verifyDraftOwnership(principal, id);
        if (req.getSections() != null) {
            inspection.setSections(toJson(req.getSections()));
        }
        inspection.setCustomerRequests(req.getCustomerRequests());
        inspection.setGarageRecommendations(req.getGarageRecommendations());
        inspection.setIsDraft(true);
        inspectionMapper.updateById(inspection);
        if (principal != null && principal.getUserId() != null) {
            // Persisted draft ownership (was an in-memory map).
            inspection.setAdvisorId(principal.getUserId());
            inspectionMapper.updateById(inspection);
        }
    }

    @Transactional
    public void deleteDraft(JwtUserPrincipal principal, Long id) {
        verifyDraftOwnership(principal, id);
        Inspection draft = inspectionMapper.findDraftById(id)
                .orElseThrow(() -> new NotFoundException("Draft not found"));
        inspectionMapper.deleteById(draft.getId());
    }

    private Customer resolveCustomer(JwtUserPrincipal principal, InspectionRequest req) {
        if (req.getCustomerId() != null && !req.getCustomerId().isBlank()) {
            Long customerId;
            try {
                customerId = Long.parseLong(req.getCustomerId());
            } catch (NumberFormatException e) {
                throw new BadRequestException("Invalid customerId '" + req.getCustomerId() + "'");
            }
            Customer customer = customerMapper.selectById(customerId);
            if (customer == null) {
                throw new BadRequestException("Customer not found with id: " + customerId);
            }
            return customer;
        }
        if (req.getCustomer() != null) {
            String phone = req.getCustomer().getPhoneNumber();
            // Seamless flow — reuse the existing customer (e.g. the one linked
            // to the booking / customer-app account) by phone instead of
            // creating a duplicate row. Otherwise approvals and job history
            // would never surface in the customer app.
            if (phone != null && !phone.isBlank()) {
                var existing = customerMapper.findByPhone(phone);
                if (existing.isPresent()) {
                    Customer existingCustomer = existing.get();
                    if (existingCustomer.getBranchId() == null && principal != null) {
                        existingCustomer.setBranchId(principal.getBranchId());
                        customerMapper.updateById(existingCustomer);
                    }
                    return existingCustomer;
                }
            }
            Customer customer = Customer.builder()
                    .branchId(principal != null ? principal.getBranchId() : null)
                    .customerName(req.getCustomer().getCustomerName())
                    .phoneNumber(req.getCustomer().getPhoneNumber())
                    .email(req.getCustomer().getEmail())
                    .customerGroup(req.getCustomer().getCustomerGroup())
                    .gender(req.getCustomer().getGender())
                    .address(req.getCustomer().getAddress())
                    .taxNumber(req.getCustomer().getTaxNumber())
                    .occupation(req.getCustomer().getOccupation())
                    .organisation(req.getCustomer().getOrganisation())
                    .source(req.getCustomer().getSource())
                    .isB2b(req.getCustomer().getIsB2B())
                    .build();
            customerMapper.insert(customer);
            return customer;
        }
        throw new BadRequestException("customerId is required when creating a job card. " +
                "Provide customerId or customer details in the request");
    }

    /**
     * Persisted ownership check (was an in-memory map that emptied on restart,
     * after which ANY advisor could read/delete ANY draft).
     */
    private void verifyDraftOwnership(JwtUserPrincipal principal, Long id) {
        if (principal == null || principal.getUserId() == null) {
            throw new ForbiddenException("Authenticated user not found");
        }
        Inspection draft = inspectionMapper.selectById(id);
        if (draft == null) {
            throw new NotFoundException("Inspection not found with id: " + id);
        }
        if (draft.getAdvisorId() != null && !draft.getAdvisorId().equals(principal.getUserId())) {
            throw new ForbiddenException("Inspection does not belong to the current user");
        }
    }

    private String toJson(Object value) {
        if (value == null) return null;
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            log.error("Failed to serialize sections JSON", e);
            throw new BadRequestException("Invalid sections payload: " + e.getOriginalMessage());
        }
    }

    private InspectionDraftResponse toDraftResponse(Inspection i) {
        Map<String, Map<String, Object>> sections = null;
        try {
            if (i.getSections() != null)
                sections = objectMapper.readValue(i.getSections(), Map.class);
        } catch (JsonProcessingException e) {
            log.error("Failed to deserialize sections JSON for inspection {}", i.getId(), e);
            throw new BadRequestException("Stored sections payload is corrupt");
        }
        return InspectionDraftResponse.builder()
                .id(String.valueOf(i.getId()))
                .jobCardId(String.valueOf(i.getJobCardId()))
                .referenceNumber(i.getReferenceNumber())
                .placeOfSupply(i.getPlaceOfSupply())
                .customerRequests(i.getCustomerRequests())
                .garageRecommendations(i.getGarageRecommendations())
                .estimatedDelivery(i.getEstimatedDelivery() != null ? i.getEstimatedDelivery().toString() : null)
                .notifyOwnerSmsEmail(i.getNotifyOwnerSmsEmail())
                .tag(i.getTag())
                .isDraft(i.getIsDraft())
                .sections(sections)
                .build();
    }
}
