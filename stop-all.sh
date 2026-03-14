#!/bin/bash

# ============================================
# GGL-Hub 企业级全球化智能物流调度平台
# 一键停止所有服务脚本
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
}

# 主函数
main() {
    log_info "开始停止 GGL-Hub 所有服务..."
    log_info "项目根目录: $(pwd)"
    
    # 检查依赖
    check_docker_compose
    
    # 停止所有服务
    log_info "停止所有服务..."
    $DOCKER_COMPOSE_CMD down
    
    log_success "============================================"
    log_success "GGL-Hub 所有服务已停止"
    log_success "============================================"
    echo ""
    log_info "清理所有容器和网络:"
    log_info "  $DOCKER_COMPOSE_CMD down --remove-orphans --volumes"
    echo ""
    log_info "查看 Docker 容器状态:"
    log_info "  docker ps -a"
    echo ""
    log_info "重新启动服务:"
    log_info "  ./start-all.sh"
}

# 执行主函数
main "$@"
