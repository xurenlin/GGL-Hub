package com.ggl.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * GGL-Hub API 网关启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
public class GglGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglGatewayApplication.class, args);
    }
}
