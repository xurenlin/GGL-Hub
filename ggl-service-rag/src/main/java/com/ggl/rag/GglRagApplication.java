package com.ggl.rag;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub 知识检索服务启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.rag.feign")
public class GglRagApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglRagApplication.class, args);
    }
}
