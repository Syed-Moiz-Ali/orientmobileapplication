package com.orient.workshop.customer.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.customer.model.dto.AddVehicleRequest;
import com.orient.workshop.customer.model.dto.VehicleResponse;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.model.entity.Vehicle;
import com.orient.workshop.core.repository.VehicleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VehicleService {

    private final VehicleMapper vehicleMapper;
    private final CustomerService customerService;

    public List<VehicleResponse> getVehicles(JwtUserPrincipal principal) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());
        List<Vehicle> vehicles = principal.getBranchId() != null
                ? vehicleMapper.findByCustomerIdAndBranch(customer.getId(), principal.getBranchId())
                : vehicleMapper.findByCustomerId(customer.getId());
        return vehicles.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public VehicleResponse addVehicle(JwtUserPrincipal principal, AddVehicleRequest req) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());

        Vehicle vehicle = Vehicle.builder()
                .customerId(customer.getId())
                .branchId(principal.getBranchId())
                .make(req.getBrand())
                .model(req.getModel())
                .plateNumber(req.getPlateNumber())
                .vin(req.getVin())
                .vehicleColor(req.getColor())
                .modelYear(req.getYear())
                .mileage(req.getMileage())
                .lastService(req.getLastService())
                .nextDue(req.getNextDue())
                .healthScore(req.getHealthScore())
                .build();
        vehicleMapper.insert(vehicle);

        return toResponse(vehicle);
    }

    @Transactional
    public VehicleResponse updateVehicle(JwtUserPrincipal principal, Long id, AddVehicleRequest req) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());
        Vehicle vehicle = vehicleMapper.selectById(id);
        if (vehicle == null || !vehicle.getCustomerId().equals(customer.getId())) {
            throw new NotFoundException("Vehicle not found with id: " + id);
        }
        vehicle.setMake(req.getBrand());
        vehicle.setModel(req.getModel());
        vehicle.setPlateNumber(req.getPlateNumber());
        vehicle.setVin(req.getVin());
        vehicle.setVehicleColor(req.getColor());
        vehicle.setModelYear(req.getYear());
        vehicle.setMileage(req.getMileage());
        vehicle.setLastService(req.getLastService());
        vehicle.setNextDue(req.getNextDue());
        vehicle.setHealthScore(req.getHealthScore());
        vehicleMapper.updateById(vehicle);

        return toResponse(vehicle);
    }

    @Transactional
    public void deleteVehicle(JwtUserPrincipal principal, Long id) {
        Customer customer = customerService.findOrCreateCustomer(principal.getUserId(), principal.getBranchId());
        Vehicle vehicle = vehicleMapper.selectById(id);
        if (vehicle == null || !vehicle.getCustomerId().equals(customer.getId())) {
            throw new NotFoundException("Vehicle not found with id: " + id);
        }
        vehicleMapper.deleteById(id);
    }

    private VehicleResponse toResponse(Vehicle v) {
        return VehicleResponse.builder()
                .id(String.valueOf(v.getId()))
                .brand(v.getMake())
                .model(v.getModel())
                .plateNumber(v.getPlateNumber())
                .vin(v.getVin())
                .color(v.getVehicleColor())
                .year(v.getModelYear() != null ? v.getModelYear() : 0)
                .mileage(v.getMileage())
                .lastService(v.getLastService())
                .nextDue(v.getNextDue())
                .healthScore(v.getHealthScore() != null ? v.getHealthScore() : 100)
                .build();
    }
}
