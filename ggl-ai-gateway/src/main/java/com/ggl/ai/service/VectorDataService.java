package com.ggl.ai.service;

import java.nio.file.Path;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.DocumentSplitter;
import dev.langchain4j.data.document.loader.FileSystemDocumentLoader;
import dev.langchain4j.data.document.splitter.DocumentSplitters;
import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class VectorDataService {

    @Autowired
    private EmbeddingStore<TextSegment> embeddingStore;

    @Autowired
    private EmbeddingModel embeddingModel;

    /**
     * 同步指定目录下的所有文档
     * 
     * @param forceMode 是否先清空再导入
     */
    public void syncDirectory(Path directoryPath, boolean forceMode) {
        if (forceMode) {
            log.warn("正在清空向量库以进行强制同步...");
            // 注意：Milvus 目前没有简单的 truncate 命令，通常是通过删除 collection
            // 或者在 Java 端配合元数据进行批量清理。开发阶段建议手动在 Attu 清空数据。
        }

        List<Document> documents = FileSystemDocumentLoader.loadDocuments(directoryPath);

        // 使用递归分片器，更符合 Markdown 的层级结构
        DocumentSplitter splitter = DocumentSplitters.recursive(500, 50);

        for (Document document : documents) {
            String fileName = document.metadata().get("file_name");
            log.info("开始处理文档: {}", fileName);

            List<TextSegment> segments = splitter.split(document);
            List<Embedding> embeddings = embeddingModel.embedAll(segments).content();

            // 批量存入 Milvus
            embeddingStore.addAll(embeddings, segments);
        }
        log.info("✅ 目录 {} 同步完成", directoryPath);
    }
}
