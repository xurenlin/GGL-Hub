#!/bin/bash

# ============================================
# Nacos 持久化验证脚本
# 验证 Nacos 是否正确持久化到 MySQL
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
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# 检查服务状态
check_service_status() {
    local service_name="$1"
    local service_url="$2"
    
    log_info "检查服务状态: $service_name"
    
    if curl -s -f "$service_url" >/dev/null 2>&1; then
        log_success "$service_name 运行正常"
        return 0
    else
        log_error "$service_name 无法访问"
        return 1
    fi
}

# 检查 MySQL 数据库
check_mysql_database() {
    local db_name="$1"
    
    log_info "检查 MySQL 数据库: $db_name"
    
    local table_count=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$db_name';" 2>/dev/null || echo "0")
    
    if [ "$table_count" -gt 0 ]; then
        log_success "数据库 $db_name 存在，包含 $table_count 张表"
        return 0
    else
        log_error "数据库 $db_name 不存在或为空"
        return 1
    fi
}

# 检查 Nacos 配置持久化
check_nacos_persistence() {
    log_info "检查 Nacos 配置持久化..."
    
    # 创建测试配置
    local test_data_id="test-persistence-$(date +%s)"
    local test_content="test-content-$(date +%s)"
    
    log_info "创建测试配置: $test_data_id"
    
    # 通过 Nacos API 创建配置
    local create_response=$(curl -s -X POST "http://localhost:8848/nacos/v1/cs/configs" \
        -d "dataId=$test_data_id" \
        -d "group=DEFAULT_GROUP" \
        -d "content=$test_content" \
        -d "type=yaml" \
        -H "Content-Type: application/x-www-form-urlencoded")
    
    if [ "$create_response" = "true" ]; then
        log_success "测试配置创建成功"
    else
        log_error "测试配置创建失败: $create_response"
        return 1
    fi
    
    # 重启 Nacos 服务
    log_info "重启 Nacos 服务..."
    docker restart ggl-nacos >/dev/null 2>&1
    
    # 等待 Nacos 重启
    log_info "等待 Nacos 重启..."
    sleep 30
    
    # 检查 Nacos 是否恢复
    check_service_status "Nacos" "http://localhost:8848/nacos"
    if [ $? -ne 0 ]; then
        log_error "Nacos 重启后无法访问"
        return 1
    fi
    
    # 验证配置是否持久化
    log_info "验证配置持久化..."
    local get_response=$(curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=$test_data_id&group=DEFAULT_GROUP")
    
    if [ "$get_response" = "$test_content" ]; then
        log_success "配置持久化验证成功"
        
        # 清理测试配置
        curl -s -X DELETE "http://localhost:8848/nacos/v1/cs/configs?dataId=$test_data_id&group=DEFAULT_GROUP" >/dev/null 2>&1
        log_info "清理测试配置"
        
        return 0
    else
        log_error "配置持久化验证失败"
        log_info "期望内容: $test_content"
        log_info "实际内容: $get_response"
        return 1
    fi
}

# 检查数据库连接配置
check_database_connection() {
    log_info "检查 Nacos 数据库连接配置..."
    
    # 检查 Nacos 容器中的数据库配置
    local db_config=$(docker exec ggl-nacos cat /home/nacos/conf/application.properties 2>/dev/null | grep -E "spring.datasource|db.url|db.user" || true)
    
    if [ -n "$db_config" ]; then
        log_success "Nacos 数据库配置存在"
        echo "$db_config" | while read line; do
            log_info "  $line"
        done
    else
        log_warning "未找到 Nacos 数据库配置"
    fi
}

# 显示持久化状态
show_persistence_status() {
    log_info "持久化状态汇总:"
    echo ""
    
    # 检查 MySQL 中的 Nacos 表
    log_info "MySQL 中的 Nacos 表:"
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE nacos; SHOW TABLES;" 2>/dev/null | while read table; do
        if [ -n "$table" ]; then
            log_info "  - $table"
        fi
    done
    
    echo ""
    
    # 检查配置数量
    local config_count=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -N -e "USE nacos; SELECT COUNT(*) FROM config_info;" 2>/dev/null || echo "0")
    log_info "Nacos 配置数量: $config_count"
    
    # 检查用户数量
    local user_count=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -N -e "USE nacos; SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
    log_info "Nacos 用户数量: $user_count"
}

# 主函数
main() {
    log_info "============================================"
    log_info "Nacos 持久化验证脚本"
    log_info "============================================"
    
    # 设置环境变量
    export MYSQL_HOST=${MYSQL_HOST:-localhost}
    export MYSQL_PORT=${MYSQL_PORT:-3307}
    export MYSQL_USER=${MYSQL_USER:-root}
    export MYSQL_PASSWORD=${MYSQL_PASSWORD:-123456}
    
    log_info "使用以下配置:"
    log_info "  MySQL Host: $MYSQL_HOST"
    log_info "  MySQL Port: $MYSQL_PORT"
    log_info "  MySQL User: $MYSQL_USER"
    echo ""
    
    # 检查基础服务
    log_info "检查基础服务状态..."
    check_service_status "MySQL" "$MYSQL_HOST:$MYSQL_PORT" || exit 1
    check_service_status "Nacos" "http://localhost:8848/nacos" || exit 1
    
    # 检查数据库
    check_mysql_database "nacos" || exit 1
    
    # 检查数据库连接配置
    check_database_connection
    
    # 显示持久化状态
    show_persistence_status
    
    echo ""
    log_info "开始持久化验证测试..."
    echo ""
    
    # 执行持久化验证
    check_nacos_persistence
    
    if [ $? -eq 0 ]; then
        log_success "============================================"
        log_success "Nacos 持久化验证成功！"
        log_success "============================================"
        echo ""
        log_info "验证结果:"
        log_info "  ✓ MySQL 数据库连接正常"
        log_info "  ✓ Nacos 表结构正确"
        log_info "  ✓ 配置数据持久化成功"
        log_info "  ✓ 服务重启后数据恢复正常"
        echo ""
        log_info "Nacos 已正确配置为使用 MySQL 持久化存储。"
    else
        log_error "============================================"
        log_error "Nacos 持久化验证失败！"
        log_error "============================================"
        echo ""
        log_info "可能的原因:"
        log_info "  1. MySQL 数据库未正确初始化"
        log_info "  2. Nacos 数据库配置错误"
        log_info "  3. 网络连接问题"
        log_info "  4. 权限配置问题"
        echo ""
        log_info "请检查:"
        log_info "  1. 运行 init-scripts/init-all.sh 初始化数据库"
        log_info "  2. 检查 docker-compose.yml 中的环境变量"
        log_info "  3. 查看 Nacos 日志: docker logs ggl-nacos"
        exit 1
    fi
}

# 执行主函数
main "$@"