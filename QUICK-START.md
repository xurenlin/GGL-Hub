# GGL-Hub 快速开始指南

## 完整工作流程

### 1. 首次部署（或代码修改后）

```bash
# 步骤1：重新编译所有服务并构建 Docker 镜像
build-all.bat

# 步骤2：启动所有服务
start-all.bat
```

### 2. 日常开发（代码无修改）

```bash
# 如果代码没有修改，可以直接启动服务
start-all.bat
```

### 3. 停止服务

```bash
# 停止所有服务
stop-all.bat
```

## 详细说明

### 构建脚本做了什么？

`build-all.bat` 执行以下操作：
1. **检查依赖**：验证 Maven 和 Docker 是否安装
2. **编译公共模块**：首先编译 `ggl-common` 模块
3. **编译所有微服务**：对每个微服务执行：
   - `mvn clean package -DskipTests` - 清理并重新编译
   - 生成新的 JAR 文件到 `target/` 目录
4. **构建 Docker 镜像**：为每个服务构建 Docker 镜像

### 启动脚本做了什么？

`start-all.bat` 执行以下操作：
1. **停止旧容器**：清理之前的运行实例
2. **启动所有服务**：使用 `docker-compose up -d`
3. **等待服务就绪**：按顺序等待每个服务启动
4. **显示状态**：提供所有服务的访问地址

## 代码修改后的重新编译流程

当您修改了任何 Java 代码后：

```bash
# 1. 停止正在运行的服务（如果正在运行）
stop-all.bat

# 2. 重新编译并构建新镜像
build-all.bat

# 3. 启动更新后的服务
start-all.bat
```

## 常见场景

### 场景1：修改了单个服务

```bash
# 进入特定服务目录
cd ggl-service-order

# 重新编译该服务
mvn clean package -DskipTests

# 重新构建该服务的 Docker 镜像
docker build -t ggl-hub/ggl-service-order:latest .

# 重启该服务
docker-compose up -d --build ggl-service-order
```

### 场景2：只修改了配置文件

```bash
# 直接重启服务，Docker 会使用新的配置文件
docker-compose up -d
```

### 场景3：开发调试模式

```bash
# 只启动基础设施服务
docker-compose up -d mysql redis nacos

# 在 IDE 中直接运行 Java 服务进行调试
```

## 验证服务状态

```bash
# 测试所有服务是否正常运行
test-services.bat

# 查看服务日志
docker-compose logs -f

# 查看容器状态
docker-compose ps
```

## 注意事项

1. **首次构建需要时间**：第一次运行 `build-all.bat` 需要下载 Maven 依赖和 Docker 基础镜像
2. **内存要求**：建议系统有 8GB+ 可用内存
3. **端口冲突**：如果端口被占用，可以修改 `docker-compose.yml` 中的端口映射
4. **环境变量**：AI 服务需要配置 API 密钥，编辑 `.env` 文件

## 故障排除

如果服务启动失败：
1. 检查日志：`docker-compose logs [服务名]`
2. 验证依赖：确保 MySQL、Redis、Nacos 先启动
3. 检查端口：确保所需端口未被占用
4. 查看资源：确保有足够的内存和磁盘空间

## 快速命令参考

```bash
# 完整重新部署
build-all.bat && start-all.bat

# 仅重启服务
stop-all.bat && start-all.bat

# 查看所有服务状态
docker-compose ps

# 查看特定服务日志
docker-compose logs -f ggl-gateway

# 进入容器调试
docker exec -it ggl-gateway sh
```

现在您可以开始使用 GGL-Hub 平台了！