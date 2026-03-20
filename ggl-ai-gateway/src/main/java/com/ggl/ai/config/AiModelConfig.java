package com.ggl.ai.config;

import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiModelConfig {

    @Value("${deepseek.api-key:sk-c8f06ccc9c9c40ee805ace8971fc1379}")
    private String apiKey;

    @Value("${deepseek.base-url:https://api.deepseek.com}")
    private String baseUrl;

    /**
     * 定义大模型 Bean
     * Spring 会自动发现这个 Bean，并把它喂给 LogisticsAgent
     */
    @Bean
    public ChatLanguageModel chatLanguageModel() {
        return OpenAiChatModel.builder()
                .apiKey(apiKey)
                .baseUrl(baseUrl)
                .logRequests(true) // 开启日志，你能在控制台看到 AI 的思考过程
                .logResponses(true)
                .build();
    }
}
