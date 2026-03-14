# GGL-Hub 企业级全球化智能物流调度平台

![Java](https://img.shields.io/badge/Java-17-blue)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.5-green)
![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2023.0.1-blue)
![Spring Cloud Alibaba](https://img.shields.io/badge/Spring%20Cloud%20Alibaba-2023.0.1.0-orange)
![LangChain4j](https://img.shields.io/badge/LangChain4j-1.12.1-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

## 📖 项目简介

**GGL-Hub** (Global Logistics Intelligent Hub) 是一个企业级全球化智能物流调度平台，专注于跨国物流的订单管理、路径规划、多语言面单生成和智能客服。平台采用微服务架构，集成了 Spring Cloud Alibaba、Nacos、Gateway 和 LangChain4j 等先进技术。

## 🎯 核心功能

### 📋 订单微服务 (Order Service)
- 跨国物流订单创建、查询、状态流转
- 物流追踪与实时状态更新
- 订单分析与报表生成

### 🌍 地理信息微服务 (Geo Service)
- 坐标转换 (WGS84/GCJ02/BD09)
- 路径规划与优化算法
- 地址解析与地理编码

### 🌐 国际化微服务 (I18n Service)
- 多语言翻译服务
- 智能面单模板生成
- 国际化资源管理

### 📚 知识检索服务 (RAG Knowledge Service)
- 向量化知识库管理
- 智能文档检索
- LangChain4j 集成

### 🛡️ AI 评测与安全防护服务 (Evaluation & Guardrail Service)
- 内容安全审核
- Prompt 注入防护
- AI 输出质量评测

### 🤖 AI 编排与网关服务 (AI Gateway / Orchestrator)
- 多 LLM 调度与负载均衡
- Agent 编排与智能客服
- 流式响应支持

## 🏗️ 技术架构

### 架构图
```
┌─────────────────────────────────────────────────────────────┐
│                        API Gateway (8080)                    │
│                    Spring Cloud Gateway                      │
└───────────────────────────┬─────────────────────────────────┘
                            │
    ┌───────────────────────┼───────────────────────┐
    │                       │                       │
┌───▼─────┐          ┌─────▼─────┐          ┌─────▼─────┐
│  Order  │          │    Geo    │          │   I18n    │
│ (8081)  │          │  (8082)   │          │  (8083)   │
└─────────┘          └───────────┘          └───────────┘
    │                       │                       │
    └───────────────────────┼───────────────────────┘
                            │
    ┌───────────────────────┼───────────────────────┐
    │                       │                       │
┌───▼─────┐          ┌─────▼─────┐          ┌─────▼─────┐
│   RAG   │          │ Guardrail │          │   AI      │
│ (8084)  │          │  (8085)   │          │ (8086)    │
└─────────┘          └───────────┘          └───────────┘
                            │
                    ┌───────▼───────┐
                    │    Nacos      │
                    │   (8848)      │
                    └───────────────┘
```

### 技术栈
- **Java 17** - 运行环境
- **Spring Boot 3.2.5** - 基础框架
- **Spring Cloud 2023.0.1** - 微服务框架
- **Spring Cloud Alibaba 2023.0.1.0** - 阿里巴巴微服务套件
- **Nacos 2.3.0** - 注册中心 & 配置中心
- **Spring Cloud Gateway** - API 网关
- **LangChain4j 1.12.1** - AI/LLM 集成框架
- **MyBatis Plus** - 数据访问层
- **Redis** - 缓存与分布式锁
- **MySQL 8.0** - 关系型数据库
- **Docker & Docker Compose** - 容器化部署

## 🚀 快速开始

### 环境要求
- JDK 17+
- Maven 3.8+
- Docker & Docker Compose
- Git

### 1. 克隆项目
```bash
git clone https://github.com/your-org/ggl-hub.git
cd ggl-hub
```

### 2. 启动基础设施
```bash
# 使用 Docker Compose 启动基础设施（包含数据库自动初始化）
docker-compose up -d mysql nacos redis

# 查看服务状态
docker-compose ps

# 等待数据库初始化完成（首次启动需要1-2分钟）
# 可以查看 MySQL 日志确认初始化状态
docker-compose logs mysql
```

### 3. 数据库初始化验证
```bash
# 验证 Nacos 数据库初始化
# Linux/macOS
./verify-nacos-persistence.sh

# Windows
verify-nacos-persistence.bat

# 或者手动验证
mysql -hlocalhost -P3307 -uroot -p123456 -e "USE nacos; SHOW TABLES;"
```

### 3. 配置环境变量
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑环境变量（配置 AI API Key 等）
vim .env
```

### 4. 编译项目
```bash
# 编译整个项目
mvn clean compile -DskipTests

# 或者编译单个模块
mvn clean compile -pl ggl-gateway -am -DskipTests
```

### 5. 启动服务
```bash
# 启动网关服务
mvn spring-boot:run -pl ggl-gateway

# 启动订单服务
mvn spring-boot:run -pl ggl-service-order

# 启动其他服务...
```

### 6. 访问服务
- **Nacos 控制台**: http://localhost:8848/nacos (账号: nacos, 密码: nacos)
- **API 网关**: http://localhost:8080
- **API 文档**: http://localhost:8080/doc.html

## 📁 项目结构

```
GGL-Hub/
├── pom.xml                              # 父POM，统一依赖管理
├── docker-compose.yml                   # Docker Compose 配置
├── .env                                 # 环境变量配置
├── docs/                                # 项目文档
│   ├── ARCHITECTURE.md                  # 架构设计文档
│   ├── QUICK_START.md                   # 快速启动指南
│   └── API.md                           # API 接口文档
├── ggl-common/                          # 公共模块
│   ├── src/main/java/com/ggl/common/
│   │   ├── result/                      # 统一响应封装
│   │   ├── exception/                   # 异常处理
│   │   ├── constant/                    # 常量定义
│   │   └── util/                        # 工具类
│   └── pom.xml
├── ggl-gateway/                         # API 网关
├── ggl-service-order/                   # 订单微服务
├── ggl-service-geo/                     # 地理信息微服务
├── ggl-service-i18n/                    # 国际化微服务
├── ggl-service-rag/                     # 知识检索服务
├── ggl-service-guardrail/               # AI 安全防护服务
└── ggl-ai-gateway/                      # AI 编排网关服务
```

## 🔧 开发指南

### 代码规范
- 遵循阿里巴巴 Java 开发规范
- 使用 Lombok 减少样板代码
- 统一使用 MapStruct 进行对象转换
- 所有 REST API 返回统一响应格式

### 分支策略
- `main` - 主分支，生产环境代码
- `develop` - 开发分支，集成测试环境
- `feature/*` - 功能分支
- `bugfix/*` - 修复分支
- `release/*` - 发布分支

### 提交规范
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式
- refactor: 重构
- test: 测试相关
- chore: 构建过程或辅助工具

## 📊 监控与运维

### 监控组件
- **Prometheus** - 指标收集 (http://localhost:9090)
- **Grafana** - 监控面板 (http://localhost:3000)
- **Jaeger** - 分布式追踪 (http://localhost:16686)
- **ELK Stack** - 日志收集与分析

### 健康检查
```bash
# 网关健康检查
curl http://localhost:8080/actuator/health

# 订单服务健康检查
curl http://localhost:8081/actuator/health
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- **项目负责人**: GGL-Hub Team
- **邮箱**: contact@ggl-hub.com
- **项目地址**: https://github.com/your-org/ggl-hub

## 🙏 致谢

感谢以下开源项目：
- [Spring Cloud Alibaba](https://github.com/alibaba/spring-cloud-alibaba)
- [LangChain4j](https://github.com/langchain4j/langchain4j)
- [Nacos](https://github.com/alibaba/nacos)
- [MyBatis Plus](https://github.com/baomidou/mybatis-plus)

---
**Made with ❤️ by GGL-Hub Team**
