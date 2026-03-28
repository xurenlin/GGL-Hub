package com.ggl.ai.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(value = "ggl-service-geo")
public interface GeoServiceClient {
    /**
     * 调用位置转换微服务的位置信息
     */
    @GetMapping("/geo/{address}/addressToCoordinate")
    String addressToCoordinate(@PathVariable("address") String address);
}
