package com.ggl.i18n;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * GGL-Hub 国际化微服务启动类
 *
 * @author GGL-Hub
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.ggl.i18n.feign")
public class GglI18nApplication {

    public static void main(String[] args) {
        SpringApplication.run(GglI18nApplication.class, args);
    }
}
