@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM GGL-Hub 数据库统一初始化脚本 (Windows 版本)
REM 版本: 1.0.0
REM 创建时间: %date% %time%
REM ============================================

REM 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 日志函数
:log_info
    echo %BLUE%[INFO]%NC% %*
    exit /b 0

:log_success
    echo %GREEN%[SUCCESS]%NC% %*
    exit /b 0

:log_warning
    echo %YELLOW%[WARNING]%NC% %*
    exit /b 0

:log_error
    echo %RED%[ERROR]%NC% %*
    exit /b 1

REM 检查 MySQL 连接
:check_mysql_connection
    call :log_info "检查 MySQL 连接..."
    
    set "max_retries=30"
    set "retry_count=0"
    
    :mysql_retry_loop
    if !retry_count! geq !max_retries! (
        call :log_error "MySQL 连接失败，请检查服务是否正常运行"
        exit /b 1
    )
    
    mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 1;" >nul 2>&1
    if !errorlevel! equ 0 (
        call :log_success "MySQL 连接成功"
        exit /b 0
    )
    
    set /a retry_count+=1
    call :log_info "等待 MySQL 启动... (!retry_count!/!max_retries!)"
    timeout /t 2 /nobreak >nul
    goto mysql_retry_loop

REM 执行 SQL 文件
:execute_sql_file
    setlocal
    set "sql_file=%~1"
    set "db_name=%~2"
    
    if not exist "!sql_file!" (
        call :log_error "SQL 文件不存在: !sql_file!"
        endlocal
        exit /b 1
    )
    
    for %%f in ("!sql_file!") do set "filename=%%~nxf"
    call :log_info "执行 SQL 文件: !filename!"
    
    if "!db_name!"=="" (
        mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "!sql_file!"
    ) else (
        mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% !db_name! < "!sql_file!"
    )
    
    if !errorlevel! equ 0 (
        call :log_success "SQL 文件执行成功: !filename!"
        endlocal
        exit /b 0
    ) else (
        call :log_error "SQL 文件执行失败: !filename!"
        endlocal
        exit /b 1
    )

REM 初始化 Nacos 数据库
:init_nacos_database
    call :log_info "开始初始化 Nacos 数据库..."
    
    call :log_info "创建 nacos 数据库..."
    mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS nacos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
    
    call :execute_sql_file "nacos-schema.sql" "nacos"
    if !errorlevel! neq 0 exit /b 1
    
    call :log_success "Nacos 数据库初始化完成"
    exit /b 0

REM 初始化订单服务数据库
:init_order_database
    call :log_info "开始初始化订单服务数据库..."
    
    call :execute_sql_file "ggl-order-schema.sql"
    if !errorlevel! neq 0 exit /b 1
    
    call :log_success "订单服务数据库初始化完成"
    exit /b 0

REM 验证数据库初始化
:verify_databases
    call :log_info "验证数据库初始化..."
    
    set "databases=nacos ggl_order"
    
    for %%d in (!databases!) do (
        call :log_info "检查数据库: %%d"
        
        for /f "tokens=*" %%t in ('mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '\''%%d'\'';" 2^>nul') do set "table_count=%%t"
        
        if not defined table_count set "table_count=0"
        
        if !table_count! gtr 0 (
            call :log_success "数据库 %%d 初始化成功，包含 !table_count! 张表"
        ) else (
            call :log_warning "数据库 %%d 可能未正确初始化"
        )
    )
    exit /b 0

REM 显示数据库信息
:show_database_info
    call :log_info "数据库连接信息:"
    echo    Host:     %MYSQL_HOST%
    echo    Port:     %MYSQL_PORT%
    echo    User:     %MYSQL_USER%
    echo    Database: nacos, ggl_order
    echo.
    
    call :log_info "已初始化的数据库:"
    mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SHOW DATABASES LIKE '%%nacos%%'; SHOW DATABASES LIKE '%%ggl_order%%';" 2>nul || echo "无法显示数据库列表"
    exit /b 0

REM 主函数
:main
    call :log_info "============================================"
    call :log_info "GGL-Hub 数据库初始化脚本"
    call :log_info "============================================"
    
    REM 设置环境变量（默认值）
    if not defined MYSQL_HOST set "MYSQL_HOST=localhost"
    if not defined MYSQL_PORT set "MYSQL_PORT=3307"
    if not defined MYSQL_USER set "MYSQL_USER=root"
    if not defined MYSQL_PASSWORD set "MYSQL_PASSWORD=123456"
    
    call :log_info "使用以下配置:"
    call :log_info "  MySQL Host: %MYSQL_HOST%"
    call :log_info "  MySQL Port: %MYSQL_PORT%"
    call :log_info "  MySQL User: %MYSQL_USER%"
    
    REM 检查 MySQL 连接
    call :check_mysql_connection
    if !errorlevel! neq 0 exit /b 1
    
    REM 初始化数据库
    call :init_nacos_database
    if !errorlevel! neq 0 exit /b 1
    
    call :init_order_database
    if !errorlevel! neq 0 exit /b 1
    
    REM 验证初始化结果
    call :verify_databases
    
    REM 显示数据库信息
    call :show_database_info
    
    call :log_success "============================================"
    call :log_success "所有数据库初始化完成！"
    call :log_success "============================================"
    echo.
    call :log_info "下一步操作:"
    call :log_info "  1. 启动 Nacos 服务: docker-compose up -d nacos"
    call :log_info "  2. 访问 Nacos 控制台: http://localhost:8848/nacos"
    call :log_info "  3. 默认登录账号: nacos/nacos"
    call :log_info "  4. 启动订单服务: docker-compose up -d ggl-service-order"
    echo.
    exit /b 0

REM 执行主函数
call :main
if !errorlevel! neq 0 (
    pause
    exit /b 1
)
pause