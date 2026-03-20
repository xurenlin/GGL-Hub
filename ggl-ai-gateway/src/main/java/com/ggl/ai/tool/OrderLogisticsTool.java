package com.ggl.ai.tool;

import com.ggl.ai.feign.OrderServiceClient;

import org.springframework.stereotype.Component;

import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;

@Component
public class OrderLogisticsTool {

    private final OrderServiceClient orderServiceClient;

    // 构造红注入 Feign 客户端
    public OrderLogisticsTool(OrderServiceClient orderServiceClient) {
        this.orderServiceClient = orderServiceClient;
    }

    @Tool("根据订单号查询物流状态、当前位置和预计送达时间")
    public String getOrderDetails(@P("订单号，通常是8位数字") String orderId) {

        System.out.println("--- [AI Agent 发起远程 Feign 调用] ---");

        try {
            return orderServiceClient.getLogisticsStatus(orderId);
        } catch (Exception e) {
            // TODO: handle exception
            return "抱歉，由于远程订单服务暂时不可用，无法获取单号 " + orderId + " 的实时信息。";
        }

    }

}
