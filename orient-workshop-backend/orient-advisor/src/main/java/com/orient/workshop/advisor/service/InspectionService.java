package com.orient.workshop.advisor.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.orient.workshop.advisor.model.dto.InspectionDraftResponse;
import com.orient.workshop.advisor.model.dto.InspectionRequest;
import com.orient.workshop.advisor.model.dto.InspectionResponse;
import com.orient.workshop.advisor.model.entity.Inspection;
import com.orient.workshop.advisor.repository.InspectionMapper;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Map;

import com.orient.workshop.core.repository.JobCardMapper;

@Service
@RequiredArgsConstructor
public class InspectionService {

    private final InspectionMapper inspectionMapper;
    private final JobCardMapper jobCardMapper;
    private final CustomerMapper customerMapper;
    private final VehicleMapper vehicleMapper;
    private final ObjectMapper objectMapper;

    @Transactional
    public InspectionResponse createInspection(InspectionRequest req) {
        Customer customer = null;
        Vehicle vehicle = null;

        if (req.getCustomer() != null) {
            customer = Customer.builder()
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
        }

        if (req.getVehicle() != null && customer != null) {
            vehicle = Vehicle.builder()
                    .customerId(customer.getId())
                    .registrationNumber(req.getVehicle().getRegistrationNumber())
                    .vin(req.getVehicle().getVin())
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
        }

        String jcRef = "JC-" + LocalDate.now().getYear() + "-" + String.format("%03d", System.currentTimeMillis() % 1000);
        JobCard jobCard = JobCard.builder()
                .jobCardRef(jcRef)
                .customerId(customer != null ? customer.getId() : null)
                .vehicleId(vehicle != null ? vehicle.getId() : null)
                .status(req.getStatus() != null ? req.getStatus() : "pending")
                .technician(req.getTechnician())
                .tag(req.getTag())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(req.getEstimatedDelivery() != null ? java.time.LocalDateTime.parse(req.getEstimatedDelivery()) : null)
                .build();
        jobCardMapper.insert(jobCard);

        String insRef = "INS-" + String.format("%03d", System.currentTimeMillis() % 1000);
        String sectionsJson = null;
        try {
            if (req.getSections() != null) sectionsJson = objectMapper.writeValueAsString(req.getSections());
        } catch (JsonProcessingException ignored) {}

        Inspection inspection = Inspection.builder()
                .inspectionRef(insRef)
                .jobCardId(jobCard.getId())
                .referenceNumber(req.getReferenceNumber())
                .placeOfSupply(req.getPlaceOfSupply())
                .customerRequests(req.getCustomerRequests())
                .garageRecommendations(req.getGarageRecommendations())
                .estimatedDelivery(req.getEstimatedDelivery() != null ? java.time.LocalDateTime.parse(req.getEstimatedDelivery()) : null)
                .notifyOwnerSmsEmail(req.getNotifyOwnerSmsEmail())
                .tag(req.getTag())
                .sections(sectionsJson)
                .build();
        inspectionMapper.insert(inspection);

        return InspectionResponse.builder().id(insRef).build();
    }

    public InspectionDraftResponse getDraft(Long id) {
        Inspection draft = inspectionMapper.findDraftById(id)
                .orElseThrow(() -> new NotFoundException("Draft not found"));
        return toDraftResponse(draft);
    }

    @Transactional
    public void saveDraft(Long id, InspectionRequest req) {
        Inspection inspection = inspectionMapper.selectById(id);
        if (inspection == null) throw new NotFoundException("Inspection not found");
        try {
            if (req.getSections() != null)
                inspection.setSections(objectMapper.writeValueAsString(req.getSections()));
        } catch (JsonProcessingException ignored) {}
        inspection.setCustomerRequests(req.getCustomerRequests());
        inspection.setGarageRecommendations(req.getGarageRecommendations());
        inspection.setIsDraft(true);
        inspectionMapper.updateById(inspection);
    }

    @Transactional
    public void deleteDraft(Long id) {
        Inspection draft = inspectionMapper.findDraftById(id)
                .orElseThrow(() -> new NotFoundException("Draft not found"));
        inspectionMapper.deleteById(draft.getId());
    }

    private InspectionDraftResponse toDraftResponse(Inspection i) {
        Map<String, Map<String, Object>> sections = null;
        try {
            if (i.getSections() != null)
                sections = objectMapper.readValue(i.getSections(), Map.class);
        } catch (JsonProcessingException ignored) {}
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
