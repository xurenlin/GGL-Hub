package com.ggl.ai.controller;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.CompletableFuture;

import com.ggl.ai.service.VectorDataService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/ai/admin")
@Slf4j
public class AiAdminController {

    @Autowired
    private VectorDataService vectorDataService;

    /**
     * 触发本地 docs 文件夹同步
     * GET http://localhost:8080/admin/ai/sync-docs
     */
    @PostMapping("/sync-docs")
    public String syncDocs(@RequestParam(name = "force", defaultValue = "false") boolean force) {
        try {
            Path docsPath = Paths.get("docs");

            // 异步执行，防止文档太多导致接口超时
            CompletableFuture.runAsync(() -> {
                vectorDataService.syncDirectory(docsPath, force);
            });

            return "🚀 同步任务已启动，请观察日志确认进度。";
        } catch (Exception e) {
            log.error("同步失败", e);
            return "❌ 同步失败：" + e.getMessage();
        }
    }

}
