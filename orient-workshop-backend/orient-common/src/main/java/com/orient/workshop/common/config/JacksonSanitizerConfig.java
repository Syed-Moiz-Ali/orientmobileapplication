package com.orient.workshop.common.config;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.databind.module.SimpleModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;

@Configuration
public class JacksonSanitizerConfig {

    @Bean
    public Module sanitizationModule() {
        SimpleModule module = new SimpleModule();
        module.addDeserializer(String.class, new JsonDeserializer<String>() {
            @Override
            public String deserialize(JsonParser p, DeserializationContext ctx) throws IOException {
                String value = p.getValueAsString();
                if (value == null) return null;
                return value
                        .replaceAll("<(?i)script[^>]*?>.*?</(?i)script>", "")
                        .replaceAll("<[^>]+>", "")
                        .replace("'", "&apos;")
                        .replace("\"", "&quot;");
            }
        });
        return module;
    }
}
