package com.ggl.gateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import reactor.core.publisher.Mono;

@Configuration
public class GatewayConfig {

    /**
     * 定义限流器的 Key 策略
     * 这里的 Bean 名称必须是 userKeyResolver，
     * 才能对应你 YAML 里的 "#{@userKeyResolver}"
     */
    @Bean
    public KeyResolver userKeyResolver() {
        // 这里以客户端 IP 地址作为限流单位
        return exchange -> Mono.just(
                exchange.getRequest().getRemoteAddress().getAddress().getHostAddress());
    }
}
