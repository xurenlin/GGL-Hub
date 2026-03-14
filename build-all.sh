#!/bin/bash

# ============================================
# GGL-Hub 企业级全球化智能物流调度平台
# 一键构建所有微服务 Docker 镜像脚本
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

# 检查 Maven 是否安装
check_maven() {
    if ! command -v mvn &> /dev/null; then
        log_error "Maven 未安装，请先安装 Maven"
        exit 1
    fi
    log_info "Maven 版本: $(mvn -v | head -n 1)"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    log_info "Docker 版本: $(docker --version)"
}

# 构建单个服务
build_service() {
    local service_name=$1
    local service_dir=$2
    
    log_info "开始构建服务: $service_name"
    
    # 进入服务目录
    cd "$service_dir" || {
        log_error "无法进入目录: $service_dir"
        return 1
    }
    
    # 清理并打包
    log_info "执行 Maven 清理和打包..."
    if mvn clean package -DskipTests; then
        log_success "Maven 打包成功: $service_name"
    else
        log_error "Maven 打包失败: $service_name"
        return 1
    fi
    
    # 构建 Docker 镜像
    log_info "构建 Docker 镜像..."
    if docker build -t "ggl-hub/$service_name:latest" .; then
        log_success "Docker 镜像构建成功: ggl-hub/$service_name:latest"
    else
        log_error "Docker 镜像构建失败: $service_name"
        return 1
    fi
    
    # 返回项目根目录
    cd - > /dev/null || return 1
}

# 主函数
main() {
    log_info "开始构建 GGL-Hub 所有微服务..."
    log_info "项目根目录: $(pwd)"
    
    # 检查依赖
    check_maven
    check_docker
    
    # 服务列表
    services=(
        "ggl-common"
        "ggl-gateway"
        "ggl-ai-gateway"
        "ggl-service-order"
        "ggl-service-geo"
        "ggl-service-i18n"
        "ggl-service-rag"
        "ggl-service-guardrail"
    )
    
    # 构建公共模块
    log_info "构建公共模块..."
    cd ggl-common || {
        log_error "无法进入 ggl-common 目录"
        exit 1
    }
    mvn clean install -DskipTests
    cd ..
    log_success "公共模块构建完成"
    
    # 构建所有服务
    for service in "${services[@]}"; do
        if [ "$service" != "ggl-common" ]; then
            build_service "$service" "$service"
            if [ $? -ne 0 ]; then
                log_error "构建服务 $service 失败，停止构建"
                exit 1
            fi
        fi
    done
    
    log_success "============================================"
    log_success "所有微服务 Docker 镜像构建完成！"
    log_success "============================================"
    echo ""
    log_info "可用的 Docker 镜像:"
    docker images | grep ggl-hub
    echo ""
    log_info "启动所有服务:"
    log_info "  docker-compose up -d"
    echo ""
    log_info "查看服务状态:"
    log_info "  docker-compose ps"
    echo ""
    log_info "查看服务日志:"
    log_info "  docker-compose logs -f"
}

# 执行主函数
main "$@"
