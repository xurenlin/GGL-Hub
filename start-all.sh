#!/bin/bash

# ============================================
# GGL-Hub 企业级全球化智能物流调度平台
# 一键启动所有服务脚本
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
}

# 检查 Docker Compose 是否安装
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        # 尝试使用 docker compose 插件
        if ! docker compose version &> /dev/null; then
            log_error "Docker Compose 未安装，请先安装 Docker Compose"
            exit 1
        fi
        DOCKER_COMPOSE_CMD="docker compose"
    else
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
    log_info "Docker Compose 命令: $DOCKER_COMPOSE_CMD"
}

# 等待服务就绪
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=$3
    local attempt=1
    
    log_info "等待服务 $service_name 启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null; then
            log_success "服务 $service_name 已就绪"
            return 0
        fi
        
        log_info "尝试 $attempt/$max_attempts: 服务 $service_name 尚未就绪，等待 5 秒..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    log_error "服务 $service_name 启动超时"
    return 1
}

# 显示服务状态
show_services_status() {
    log_info "============================================"
    log_info "GGL-Hub 服务状态"
    log_info "============================================"
    
    echo ""
    log_info "基础服务:"
    echo "  Nacos (注册中心):      http://localhost:8848/nacos"
    echo "  MySQL (数据库):        localhost:3307"
    echo "  Redis (缓存):          localhost:6379"
    echo "  RedisInsight (管理):   http://localhost:5540"
    echo ""
    
    log_info "Java 微服务:"
    echo "  网关服务:              http://localhost:8080"
    echo "  订单服务:              http://localhost:8081"
    echo "  地理信息服务:          http://localhost:8082"
    echo "  国际化服务:            http://localhost:8083"
    echo "  知识检索服务:          http://localhost:8084"
    echo "  AI安全防护服务:        http://localhost:8085"
    echo "  AI编排网关服务:        http://localhost:8086"
    echo ""
    
    log_info "监控与运维:"
    echo "  Prometheus (监控):     http://localhost:9090"
    echo "  Grafana (仪表板):      http://localhost:3000"
    echo "  Jaeger (追踪):         http://localhost:16686"
    echo "  Portainer (管理):      http://localhost:9000"
    echo "  MinIO (对象存储):      http://localhost:9002"
    echo "  Kibana (日志):         http://localhost:5601"
    echo ""
    
    log_info "API 文档:"
    echo "  网关 API 文档:         http://localhost:8080/doc.html"
    echo "  订单服务 API 文档:     http://localhost:8081/doc.html"
    echo "  地理服务 API 文档:     http://localhost:8082/doc.html"
    echo "  国际化服务 API 文档:   http://localhost:8083/doc.html"
    echo "  知识检索服务 API 文档: http://localhost:8084/doc.html"
    echo "  AI安全服务 API 文档:   http://localhost:8085/doc.html"
    echo "  AI网关服务 API 文档:   http://localhost:8086/doc.html"
    echo ""
}

# 主函数
main() {
    log_info "开始启动 GGL-Hub 所有服务..."
    log_info "项目根目录: $(pwd)"
    
    # 检查依赖
    check_docker
    check_docker_compose
    
    # 停止并清理旧容器
    log_info "停止并清理旧容器..."
    $DOCKER_COMPOSE_CMD down --remove-orphans
    
    # 启动所有服务
    log_info "启动所有服务..."
    $DOCKER_COMPOSE_CMD up -d
    
    # 等待基础服务启动
    log_info "等待基础服务启动..."
    wait_for_service "Nacos" "http://localhost:8848/nacos" 12
    wait_for_service "MySQL" "http://localhost:3307" 12
    wait_for_service "Redis" "http://localhost:6379" 12
    
    # 等待 Java 微服务启动
    log_info "等待 Java 微服务启动..."
    wait_for_service "网关服务" "http://localhost:8080/actuator/health" 30
    wait_for_service "订单服务" "http://localhost:8081/actuator/health" 30
    wait_for_service "地理信息服务" "http://localhost:8082/actuator/health" 30
    wait_for_service "国际化服务" "http://localhost:8083/actuator/health" 30
    wait_for_service "知识检索服务" "http://localhost:8084/actuator/health" 30
    wait_for_service "AI安全防护服务" "http://localhost:8085/actuator/health" 30
    wait_for_service "AI编排网关服务" "http://localhost:8086/actuator/health" 30
    
    # 显示服务状态
    show_services_status
    
    log_success "============================================"
    log_success "GGL-Hub 所有服务启动完成！"
    log_success "============================================"
    echo ""
    log_info "查看所有容器状态:"
    log_info "  $DOCKER_COMPOSE_CMD ps"
    echo ""
    log_info "查看服务日志:"
    log_info "  $DOCKER_COMPOSE_CMD logs -f"
    echo ""
    log_info "停止所有服务:"
    log_info "  $DOCKER_COMPOSE_CMD down"
    echo ""
    log_info "访问网关服务:"
    log_info "  http://localhost:8080"
}

# 执行主函数
main "$@"
