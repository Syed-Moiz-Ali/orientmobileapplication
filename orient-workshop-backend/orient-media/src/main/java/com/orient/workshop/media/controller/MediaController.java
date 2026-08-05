package com.orient.workshop.media.controller;
import io.swagger.v3.oas.annotations.tags.Tag;


import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.media.service.MediaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
        Map<String, String> result = mediaService.uploadMedia(tenant, "repair-orders", id, file, itemId, type);
        return ApiResponse.success(result);
    }
}
