package com.orient.workshop.owner.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Branch;
import com.orient.workshop.owner.service.BranchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Branches")
@RestController
@RequestMapping("/branches")
@RequiredArgsConstructor
public class BranchController {

    private final BranchService branchService;

    @GetMapping
    public ApiResponse<List<Branch>> getAll() {
        return ApiResponse.success(branchService.getAll());
    }

    @PostMapping
    public ApiResponse<Branch> create(@Valid @RequestBody Branch req) {
        return ApiResponse.success(branchService.create(req));
    }

    @PutMapping("/{id}")
    public ApiResponse<Branch> update(@PathVariable Long id, @RequestBody Branch req) {
        return ApiResponse.success(branchService.update(id, req));
    }
}

