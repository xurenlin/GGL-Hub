package com.ggl.ai.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.model.ollama.OllamaEmbeddingModel;
import dev.langchain4j.model.openai.OpenAiChatModel;

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
                .modelName("deepseek-chat")
                .logRequests(true) // 开启日志，你能在控制台看到 AI 的思考过程
                .logResponses(true)
                .build();
    }

    /**
     * 定义 Embedding 模型 Bean
     * 负责将文档片段转换为向量
     */
    @Bean
    public EmbeddingModel embeddingModel() {
        // 使用 OpenAi 兼容接口来调用 DeepSeek 或其他平台的 Embedding 服务
        return OllamaEmbeddingModel.builder()
                .baseUrl("http://localhost:11434")
                .modelName("bge-m3") // 确认你使用的模型名称，需支持 1024 维输出
                .build();
    }
}
