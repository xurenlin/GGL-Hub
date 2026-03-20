package com.ggl.ai.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(value = "ggl-service-order")
public interface OrderServiceClient {
    /**
     * 调用订单微服务的接口获取物流详情
     */
    @GetMapping("/orders/{orderId}/logistics")
    String getLogisticsStatus(@PathVariable("orderId") String orderId);
}
