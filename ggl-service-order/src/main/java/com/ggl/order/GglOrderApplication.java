package com.ggl.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub 订单微服务启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.order.feign")
public class GglOrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglOrderApplication.class, args);
    }
}
