package com.orient.workshop.media.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
public class MediaService {

    @Value("${app.media.upload-path:/data/orient/media}")
    private String uploadPath;

    @Value("${app.media.allowed-types:image/jpeg,image/png,image/webp,video/mp4,audio/m4a,audio/wav}")
    private String allowedTypes;

    public Map<String, String> uploadMedia(String module, String recordId, MultipartFile file, String itemId, String type) {
        validateFile(file);

        String dir = module + "/" + recordId;
        String filename = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();

        try {
            Path targetDir = Path.of(uploadPath, dir);
            Files.createDirectories(targetDir);
            Path target = targetDir.resolve(filename);
            file.transferTo(target.toFile());
            String url = "/media/" + dir + "/" + filename;
            log.info("Uploaded: {} ({} bytes)", url, file.getSize());
            return Map.of("url", url);
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) throw new IllegalArgumentException("File is empty");
        String contentType = file.getContentType();
        if (contentType != null && !allowedTypes.contains(contentType)) {
            throw new IllegalArgumentException("File type not allowed: " + contentType);
        }
    }
}
