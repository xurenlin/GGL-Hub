package com.ggl.ai.config;

import com.ggl.ai.service.LogisticsAgent;
import com.ggl.ai.tool.OrderLogisticsTool;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.service.AiServices;

@Configuration
public class AiAgentConfig {

    @Bean
    public LogisticsAgent logisticsAgent(ChatLanguageModel chatLanguageModel,
            OrderLogisticsTool orderLogisticsTool) {
        // 这一步就像是在组装一台电脑，把 CPU (模型) 和 硬盘 (工具) 组装在一起
        return AiServices.builder(LogisticsAgent.class)
                .chatLanguageModel(chatLanguageModel)
                .tools(orderLogisticsTool) // 关键：把含有 Feign 调用的工具类注册进来
                .build();
    }

}
