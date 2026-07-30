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

    @PostConstruct
    public void init() {
        try {
            Files.createDirectories(Path.of(uploadPath));
        } catch (Exception e) {
            log.warn("Could not create upload dir: {}", uploadPath);
        }
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/media/**")
                .addResourceLocations("file:" + uploadPath + "/");
    }
}
