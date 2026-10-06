package com.orient.workshop.media.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.media.model.dto.MediaNoteRequest;
import com.orient.workshop.media.model.entity.MediaAsset;
import com.orient.workshop.media.repository.MediaAssetMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

@Slf4j
@Service
public class MediaService {

    private static final int MAGIC_BYTES_LENGTH = 16;
    private static final Pattern SAFE_STORAGE_SEGMENT =
            Pattern.compile("[A-Za-z0-9_-]{1,100}");

    @Value("${app.media.upload-path:/data/orient/media}")
    private String uploadPath;

    @Value("${app.media.allowed-types:image/jpeg,image/png,image/webp,video/mp4,audio/m4a,audio/wav,image/gif}")
    private List<String> allowedTypes;

    @Value("${app.media.public-url-prefix:/api/v1/media}")
    private String publicUrlPrefix;

    // Optional injection so the plain unit test can construct the service
    // without a database.
    @Autowired(required = false)
    private MediaAssetMapper mediaAssetMapper;

    public Map<String, String> uploadMedia(String tenant, String module, String recordId,
                                           MultipartFile file, String itemId, String type) {
        return uploadMedia(tenant, module, recordId, file, itemId, type, null);
    }

    public Map<String, String> uploadMedia(String tenant, String module, String recordId,
                                           MultipartFile file, String itemId, String type,
                                           Long createdBy) {
        validatePathSegment(tenant);
        validatePathSegment(module);
        validatePathSegment(recordId);

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
            Path storageRoot = Path.of(uploadPath).toAbsolutePath().normalize();
            Path targetDir = storageRoot.resolve(tenant).resolve(module).resolve(recordId).normalize();
            if (!targetDir.startsWith(storageRoot)) {
                throw new IllegalArgumentException("Invalid media storage path");
            }
            Files.createDirectories(targetDir);
            Path target = targetDir.resolve(filename);
            file.transferTo(target.toFile());
            String prefix = normalizePublicUrlPrefix(publicUrlPrefix);
            String url = prefix + "/" + tenant + "/" + module + "/" + recordId + "/" + filename;
            log.info("Uploaded: {} ({} bytes)", url, file.getSize());
            String ref = recordAsset(tenant, module, recordId, itemId, type,
                    filename, url, detected, file.getSize(), createdBy);
            Map<String, String> result = new java.util.HashMap<>();
            result.put("url", url);
            result.put("itemId", itemId == null ? "" : itemId);
            result.put("type", type == null || type.isBlank() ? "photo" : type);
            if (ref != null) result.put("ref", ref);
            return result;
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    /** Records the uploaded file in media_assets so it can be listed later. */
    private String recordAsset(String tenant, String module, String recordId, String itemId,
                               String type, String filename, String url, FileType detected,
                               long size, Long createdBy) {
        if (mediaAssetMapper == null) return null;
        try {
            MediaAsset asset = MediaAsset.builder()
                    .ref(IdGenerator.shortRef("MED"))
                    .tenant(tenant)
                    .module(module)
                    .recordId(recordId)
                    .itemId(itemId == null ? "" : itemId)
                    .mediaType(type == null || type.isBlank() ? "photo" : type)
                    .url(url)
                    .fileName(filename)
                    .contentType(detected.mimeType)
                    .sizeBytes(size)
                    .createdBy(createdBy)
                    .build();
            mediaAssetMapper.insert(asset);
            return asset.getRef();
        } catch (Exception e) {
            // Never fail an upload because indexing failed.
            log.warn("Failed to record media asset for {}/{}: {}", module, recordId, e.getMessage());
            return null;
        }
    }

    /** Lists the media recorded for a record (e.g. inspections/INS-123). */
    public List<MediaAsset> list(String module, String recordId) {
        validatePathSegment(module);
        validatePathSegment(recordId);
        if (mediaAssetMapper == null) return List.of();
        return mediaAssetMapper.findByRecord(module, recordId);
    }

    /**
     * Replaces the text notes recorded for a record. Notes are stored on the
     * same media index as photos/videos so one listing returns every asset.
     */
    @Transactional
    public int recordNotes(String tenant, String module, String recordId,
                           MediaNoteRequest request, Long createdBy) {
        if (mediaAssetMapper == null) return 0;
        validatePathSegment(tenant);
        validatePathSegment(module);
        validatePathSegment(recordId);
        List<MediaNoteRequest.Item> items = request != null ? request.getItems() : null;
        if (items == null || items.isEmpty()) return 0;

        mediaAssetMapper.delete(new LambdaQueryWrapper<MediaAsset>()
                .eq(MediaAsset::getModule, module)
                .eq(MediaAsset::getRecordId, recordId)
                .eq(MediaAsset::getMediaType, "note"));

        int saved = 0;
        for (MediaNoteRequest.Item item : items) {
            if (item == null || item.getNote() == null || item.getNote().isBlank()) continue;
            mediaAssetMapper.insert(MediaAsset.builder()
                    .ref(IdGenerator.shortRef("MED"))
                    .tenant(tenant)
                    .module(module)
                    .recordId(recordId)
                    .itemId(item.getItemId() == null ? "" : item.getItemId())
                    .mediaType("note")
                    .url("")
                    .note(item.getNote())
                    .fileName("")
                    .contentType("text/plain")
                    .sizeBytes((long) item.getNote().length())
                    .createdBy(createdBy)
                    .build());
            saved++;
        }
        return saved;
    }

    /**
     * CR-3: reject any path segment or filename containing path separators, traversal
     * markers (".."), or NUL bytes so user input can never escape the upload root.
     */
    private void validatePathSegment(String segment) {
        if (segment == null || !SAFE_STORAGE_SEGMENT.matcher(segment).matches()) {
            throw new IllegalArgumentException("Invalid path segment: " + segment);
        }
    }

    private String normalizePublicUrlPrefix(String prefix) {
        String normalized = prefix == null || prefix.isBlank() ? "/api/v1/media" : prefix.trim();
        if (!normalized.startsWith("/")) normalized = "/" + normalized;
        while (normalized.length() > 1 && normalized.endsWith("/")) {
            normalized = normalized.substring(0, normalized.length() - 1);
        }
        return normalized;
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
