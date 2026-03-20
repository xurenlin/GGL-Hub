package com.ggl.order.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/orders")
public class OrderController {

    @GetMapping("/{orderId}/logistics")
    public String getLogisticsStatus(@PathVariable("orderId") String orderId) {

        if ("9527".equals(orderId)) {
            return "订单 9527 状态：【运输中】。当前位置：北京顺义分拨中心。预计送达：2026-03-21。";
        } else if ("12345".equals(orderId)) {
            return "订单 12345 状态：【派送中】。派送员：张师傅（138xxxx1234）。";
        }

        return "未查询到订单号 " + orderId + " 的相关物流信息，请核对单号。";
    }

}
