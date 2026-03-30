package com.ggl.ai.config;

import com.ggl.ai.service.LogisticsAgent;
import com.ggl.ai.tool.GeoTool;
import com.ggl.ai.tool.OrderTool;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.rag.content.retriever.ContentRetriever;
import dev.langchain4j.rag.content.retriever.EmbeddingStoreContentRetriever;
import dev.langchain4j.service.AiServices;
import dev.langchain4j.store.embedding.EmbeddingStore;
import dev.langchain4j.store.embedding.milvus.MilvusEmbeddingStore;

@Configuration
public class AiAgentConfig {

        @Value("${deepseek.api-key}")
        private String apiKey;

        // 1. 定义向量存储 (连接到 Docker 里的 Milvus)
        @Bean
        public EmbeddingStore<TextSegment> embeddingStore() {
                return MilvusEmbeddingStore.builder()
                                .host("localhost") // 开发环境连宿主机映射的端口
                                .port(19530)
                                .collectionName("ggl_knowledge_base")
                                .dimension(1024) // 必须与你 Attu 创建时一致
                                .metricType(io.milvus.param.MetricType.IP)
                                .build();

        }

        // 2. 定义内容检索器 (RAG 的核心组件)
        @Bean
        public ContentRetriever contentRetriever(EmbeddingStore<TextSegment> embeddingStore,
                        EmbeddingModel embeddingModel) {
                return EmbeddingStoreContentRetriever.builder()
                                .embeddingStore(embeddingStore)
                                .embeddingModel(embeddingModel)
                                .maxResults(3) // 每次找最相关的 3 条知识
                                .minScore(0.7) // 相似度低于 0.7 的不要（防止 AI 乱说）
                                .build();
        }

        @Bean
        public LogisticsAgent logisticsAgent(ChatLanguageModel chatLanguageModel,
                        ContentRetriever contentRetriever,
                        OrderTool orderLogisticsTool, GeoTool geoTool) {
                // 这一步就像是在组装一台电脑，把 CPU (模型) 和 硬盘 (工具) 组装在一起
                return AiServices.builder(LogisticsAgent.class)
                                .chatLanguageModel(chatLanguageModel)
                                .contentRetriever(contentRetriever)
                                .tools(orderLogisticsTool,
                                                geoTool) // 关键：把含有 Feign 调用的工具类注册进来
                                .chatMemory(MessageWindowChatMemory.withMaxMessages(10))
                                .build();
        }

}
