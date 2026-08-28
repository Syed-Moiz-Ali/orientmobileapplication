package com.orient.workshop.core.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
@ConditionalOnProperty(name = "orient.firebase.enabled", havingValue = "true")
public class FirebaseConfiguration {

    @Bean
    public FirebaseApp firebaseApp(
            @Value("${orient.firebase.project-id:}") String projectId,
            @Value("${orient.firebase.credentials-path:}") String credentialsPath) throws IOException {
        GoogleCredentials credentials = loadCredentials(credentialsPath);
        FirebaseOptions.Builder options = FirebaseOptions.builder()
                .setCredentials(credentials);
        if (StringUtils.hasText(projectId)) {
            options.setProjectId(projectId);
        }
        return FirebaseApp.getApps().isEmpty()
                ? FirebaseApp.initializeApp(options.build())
                : FirebaseApp.getInstance();
    }

    private GoogleCredentials loadCredentials(String credentialsPath) throws IOException {
        if (StringUtils.hasText(credentialsPath)) {
            Path path = Path.of(credentialsPath).toAbsolutePath().normalize();
            if (!Files.isRegularFile(path)) {
                throw new IOException("Firebase credentials file not found: " + path);
            }
            try (InputStream serviceAccount = Files.newInputStream(path)) {
                return GoogleCredentials.fromStream(serviceAccount);
            }
        }
        // Reads GOOGLE_APPLICATION_CREDENTIALS automatically, or the workload
        // identity attached by Google Cloud/AWS/Azure when one is available.
        return GoogleCredentials.getApplicationDefault();
    }

    @Bean
    public FirebaseMessaging firebaseMessaging(FirebaseApp firebaseApp) {
        return FirebaseMessaging.getInstance(firebaseApp);
    }
}
