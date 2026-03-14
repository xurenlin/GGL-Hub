@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM Nacos 持久化验证脚本 (Windows 版本)
REM 验证 Nacos 是否正确持久化到 MySQL
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

REM 检查服务状态
:check_service_status
    setlocal
    set "service_name=%~1"
    set "service_url=%~2"
    
    call :log_info "检查服务状态: !service_name!"
    
    curl -s -f "!service_url!" >nul 2>nul
    if !errorlevel! equ 0 (
        call :log_success "!service_name! 运行正常"
        endlocal
        exit /b 0
    ) else (
        call :log_error "!service_name! 无法访问"
        endlocal
        exit /b 1
    )

REM 检查 MySQL 数据库
:check_mysql_database
    setlocal
    set "db_name=%~1"
    
    call :log_info "检查 MySQL 数据库: !db_name!"
    
    for /f "tokens=*" %%t in ('mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '!db_name!';" 2^>nul') do set "table_count=%%t"
    
    if not defined table_count set "table_count=0"
    
    if !table_count! gtr 0 (
        call :log_success "数据库 !db_name! 存在，包含 !table_count! 张表"
        endlocal
        exit /b 0
    ) else (
        call :log_error "数据库 !db_name! 不存在或为空"
        endlocal
        exit /b 1
    )

REM 检查 Nacos 配置持久化
:check_nacos_persistence
    call :log_info "检查 Nacos 配置持久化..."
    
    REM 创建测试配置
    set "timestamp=!time:~0,2!!time:~3,2!!time:~6,2!"
    set "test_data_id=test-persistence-!timestamp!"
    set "test_content=test-content-!timestamp!"
    
    call :log_info "创建测试配置: !test_data_id!"
    
    REM 通过 Nacos API 创建配置
    for /f "tokens=*" %%r in ('curl -s -X POST "http://localhost:8848/nacos/v1/cs/configs" -d "dataId=!test_data_id!" -d "group=DEFAULT_GROUP" -d "content=!test_content!" -d "type=yaml" -H "Content-Type: application/x-www-form-urlencoded"') do set "create_response=%%r"
    
    if "!create_response!"=="true" (
        call :log_success "测试配置创建成功"
    ) else (
        call :log_error "测试配置创建失败: !create_response!"
        exit /b 1
    )
    
    REM 重启 Nacos 服务
    call :log_info "重启 Nacos 服务..."
    docker restart ggl-nacos >nul 2>&1
    
    REM 等待 Nacos 重启
    call :log_info "等待 Nacos 重启..."
    timeout /t 30 /nobreak >nul
    
    REM 检查 Nacos 是否恢复
    call :check_service_status "Nacos" "http://localhost:8848/nacos"
    if !errorlevel! neq 0 (
        call :log_error "Nacos 重启后无法访问"
        exit /b 1
    )
    
    REM 验证配置是否持久化
    call :log_info "验证配置持久化..."
    for /f "tokens=*" %%g in ('curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=!test_data_id!&group=DEFAULT_GROUP"') do set "get_response=%%g"
    
    if "!get_response!"=="!test_content!" (
        call :log_success "配置持久化验证成功"
        
        REM 清理测试配置
        curl -s -X DELETE "http://localhost:8848/nacos/v1/cs/configs?dataId=!test_data_id!&group=DEFAULT_GROUP" >nul 2>&1
        call :log_info "清理测试配置"
        
        exit /b 0
    ) else (
        call :log_error "配置持久化验证失败"
        call :log_info "期望内容: !test_content!"
        call :log_info "实际内容: !get_response!"
        exit /b 1
    )

REM 检查数据库连接配置
:check_database_connection
    call :log_info "检查 Nacos 数据库连接配置..."
    
    for /f "tokens=*" %%c in ('docker exec ggl-nacos cat /home/nacos/conf/application.properties 2^>nul ^| findstr /i "spring.datasource db.url db.user"') do set "db_config=%%c"
    
    if defined db_config (
        call :log_success "Nacos 数据库配置存在"
        echo !db_config!
    ) else (
        call :log_warning "未找到 Nacos 数据库配置"
    )
    exit /b 0

REM 显示持久化状态
:show_persistence_status
    call :log_info "持久化状态汇总:"
    echo.
    
    call :log_info "MySQL 中的 Nacos 表:"
    mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "USE nacos; SHOW TABLES;" 2>nul | findstr /v "Tables_in" | while read table do (
        if defined table (
            call :log_info "  - !table!"
        )
    )
    
    echo.
    
    REM 检查配置数量
    for /f "tokens=*" %%c in ('mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -N -e "USE nacos; SELECT COUNT(*) FROM config_info;" 2^>nul') do set "config_count=%%c"
    if not defined config_count set "config_count=0"
    call :log_info "Nacos 配置数量: !config_count!"
    
    REM 检查用户数量
    for /f "tokens=*" %%u in ('mysql -h%MYSQL_HOST% -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -N -e "USE nacos; SELECT COUNT(*) FROM users;" 2^>nul') do set "user_count=%%u"
    if not defined user_count set "user_count=0"
    call :log_info "Nacos 用户数量: !user_count!"
    exit /b 0

REM 主函数
:main
    call :log_info "============================================"
    call :log_info "Nacos 持久化验证脚本"
    call :log_info "============================================"
    
    REM 设置环境变量
    if not defined MYSQL_HOST set "MYSQL_HOST=localhost"
    if not defined MYSQL_PORT set "MYSQL_PORT=3307"
    if not defined MYSQL_USER set "MYSQL_USER=root"
    if not defined MYSQL_PASSWORD set "MYSQL_PASSWORD=123456"
    
    call :log_info "使用以下配置:"
    call :log_info "  MySQL Host: %MYSQL_HOST%"
    call :log_info "  MySQL Port: %MYSQL_PORT%"
    call :log_info "  MySQL User: %MYSQL_USER%"
    echo.
    
    REM 检查基础服务
    call :log_info "检查基础服务状态..."
    call :check_service_status "MySQL" "%MYSQL_HOST%:%MYSQL_PORT%"
    if !errorlevel! neq 0 exit /b 1
    
    call :check_service_status "Nacos" "http://localhost:8848/nacos"
    if !errorlevel! neq 0 exit /b 1
    
    REM 检查数据库
    call :check_mysql_database "nacos"
    if !errorlevel! neq 0 exit /b 1
    
    REM 检查数据库连接配置
    call :check_database_connection
    
    REM 显示持久化状态
    call :show_persistence_status
    
    echo.
    call :log_info "开始持久化验证测试..."
    echo.
    
    REM 执行持久化验证
    call :check_nacos_persistence
    
    if !errorlevel! equ 0 (
        call :log_success "============================================"
        call :log_success "Nacos 持久化验证成功！"
        call :log_success "============================================"
        echo.
        call :log_info "验证结果:"
        call :log_info "  ✓ MySQL 数据库连接正常"
        call :log_info "  ✓ Nacos 表结构正确"
        call :log_info "  ✓ 配置数据持久化成功"
        call :log_info "  ✓ 服务重启后数据恢复正常"
        echo.
        call :log_info "Nacos 已正确配置为使用 MySQL 持久化存储。"
    ) else (
        call :log_error "============================================"
        call :log_error "Nacos 持久化验证失败！"
        call :log_error "============================================"
        echo.
        call :log_info "可能的原因:"
        call :log_info "  1. MySQL 数据库未正确初始化"
        call :log_info "  2. Nacos 数据库配置错误"
        call :log_info "  3. 网络连接问题"
        call :log_info "  4. 权限配置问题"
        echo.
        call :log_info "请检查:"
        call :log_info "  1. 运行 init-scripts\init-all.bat 初始化数据库"
        call :log_info "  2. 检查 docker-compose.yml 中的环境变量"
        call :log_info "  3. 查看 Nacos 日志: docker logs ggl-nacos"
        exit /b 1
    )
    exit /b 0

REM 执行主函数
call :main
if !errorlevel! neq 0 (
    pause
    exit /b 1
)
pause