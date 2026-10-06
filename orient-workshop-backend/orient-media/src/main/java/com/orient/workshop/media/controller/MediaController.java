package com.orient.workshop.media.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.media.model.dto.MediaNoteRequest;
import com.orient.workshop.media.model.entity.MediaAsset;
import com.orient.workshop.media.service.MediaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Tag(name = "Media")
@RestController
@RequiredArgsConstructor
public class MediaController {

    private final MediaService mediaService;

    @PostMapping(value = "/repair-orders/{id}/media", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<Map<String, String>> uploadMedia(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "itemId", required = false) String itemId,
            @RequestParam(value = "type", defaultValue = "photo") String type) {
        // CR-3: per-tenant storage subfolder (branch when the user has one, else user-scoped)
        String tenant = principal != null && principal.getBranchId() != null
                ? "branch-" + principal.getBranchId()
                : principal != null ? "user-" + principal.getUserId() : "default";
        Map<String, String> result = mediaService.uploadMedia(tenant, "repair-orders", id, file, itemId, type,
                principal != null ? principal.getUserId() : null);
        return ApiResponse.success(result);
    }

    @GetMapping("/repair-orders/{id}/media")
    public ApiResponse<List<MediaAsset>> listRepairOrderMedia(@PathVariable String id) {
        return ApiResponse.success(mediaService.list("repair-orders", id));
    }

    @PostMapping(value = "/inspections/{id}/media", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<Map<String, String>> uploadInspectionMedia(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "itemId", required = false) String itemId,
            @RequestParam(value = "type", defaultValue = "photo") String type) {
        String tenant = principal != null && principal.getBranchId() != null
                ? "branch-" + principal.getBranchId()
                : principal != null ? "user-" + principal.getUserId() : "default";
        Map<String, String> result = mediaService.uploadMedia(tenant, "inspections", id, file, itemId, type,
                principal != null ? principal.getUserId() : null);
        return ApiResponse.success(result);
    }

    @GetMapping("/inspections/{id}/media")
    public ApiResponse<List<MediaAsset>> listInspectionMedia(@PathVariable String id) {
        return ApiResponse.success(mediaService.list("inspections", id));
    }

    /** Registers the free-text notes for an inspection's checkpoints. */
    @PostMapping("/inspections/{id}/notes")
    public ApiResponse<Integer> saveInspectionNotes(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestBody MediaNoteRequest req) {
        return ApiResponse.success(mediaService.recordNotes(tenant(principal), "inspections", id, req,
                principal != null ? principal.getUserId() : null));
    }

    @PostMapping("/repair-orders/{id}/notes")
    public ApiResponse<Integer> saveRepairOrderNotes(
            @AuthenticationPrincipal JwtUserPrincipal principal,
            @PathVariable String id,
            @RequestBody MediaNoteRequest req) {
        return ApiResponse.success(mediaService.recordNotes(tenant(principal), "repair-orders", id, req,
                principal != null ? principal.getUserId() : null));
    }

    private String tenant(JwtUserPrincipal principal) {
        if (principal == null) return "default";
        if (principal.getBranchId() != null) return "branch-" + principal.getBranchId();
        return "user-" + principal.getUserId();
    }
}
