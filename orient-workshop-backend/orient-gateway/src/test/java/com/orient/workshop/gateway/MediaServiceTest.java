package com.orient.workshop.gateway;

import com.orient.workshop.media.service.MediaService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MediaServiceTest {

    @TempDir
    Path uploadRoot;

    @Test
    void inspectionMediaUsesExpectedFolderAndPublicUrl() throws Exception {
        MediaService service = configuredService();
        MockMultipartFile jpeg = new MockMultipartFile(
                "file", "inspection.jpg", "image/jpeg",
                new byte[]{(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 0x01, 0x02});

        Map<String, String> result = service.uploadMedia(
                "branch-7", "inspections", "INS-123", jpeg,
                "under_hood_2", "photo");

        Path targetDirectory = uploadRoot.resolve("branch-7/inspections/INS-123");
        assertTrue(Files.isDirectory(targetDirectory));
        try (var files = Files.list(targetDirectory)) {
            assertEquals(1, files.count());
        }
        assertTrue(result.get("url").startsWith(
                "/api/v1/media/branch-7/inspections/INS-123/"));
        assertEquals("under_hood_2", result.get("itemId"));
        assertEquals("photo", result.get("type"));
    }

    @Test
    void traversalLikeRecordIdIsRejected() {
        MediaService service = configuredService();
        MockMultipartFile jpeg = new MockMultipartFile(
                "file", "inspection.jpg", "image/jpeg",
                new byte[]{(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 0x01});

        assertThrows(IllegalArgumentException.class, () -> service.uploadMedia(
                "branch-7", "inspections", "../outside", jpeg,
                "item", "photo"));
    }

    private MediaService configuredService() {
        MediaService service = new MediaService();
        ReflectionTestUtils.setField(service, "uploadPath", uploadRoot.toString());
        ReflectionTestUtils.setField(service, "allowedTypes", List.of("image/jpeg"));
        ReflectionTestUtils.setField(service, "publicUrlPrefix", "/api/v1/media/");
        return service;
    }
}
