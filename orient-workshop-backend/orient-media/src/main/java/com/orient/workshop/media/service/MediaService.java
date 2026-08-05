package com.orient.workshop.media.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
public class MediaService {

    private static final int MAGIC_BYTES_LENGTH = 16;

    @Value("${app.media.upload-path:/data/orient/media}")
    private String uploadPath;

    @Value("${app.media.allowed-types:image/jpeg,image/png,image/webp,video/mp4,audio/m4a,audio/wav,image/gif}")
    private List<String> allowedTypes;

    public Map<String, String> uploadMedia(String tenant, String module, String recordId,
                                           MultipartFile file, String itemId, String type) {
        validatePathSegment(tenant);
        validatePathSegment(module);
        validatePathSegment(recordId);

        String originalName = file.getOriginalFilename();
        if (originalName != null) {
            validatePathSegment(originalName);
        }
        if (file.isEmpty()) throw new IllegalArgumentException("File is empty");

        // CR-3: never trust the client-supplied Content-Type — validate the actual bytes.
        FileType detected = detectType(file);
        if (detected == null) {
            throw new IllegalArgumentException("File type could not be recognized from content");
        }
        if (!allowedTypes.contains(detected.mimeType)) {
            throw new IllegalArgumentException("File type not allowed: " + detected.mimeType);
        }

        String filename = UUID.randomUUID().toString().replace("-", "") + "." + detected.extension;

        try {
            Path targetDir = Path.of(uploadPath, tenant, module, recordId);
            Files.createDirectories(targetDir);
            Path target = targetDir.resolve(filename);
            file.transferTo(target.toFile());
            String url = "/media/" + tenant + "/" + module + "/" + recordId + "/" + filename;
            log.info("Uploaded: {} ({} bytes)", url, file.getSize());
            return Map.of("url", url);
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    /**
     * CR-3: reject any path segment or filename containing path separators, traversal
     * markers (".."), or NUL bytes so user input can never escape the upload root.
     */
    private void validatePathSegment(String segment) {
        if (segment == null || segment.isBlank()) {
            throw new IllegalArgumentException("Invalid path segment");
        }
        if (segment.contains("/") || segment.contains("\\")
                || segment.contains("..") || segment.indexOf('\u0000') >= 0) {
            throw new IllegalArgumentException("Invalid path segment: " + segment);
        }
    }

    /** Detects the file type from magic bytes (CR-3); null when unrecognized. */
    private FileType detectType(MultipartFile file) {
        try (InputStream in = file.getInputStream()) {
            byte[] head = in.readNBytes(MAGIC_BYTES_LENGTH);
            if (head.length < 4) return null;

            // JPEG: FF D8 FF
            if (startsWith(head, (byte) 0xFF, (byte) 0xD8, (byte) 0xFF)) {
                return new FileType("image/jpeg", "jpg");
            }
            // PNG: 89 50 4E 47 0D 0A 1A 0A
            if (startsWith(head, (byte) 0x89, (byte) 0x50, (byte) 0x4E, (byte) 0x47,
                    (byte) 0x0D, (byte) 0x0A, (byte) 0x1A, (byte) 0x0A)) {
                return new FileType("image/png", "png");
            }
            // GIF: GIF87a / GIF89a
            if (head.length >= 6 && "GIF87a".equals(new String(head, 0, 6, java.nio.charset.StandardCharsets.US_ASCII))
                    || head.length >= 6 && "GIF89a".equals(new String(head, 0, 6, java.nio.charset.StandardCharsets.US_ASCII))) {
                return new FileType("image/gif", "gif");
            }
            // PDF: %PDF
            if (head.length >= 4 && "%PDF".equals(new String(head, 0, 4, java.nio.charset.StandardCharsets.US_ASCII))) {
                return new FileType("application/pdf", "pdf");
            }
            // RIFF containers: WAV (RIFF....WAVE) and WEBP (RIFF....WEBP)
            if (startsWith(head, (byte) 0x52, (byte) 0x49, (byte) 0x46, (byte) 0x46) && head.length >= 12) {
                String fourCc = new String(head, 8, 4, java.nio.charset.StandardCharsets.US_ASCII);
                if ("WAVE".equals(fourCc)) {
                    return new FileType("audio/wav", "wav");
                }
                if ("WEBP".equals(fourCc)) {
                    return new FileType("image/webp", "webp");
                }
            }
            // MP4/M4A: ....ftyp (brand at offset 8 distinguishes audio M4A)
            if (head.length >= 12 && "ftyp".equals(new String(head, 4, 4, java.nio.charset.StandardCharsets.US_ASCII))) {
                String brand = new String(head, 8, 4, java.nio.charset.StandardCharsets.US_ASCII);
                if ("M4A ".equals(brand)) {
                    return new FileType("audio/m4a", "m4a");
                }
                return new FileType("video/mp4", "mp4");
            }
            return null;
        } catch (IOException e) {
            log.warn("Failed to read file header: {}", e.getMessage());
            return null;
        }
    }

    private boolean startsWith(byte[] head, byte... expected) {
        if (head.length < expected.length) return false;
        for (int i = 0; i < expected.length; i++) {
            if (head[i] != expected[i]) return false;
        }
        return true;
    }

    private static final class FileType {
        private final String mimeType;
        private final String extension;

        private FileType(String mimeType, String extension) {
            this.mimeType = mimeType;
            this.extension = extension;
        }
    }
}
