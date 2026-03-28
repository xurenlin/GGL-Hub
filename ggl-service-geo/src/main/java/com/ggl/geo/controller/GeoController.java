package com.ggl.geo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/geo")
public class GeoController {

    @GetMapping("/{address}/addressToCoordinate")
    public String addressToCoordinate(@PathVariable("address") String address) {
        if (address.contains("青浦")) {
            return "地址：" + address + " 的经纬度为：121.124177, 31.150681";
        }
        return "地址：" + address + " 的经纬度转换失败，请检查地址是否详细。";
    }
}
