package com.ggl.ai.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Service;

import dev.langchain4j.data.message.SystemMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;

@Service
@RefreshScope
public class SimpleRouterService {

    private final ChatLanguageModel model;

    @Value("${logistics.ai.router-prompt}")
    private String systemPrompt;

    public SimpleRouterService() {
        // 使用默认配置，实际项目中应该从配置中心获取
        this.model = OpenAiChatModel.builder()
                .apiKey("sk-c8f06ccc9c9c40ee805ace8971fc1379")
                .baseUrl("https://api.deepseek.com")
                .modelName("deepseek-chat")
                .build();
    }

    public String getCurrentPrompt() {
        if (systemPrompt == null || systemPrompt.isEmpty()) {
            return "使用默认提示词 (配置为空)";
        }
        return "使用配置的提示词: " + systemPrompt.substring(0, Math.min(20, systemPrompt.length())) + "...";
    }

    public String routeAndExecute(String userQuery) {
        try {
            String intent = model.generate(List.of(
                    SystemMessage.from(systemPrompt),
                    UserMessage.from(userQuery))).content().text();

            // 路由逻辑
            if (intent.contains("ORDER")) {
                return "【路由至 Order Service】: 正在查询订单...";
            } else if (intent.contains("GEO")) {
                return "【路由至 Geo Service】: 正在处理坐标...";
            } else {
                return "【AI 回复】: " + model.generate(userQuery);
            }
        } catch (Exception e) {
            return "【错误】: AI服务暂时不可用，请稍后重试。错误信息: " + e.getMessage();
        }
    }
}
