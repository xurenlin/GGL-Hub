# GGL-Hub 容器化部署指南

## 概述

本文档提供了 GGL-Hub 企业级全球化智能物流调度平台的容器化部署指南。通过 Docker 和 Docker Compose，您可以一键启动所有服务，包括 Java 微服务、数据库、缓存、监控等基础设施。

## 系统要求

- **操作系统**: Windows 10/11, macOS, Linux
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Maven**: 3.6+ (用于构建)
- **Java**: 17+ (用于构建)
- **内存**: 建议 8GB+ RAM
- **磁盘空间**: 建议 10GB+ 可用空间

## 项目结构

```
GGL-Hub/
├── docker-compose.yml          # Docker Compose 配置文件
├── .env                        # 环境变量配置文件
├── build-all.bat               # Windows 构建脚本
├── build-all.sh                # Linux/macOS 构建脚本
├── start-all.bat               # Windows 启动脚本
├── start-all.sh                # Linux/macOS 启动脚本
├── stop-all.bat                # Windows 停止脚本
├── stop-all.sh                 # Linux/macOS 停止脚本
├── DOCKER-README.md            # 本文档
├── ggl-gateway/
│   └── Dockerfile              # 网关服务 Dockerfile
├── ggl-ai-gateway/
│   └── Dockerfile              # AI编排网关服务 Dockerfile
├── ggl-service-order/
│   └── Dockerfile              # 订单服务 Dockerfile
├── ggl-service-geo/
│   └── Dockerfile              # 地理信息服务 Dockerfile
├── ggl-service-i18n/
│   └── Dockerfile              # 国际化服务 Dockerfile
├── ggl-service-rag/
│   └── Dockerfile              # 知识检索服务 Dockerfile
└── ggl-service-guardrail/
    └── Dockerfile              # AI安全防护服务 Dockerfile
```

## 快速开始

### 1. 构建所有微服务镜像

#### Windows 用户:
```bash
build-all.bat
```

#### Linux/macOS 用户:
```bash
chmod +x build-all.sh
./build-all.sh
```

### 2. 启动所有服务

#### Windows 用户:
```bash
start-all.bat
```

#### Linux/macOS 用户:
```bash
chmod +x start-all.sh
./start-all.sh
```

### 3. 停止所有服务

#### Windows 用户:
```bash
stop-all.bat
```

#### Linux/macOS 用户:
```bash
chmod +x stop-all.sh
./stop-all.sh
```

## 服务端口映射

### 基础服务
| 服务 | 端口 | 说明 |
|------|------|------|
| Nacos | 8848 | 服务注册与配置中心 |
| MySQL | 3307 | 数据库 |
| Redis | 6379 | 缓存 |
| RedisInsight | 5540 | Redis 管理界面 |

### Java 微服务
| 服务 | 端口 | 说明 |
|------|------|------|
| 网关服务 | 8080 | Spring Cloud Gateway |
| 订单服务 | 8081 | 订单管理微服务 |
| 地理信息服务 | 8082 | 地理信息微服务 |
| 国际化服务 | 8083 | 国际化微服务 |
| 知识检索服务 | 8084 | RAG 微服务 |
| AI安全防护服务 | 8085 | AI 安全防护微服务 |
| AI编排网关服务 | 8086 | AI 编排网关微服务 |

### 监控与运维
| 服务 | 端口 | 说明 |
|------|------|------|
| Prometheus | 9090 | 监控系统 |
| Grafana | 3000 | 监控仪表板 |
| Jaeger | 16686 | 分布式追踪 |
| Portainer | 9000 | Docker 管理界面 |
| MinIO | 9002 | 对象存储 API |
| MinIO Console | 9003 | 对象存储管理界面 |
| Kibana | 5601 | 日志可视化 |

## 环境变量配置

编辑 `.env` 文件配置环境变量：

```bash
# AI 服务配置
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
AZURE_OPENAI_ENDPOINT=your-azure-openai-endpoint
AZURE_OPENAI_API_KEY=your-azure-openai-api-key
AZURE_OPENAI_DEPLOYMENT_NAME=your-deployment-name
```

## 手动操作指南

### 1. 使用 Docker Compose 手动操作

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f

# 停止所有服务
docker-compose down

# 停止并清理所有资源
docker-compose down --remove-orphans --volumes
```

### 2. 构建单个服务镜像

```bash
# 进入服务目录
cd ggl-gateway

# 构建镜像
docker build -t ggl-hub/ggl-gateway:latest .

# 查看镜像
docker images | grep ggl-hub
```

### 3. 服务健康检查

所有 Java 微服务都配置了健康检查端点：

```bash
# 检查网关服务健康状态
curl http://localhost:8080/actuator/health

# 检查订单服务健康状态
curl http://localhost:8081/actuator/health

# 检查所有服务健康状态
docker-compose ps
```

## 故障排除

### 1. 端口冲突

如果出现端口冲突，可以修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8080:8080"  # 改为 "18080:8080"
```

### 2. 内存不足

如果服务启动失败，可能是内存不足。可以：

1. 增加 Docker 内存分配
2. 减少同时启动的服务数量
3. 修改 JVM 内存参数（在 Dockerfile 中）

### 3. 服务启动顺序问题

服务之间有依赖关系，启动顺序为：
1. MySQL → Nacos
2. Redis → 所有 Java 微服务
3. Nacos → 所有 Java 微服务

### 4. 查看详细日志

```bash
# 查看特定服务日志
docker-compose logs ggl-gateway

# 查看所有服务日志
docker-compose logs -f

# 查看容器内部状态
docker exec -it ggl-gateway sh
```

## 开发与调试

### 1. 本地开发模式

```bash
# 只启动基础设施服务
docker-compose up -d mysql redis nacos

# 在 IDE 中启动 Java 微服务
```

### 2. 调试模式

修改 Dockerfile 中的 JVM 参数启用调试：

```dockerfile
ENV JAVA_OPTS="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=5005,suspend=n -Xms256m -Xmx512m"
```

### 3. 热部署

对于开发环境，可以使用卷挂载实现热部署：

```yaml
volumes:
  - ./ggl-gateway/target:/app
```

## 生产环境建议

### 1. 安全配置

1. 修改默认密码（MySQL、Redis、Nacos）
2. 启用 HTTPS
3. 配置防火墙规则
4. 使用私有镜像仓库

### 2. 性能优化

1. 调整 JVM 内存参数
2. 配置数据库连接池
3. 启用 Redis 缓存
4. 配置负载均衡

### 3. 监控告警

1. 配置 Prometheus 告警规则
2. 设置 Grafana 仪表板
3. 配置日志收集
4. 设置健康检查

## 常见问题

### Q: 服务启动后无法访问？
A: 检查端口是否被占用，防火墙是否允许访问。

### Q: Nacos 无法连接 MySQL？
A: 检查 MySQL 是否启动，密码是否正确。

### Q: Java 微服务无法注册到 Nacos？
A: 检查 Nacos 是否可访问，网络配置是否正确。

### Q: 内存不足导致服务崩溃？
A: 增加 Docker 内存分配或减少服务数量。

## 支持与反馈

如有问题，请参考：
1. Docker 官方文档
2. Spring Cloud 文档
3. Nacos 文档
4. 项目 README.md

或提交 Issue 到项目仓库。
```

## 总结

通过本文档，您可以快速部署和运行 GGL-Hub 平台的所有服务。容器化部署提供了环境一致性、快速部署和易于维护的优势。