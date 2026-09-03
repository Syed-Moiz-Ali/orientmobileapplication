package com.orient.workshop.media.config;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Path;

@Slf4j
@Configuration
public class FileStorageConfig implements WebMvcConfigurer {

    @Value("${app.media.upload-path:/data/orient/media}")
    private String uploadPath;

    private Path uploadRoot;

    @PostConstruct
    public void init() {
        try {
            uploadRoot = Path.of(uploadPath).toAbsolutePath().normalize();
            Files.createDirectories(uploadRoot);
            if (!Files.isDirectory(uploadRoot) || !Files.isWritable(uploadRoot)) {
                throw new IllegalStateException("Media upload directory is not writable: " + uploadRoot);
            }
            log.info("Media files stored under {}", uploadRoot);
        } catch (Exception e) {
            throw new IllegalStateException("Could not initialize media upload directory: " + uploadPath, e);
        }
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path root = uploadRoot != null
                ? uploadRoot
                : Path.of(uploadPath).toAbsolutePath().normalize();
        registry.addResourceHandler("/media/**")
                .addResourceLocations(root.toUri().toString());
    }
}
