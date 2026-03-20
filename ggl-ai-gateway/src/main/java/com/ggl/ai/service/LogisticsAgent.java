package com.ggl.ai.service;

import dev.langchain4j.service.SystemMessage;

public interface LogisticsAgent {

    // 我们把 Nacos 里的 Prompt 作为系统消息传入
    @SystemMessage("${logistics.ai.router-prompt}")
    String chat(String userMessage);
}
