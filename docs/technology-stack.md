# GGL-Hub 技术栈与中间件文档

## 📋 文档概述

本文档详细描述了 GGL-Hub 企业级全球化智能物流调度平台所使用的技术栈和中间件组件，包括技术选型理由、版本信息、配置说明和使用方式。

## 🎯 技术选型原则

### 1. 选型标准
- **成熟稳定**：选择经过大规模生产验证的技术
- **社区活跃**：拥有活跃的社区支持和持续更新
- **生态完善**：具备完整的生态系统和工具链
- **性能优异**：满足高并发、低延迟的业务需求
- **可维护性**：易于开发、测试、部署和运维

### 2. 技术栈分层
- **基础框架层**：Spring Boot + Spring Cloud
- **数据存储层**：MySQL + Redis + 对象存储
- **服务治理层**：Nacos + Gateway
- **AI 集成层**：LangChain4j + 向量数据库
- **监控运维层**：Prometheus + Grafana + ELK

## 🏗️ 核心技术栈

### 1. 开发语言与运行时
#### Java 17
- **版本**：Java 17 LTS
- **选型理由**：
  - 长期支持版本，稳定性有保障
  - 性能优化显著，GC 改进明显
  - 新特性丰富（Records、Pattern Matching等）
  - 企业级应用广泛支持

#### Spring Boot 3.4.3
- **版本**：3.4.3
- **主要特性**：
  - 自动配置和起步依赖
  - 内嵌 Web 服务器（Tomcat）
  - Actuator 监控端点
  - 生产就绪特性
- **配置方式**：`application.yml` + `bootstrap.yml`

#### Spring Cloud 2023.0.3
- **版本**：2023.0.3（代号 "Kilburn"）
- **包含组件**：
  - Spring Cloud Gateway
  - Spring Cloud OpenFeign
  - Spring Cloud LoadBalancer
  - Spring Cloud CircuitBreaker
- **服务治理能力**：服务发现、配置管理、负载均衡、熔断降级

### 2. 微服务框架
#### Spring Cloud Alibaba 2023.0.1.0
- **版本**：2023.0.1.0
- **核心组件**：
  - Nacos Discovery（服务注册与发现）
  - Nacos Config（配置中心）
  - Sentinel（流量控制）
  - RocketMQ（消息队列，可选）
- **优势**：阿里云生态集成，中文文档完善

#### LangChain4j 1.0.0-alpha1
- **版本**：1.0.0-alpha1
- **功能**：
  - Java AI 应用开发框架
  - 多 LLM 提供商支持（OpenAI、Azure、本地模型）
  - RAG（检索增强生成）实现
  - Agent 和工具调用
- **集成方式**：Spring Boot Starter

### 3. 数据访问层
#### MyBatis Plus 3.5.5
- **版本**：3.5.5
- **特性**：
  - 强大的 CRUD 操作
  - 条件构造器
  - 分页插件
  - 性能分析插件
- **代码生成**：支持自动生成 Entity、Mapper、Service

#### 数据库驱动
- **MySQL Connector/J**：8.2.0
- **PostgreSQL JDBC**：42.7.0（向量数据库支持）
- **Redis客户端**：Lettuce 6.3.0

### 4. 工具库
#### Lombok 1.18.32
- **功能**：通过注解减少样板代码
- **常用注解**：`@Data`、`@Builder`、`@Slf4j`、`@AllArgsConstructor`

#### Hutool 5.8.26
- **功能**：Java工具类库
- **包含模块**：字符串处理、日期时间、加密解密、HTTP客户端

#### MapStruct 1.5.5.Final
- **功能**：对象映射框架
- **优势**：编译时生成映射代码，零运行时开销

## 🗄️ 数据存储中间件

### 1. 关系型数据库
#### MySQL 8.0
- **版本**：8.0
- **部署方式**：Docker 容器化
- **配置参数**：
  - 字符集：utf8mb4
  - 排序规则：utf8mb4_unicode_ci
  - 最大连接数：1000
- **数据库规划**：
  - `ggl_order`：订单业务数据
  - `ggl_user`：用户管理数据
  - `ggl_geo`：地理信息数据
  - `ggl_i18n`：国际化数据
  - `nacos`：配置中心数据

#### PostgreSQL + pgvector
- **版本**：PostgreSQL 15 + pgvector 0.5.0
- **用途**：向量数据库，支持 AI 语义检索
- **特性**：
  - 向量相似度搜索
  - ANN（近似最近邻）索引
  - 支持多种距离度量（余弦、欧几里得等）

### 2. 缓存与内存数据库
#### Redis 7.0
- **版本**：7.0-alpine
- **部署方式**：Docker 容器化，主从复制
- **使用场景**：
  - 会话存储（Spring Session）
  - 数据缓存（@Cacheable）
  - 分布式锁（Redisson）
  - 消息队列（Pub/Sub）
- **配置**：密码保护、持久化（AOF）

#### Redisson 3.27.2
- **功能**：Redis Java客户端
- **特性**：
  - 分布式对象和服务
  - 分布式锁和同步器
  - 分布式集合
  - Spring Boot 自动配置

### 3. 对象存储
#### MinIO
- **版本**：Latest
- **部署方式**：Docker 容器化
- **使用场景**：
  - 文件上传和下载
  - 图片和文档存储
  - 面单模板存储
- **访问控制**：预签名 URL、Bucket 策略

## 🔧 服务治理中间件

### 1. 服务注册与配置中心
#### Nacos 2.3.0
- **版本**：2.3.0
- **部署方式**：Docker 容器化，单机模式
- **核心功能**：
  - **服务发现**：微服务注册与发现
  - **配置管理**：动态配置推送
  - **命名空间**：环境隔离
  - **集群管理**：服务健康检查
- **访问地址**：http://localhost:8848/nacos
- **默认账号**：nacos/nacos

### 2. API 网关
#### Spring Cloud Gateway
- **版本**：随 Spring Cloud 2023.0.3
- **核心功能**：
  - **路由转发**：基于路径、Header、参数的路由
  - **过滤器链**：认证、限流、日志、熔断
  - **负载均衡**：集成 LoadBalancer
  - **跨域处理**：CORS 配置
- **配置方式**：Java Config + YAML

### 3. 服务间通信
#### OpenFeign
- **功能**：声明式 REST 客户端
- **特性**：
  - 接口注解定义
  - 负载均衡集成
  - 熔断器支持
  - 请求/响应拦截器

#### WebClient
- **功能**：响应式 HTTP 客户端
- **使用场景**：非阻塞 IO 调用、流式响应

## 🤖 AI 与智能组件

### 1. AI 框架集成
#### LangChain4j 生态系统
- **核心模块**：
  - `langchain4j-core`：核心抽象
  - `langchain4j-spring-boot-starter`：Spring Boot 集成
  - `langchain4j-openai`：OpenAI 集成
  - `langchain4j-azure-openai`：Azure OpenAI 集成
  - `langchain4j-embeddings`：嵌入模型
  - `langchain4j-retrieval`：检索增强

#### 向量化与检索
- **嵌入模型**：OpenAI text-embedding-ada-002
- **向量存储**：PostgreSQL + pgvector
- **检索策略**：相似度搜索、混合搜索

### 2. AI 安全与评测
#### 内容安全审核
- **审核维度**：政治敏感、暴力色情、广告营销
- **审核方式**：本地规则 + 第三方 API

#### Prompt 安全防护
- **防护策略**：注入检测、敏感词过滤、长度限制
- **评测指标**：相关性、准确性、安全性

## 📊 监控与可观测性

### 1. 指标监控
#### Prometheus
- **版本**：Latest
- **部署方式**：Docker 容器化
- **数据采集**：Pull 模式，15秒间隔
- **存储策略**：TSDB，200小时保留

#### Grafana
- **版本**：Latest
- **部署方式**：Docker 容器化
- **数据源**：Prometheus、MySQL、Redis
- **仪表板**：JVM 监控、业务指标、基础设施

### 2. 日志管理
#### ELK Stack
- **组件**：
  - Elasticsearch 8.12.0：日志存储和检索
  - Logstash 8.12.0：日志收集和解析
  - Kibana 8.12.0：日志可视化
- **日志格式**：JSON 结构化日志
- **日志级别**：DEBUG、INFO、WARN、ERROR

### 3. 链路追踪
#### Jaeger
- **版本**：Latest
- **部署方式**：Docker 容器化
- **集成方式**：Spring Cloud Sleuth
- **追踪维度**：服务调用链、数据库操作、HTTP请求

## 🚀 部署与运维

### 1. 容器化技术
#### Docker
- **版本**：20.10+
- **使用方式**：多阶段构建、镜像优化
- **基础镜像**：`eclipse-temurin:17-jre-alpine`

#### Docker Compose
- **版本**：3.8
- **编排文件**：`docker-compose.yml`
- **服务定义**：数据库、中间件、监控组件

### 2. 配置管理
#### 环境变量配置
```bash
# 核心环境变量
NACOS_HOST=localhost
NACOS_PORT=8848
MYSQL_HOST=mysql
MYSQL_PORT=3306
REDIS_HOST=redis
REDIS_PORT=6379
```

#### 配置文件分层
- `bootstrap.yml`：启动配置（Nacos 连接）
- `application.yml`：应用配置
- `application-{profile}.yml`：环境特定配置

### 3. 健康检查与就绪探针
#### Spring Boot Actuator
- **端点**：`/actuator/health`、`/actuator/info`、`/actuator/metrics`
- **健康指示器**：数据库、Redis、磁盘空间
- **自定义健康检查**：第三方服务连通性

## 🔐 安全组件

### 1. 认证授权
#### JWT（JSON Web Token）
- **库**：jjwt 0.11.5
- **算法**：HS256
- **令牌结构**：Header.Payload.Signature
- **刷新机制**：Access Token + Refresh Token

#### Spring Security
- **版本**：随 Spring Boot 3.4.3
- **功能**：认证、授权、密码加密、CSRF 防护

### 2. 数据安全
#### 加密算法
- **密码加密**：BCrypt
- **数据传输**：TLS 1.3
- **数据存储**：AES-256-GCM

#### 敏感信息处理
- **日志脱敏**：手机号、邮箱、身份证号
- **接口返回**：敏感字段掩码
- **配置加密**：Jasypt 或 Nacos 配置加密

## 📈 性能优化组件

### 1. 缓存策略
#### 多级缓存架构
- **L1 缓存**：Caffeine（本地缓存）
- **L2 缓存**：Redis（分布式缓存）
- **缓存穿透防护**：布隆过滤器
- **缓存雪崩防护**：随机过期时间

#### 数据库优化
- **连接池**：HikariCP
- **查询优化**：索引、分页、批量操作
- **读写分离**：主从复制

### 2. 异步处理
#### Spring Async
- **线程池配置**：核心线程数、最大线程数、队列容量
- **任务类型**：CPU 密集型、IO 密集型

#### 消息队列（可选）
- **RocketMQ**：阿里云消息队列
- **使用场景**：订单创建、支付通知、物流更新

## 🔄 开发工具链

### 1. 构建工具
#### Maven 3.8+
- **父POM管理**：统一依赖版本
- **多模块构建**：`mvn clean compile -pl module -am`
- **Profile支持**：开发、测试、生产环境

### 2. 代码质量
#### 代码规范
- **阿里巴巴Java开发规范**
- **Checkstyle**：代码风格检查
- **SpotBugs**：静态代码分析

#### 测试框架
- **JUnit 5**：单元测试
- **Mockito**：Mock 测试
- **Testcontainers**：集成测试

### 3. 文档生成
#### OpenAPI 3.0
- **库**：SpringDoc OpenAPI 1.7.0
- **UI工具**：Knife4j 4.4.0
- **访问地址**：http://localhost:8080/doc.html

## 📋 版本兼容性矩阵

| 组件 | 版本 | 兼容性说明 |
|------|------|------------|
| Java | 17 | 必须使用 LTS 版本 |
| Spring Boot | 3.4.3 | 需要 Java 17+ |
| Spring Cloud | 2023.0.3 | 与 Spring Boot 3.4.x 兼容 |
| Spring Cloud Alibaba | 2023.0.1.0 | 与 Spring Cloud 2023.0.x 兼容 |
| Nacos | 2.3.0 | 支持 Spring Cloud Alibaba 2023.0.1.0 |
| MySQL | 8.0 | 建议使用 8.0+ 版本 |
| Redis | 7.0 | 兼容 6.x、7.x 版本 |

## 🛠️ 环境准备清单

### 1. 开发环境
```bash
# 必须安装
JDK 17+
Maven 3.8+
Docker 20.10+
Docker Compose 3.8+

# 可选安装
Git 2.30+
IDE（IntelliJ IDEA / VS Code）
MySQL Workbench / DBeaver
RedisInsight
```

### 2. 生产环境
```bash
# 基础设施
Kubernetes 1.24+
Helm 3.10+
Nginx 1.20+
Certbot（SSL证书）

# 监控告警
AlertManager（Prometheus告警）
钉钉/企业微信机器人
短信/邮件告警服务
```

## 📝 配置示例

### 1. Maven 依赖管理
```xml
<!-- 父POM统一管理 -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 2. Docker Compose 配置
```yaml
version: '3.8'
services:
  nacos:
    image: nacos/nacos-server:v2.3.0
    environment:
      - MODE=standalone
      - SPRING_DATASOURCE_PLATFORM=mysql
    ports:
      - "8848:8848"
```

### 3. 应用配置文件
```yaml
spring:
  application:
    name: ggl-service-order
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_HOST:localhost}:${NACOS_PORT:8848}
```

---

**文档版本**: v1.0  
**最后更新**: 2026-03-17  
**维护团队**: GGL-Hub 技术架构组