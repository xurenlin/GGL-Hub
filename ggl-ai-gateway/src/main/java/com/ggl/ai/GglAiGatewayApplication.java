package com.ggl.ai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub AI 编排与网关服务启动类
 *
 * @author GGL-Hub
 */

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.ai.feign")
public class GglAiGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglAiGatewayApplication.class, args);
    }
}
