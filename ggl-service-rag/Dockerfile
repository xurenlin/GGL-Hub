# ============================================
# GGL-Hub RAG Service Dockerfile
# 企业级全球化智能物流调度平台 - 知识检索服务
# ============================================

# 使用多阶段构建优化镜像大小
FROM eclipse-temurin:17-jre-alpine AS runtime

# 设置维护者信息
LABEL maintainer="GGL-Hub Team"
LABEL description="GGL-Hub RAG Service - Retrieval Augmented Generation Microservice"
LABEL version="1.0.0"

# 设置工作目录
WORKDIR /app

# 设置时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apk del tzdata

# 创建非root用户运行应用
RUN addgroup -g 1000 ggl && \
    adduser -u 1000 -G ggl -s /bin/sh -D ggl

# 创建数据目录用于存储文档
RUN mkdir -p /app/data/documents && \
    chown -R ggl:ggl /app/data

# 复制 JAR 文件
COPY target/ggl-service-rag-*.jar app.jar

# 设置文件所有权
RUN chown -R ggl:ggl /app

# 切换到非root用户
USER ggl

# 暴露端口
EXPOSE 8084

# JVM 参数配置 (RAG服务需要更多内存用于向量处理)
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication"

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8084/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
