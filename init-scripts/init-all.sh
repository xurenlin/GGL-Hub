#!/bin/bash

# ============================================
# GGL-Hub 数据库统一初始化脚本
# 版本: 1.0.0
# 创建时间: $(date)
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

# 检查 MySQL 连接
check_mysql_connection() {
    log_info "检查 MySQL 连接..."
    
    local max_retries=30
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
            log_success "MySQL 连接成功"
            return 0
        fi
        
        log_info "等待 MySQL 启动... ($((retry_count + 1))/$max_retries)"
        sleep 2
        retry_count=$((retry_count + 1))
    done
    
    log_error "MySQL 连接失败，请检查服务是否正常运行"
    return 1
}

# 执行 SQL 文件
execute_sql_file() {
    local sql_file="$1"
    local db_name="$2"
    
    if [ ! -f "$sql_file" ]; then
        log_error "SQL 文件不存在: $sql_file"
        return 1
    fi
    
    log_info "执行 SQL 文件: $(basename "$sql_file")"
    
    if [ -n "$db_name" ]; then
        mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$db_name" < "$sql_file"
    else
        mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" < "$sql_file"
    fi
    
    if [ $? -eq 0 ]; then
        log_success "SQL 文件执行成功: $(basename "$sql_file")"
    else
        log_error "SQL 文件执行失败: $(basename "$sql_file")"
        return 1
    fi
}

# 初始化 Nacos 数据库
init_nacos_database() {
    log_info "开始初始化 Nacos 数据库..."
    
    # 创建 nacos 数据库
    log_info "创建 nacos 数据库..."
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS nacos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    # 执行 Nacos SQL 文件
    execute_sql_file "nacos-schema.sql" "nacos"
    
    log_success "Nacos 数据库初始化完成"
}

# 初始化订单服务数据库
init_order_database() {
    log_info "开始初始化订单服务数据库..."
    
    # 执行订单服务 SQL 文件
    execute_sql_file "ggl-order-schema.sql"
    
    log_success "订单服务数据库初始化完成"
}

# 验证数据库初始化
verify_databases() {
    log_info "验证数据库初始化..."
    
    local databases=("nacos" "ggl_order")
    
    for db in "${databases[@]}"; do
        log_info "检查数据库: $db"
        
        local table_count=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$db';" 2>/dev/null || echo "0")
        
        if [ "$table_count" -gt 0 ]; then
            log_success "数据库 $db 初始化成功，包含 $table_count 张表"
        else
            log_warning "数据库 $db 可能未正确初始化"
        fi
    done
}

# 显示数据库信息
show_database_info() {
    log_info "数据库连接信息:"
    echo "  Host:     $MYSQL_HOST"
    echo "  Port:     $MYSQL_PORT"
    echo "  User:     $MYSQL_USER"
    echo "  Database: nacos, ggl_order"
    echo ""
    
    log_info "已初始化的数据库:"
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES LIKE '%nacos%'; SHOW DATABASES LIKE '%ggl_order%';" 2>/dev/null || true
}

# 主函数
main() {
    log_info "============================================"
    log_info "GGL-Hub 数据库初始化脚本"
    log_info "============================================"
    
    # 设置环境变量（默认值）
    export MYSQL_HOST=${MYSQL_HOST:-localhost}
    export MYSQL_PORT=${MYSQL_PORT:-3307}
    export MYSQL_USER=${MYSQL_USER:-root}
    export MYSQL_PASSWORD=${MYSQL_PASSWORD:-123456}
    
    log_info "使用以下配置:"
    log_info "  MySQL Host: $MYSQL_HOST"
    log_info "  MySQL Port: $MYSQL_PORT"
    log_info "  MySQL User: $MYSQL_USER"
    
    # 检查 MySQL 连接
    check_mysql_connection || exit 1
    
    # 初始化数据库
    init_nacos_database
    init_order_database
    
    # 验证初始化结果
    verify_databases
    
    # 显示数据库信息
    show_database_info
    
    log_success "============================================"
    log_success "所有数据库初始化完成！"
    log_success "============================================"
    echo ""
    log_info "下一步操作:"
    log_info "  1. 启动 Nacos 服务: docker-compose up -d nacos"
    log_info "  2. 访问 Nacos 控制台: http://localhost:8848/nacos"
    log_info "  3. 默认登录账号: nacos/nacos"
    log_info "  4. 启动订单服务: docker-compose up -d ggl-service-order"
    echo ""
}

# 执行主函数
main "$@"