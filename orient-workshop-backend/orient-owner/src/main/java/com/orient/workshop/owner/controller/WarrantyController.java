package com.orient.workshop.owner.controller;

import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.Warranty;
import com.orient.workshop.core.repository.VehicleMapper;
import com.orient.workshop.core.repository.WarrantyMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/warranties")
@RequiredArgsConstructor
public class WarrantyController {

    private final WarrantyMapper warrantyMapper;
    private final VehicleMapper vehicleMapper;

    @GetMapping
    public ApiResponse<List<Warranty>> list(@RequestParam(required = false) Long vehicleId) {
        if (vehicleId != null) {
            return ApiResponse.success(warrantyMapper.findByVehicleId(vehicleId));
        }
        return ApiResponse.success(warrantyMapper.selectList(null));
    }

    @PostMapping
    public ApiResponse<Warranty> create(@RequestBody Warranty req) {
        if (req.getVehicleId() == null || vehicleMapper.selectById(req.getVehicleId()) == null) {
            throw new BadRequestException("A valid vehicleId is required");
        }
        if (req.getEndDate() != null && req.getStartDate() != null
                && req.getEndDate().isBefore(req.getStartDate())) {
            throw new BadRequestException("endDate must be after startDate");
        }
        Warranty warranty = Warranty.builder()
                .vehicleId(req.getVehicleId())
                .warrantyRef(IdGenerator.shortRef("WR"))
                .type(req.getType() != null ? req.getType() : "manufacturer")
                .startDate(req.getStartDate())
                .endDate(req.getEndDate())
                .terms(req.getTerms() != null ? req.getTerms() : "")
                .build();
        warrantyMapper.insert(warranty);
        return ApiResponse.success(warranty);
    }
}
