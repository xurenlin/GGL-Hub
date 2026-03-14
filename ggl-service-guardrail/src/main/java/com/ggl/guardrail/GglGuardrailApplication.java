package com.ggl.guardrail;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub AI 评测与安全防护服务启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.guardrail.feign")
public class GglGuardrailApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglGuardrailApplication.class, args);
    }
}
