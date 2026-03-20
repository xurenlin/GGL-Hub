package com.ggl.ai.service;

import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Service;

@Service
@RefreshScope
public class SimpleRouterService {

    // 1. 只保留 Agent 代理，因为 Agent 内部已经包含了 model
    private final LogisticsAgent logisticsAgent;

    // 2. 必须通过构造器注入，这样 final 字段才会被初始化
    public SimpleRouterService(LogisticsAgent logisticsAgent) {
        this.logisticsAgent = logisticsAgent;
    }

    public String routeAndExecute(String userQuery) {
        try {
            // 现在的逻辑：
            // 1. AI 接收到 userQuery
            // 2. AI 阅读 Nacos 里的指令
            // 3. AI 发现用户想查单号，自动调用 OrderLogisticsTool (Feign)
            // 4. AI 汇总 Feign 返回的结果，并组织成自然的语言返回
            return logisticsAgent.chat(userQuery);

        } catch (Exception e) {
            // 统一异常处理
            return "【系统提示】: 智能调度暂时不可用，请稍后再试。错误: " + e.getMessage();
        }
    }
}
