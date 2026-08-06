package com.orient.workshop.gateway;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAsync
@EnableScheduling
@MapperScan({"com.orient.workshop.**.repository"})
@ComponentScan(basePackages = {
        "com.orient.workshop.common",
        "com.orient.workshop.core",
        "com.orient.workshop.auth",
        "com.orient.workshop.customer",
        "com.orient.workshop.advisor",
        "com.orient.workshop.supervisor",
        "com.orient.workshop.technician",
        "com.orient.workshop.owner",
        "com.orient.workshop.crm",
        "com.orient.workshop.media",
        "com.orient.workshop.sync",
        "com.orient.workshop.scheduler",
        "com.orient.workshop.whatsapp",
        "com.orient.workshop.gateway"
})
public class OrientGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrientGatewayApplication.class, args);
    }
}
