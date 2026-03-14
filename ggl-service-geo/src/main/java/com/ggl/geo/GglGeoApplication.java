package com.ggl.geo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub 地理信息微服务启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.geo.feign")
public class GglGeoApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglGeoApplication.class, args);
    }
}
