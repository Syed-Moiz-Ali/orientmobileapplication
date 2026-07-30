package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.customer.model.dto.ActiveServiceResponse;
import com.orient.workshop.customer.model.dto.ServiceStageDto;
import com.orient.workshop.customer.model.dto.ServiceTypeResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.JobCard;
import com.orient.workshop.core.model.entity.ServiceType;
import com.orient.workshop.core.repository.JobCardMapper;
import com.orient.workshop.core.repository.ServiceTypeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ServiceTrackingService {

    private final JobCardMapper jobCardMapper;
    private final ServiceTypeMapper serviceTypeMapper;
    private final CustomerService customerService;

    public ActiveServiceResponse getActiveService(JwtUserPrincipal principal) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId());

        JobCard jobCard = jobCardMapper.findActiveByCustomerId(customer.getId())
                .orElseThrow(() -> new NotFoundException("No active service found"));

        return ActiveServiceResponse.builder()
                .jobCardId(jobCard.getJobCardRef())
                .plateNumber("")
                .vehicleName("")
                .service("")
                .started("")
                .estCompletion("")
                .progressPercent(65)
                .currentStage("Service Work")
                .technicianName(jobCard.getTechnician() != null ? jobCard.getTechnician() : "")
                .stages(List.of(
                        stage("Vehicle Received", "09:00 AM", "done"),
                        stage("Initial Inspection", "09:20 AM", "done"),
                        stage("Parts Preparation", "09:45 AM", "done"),
                        stage("Service Work", "10:15 AM", "inProgress"),
                        stage("Quality Check", null, "pending"),
                        stage("Wash & Cleaning", null, "pending"),
                        stage("Ready for Delivery", null, "pending")
                ))
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

    private ServiceStageDto stage(String name, String time, String status) {
        return ServiceStageDto.builder().name(name).time(time).status(status).build();
    }
}
