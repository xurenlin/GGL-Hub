@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM GGL-Hub 企业级全球化智能物流调度平台
REM 一键启动所有服务脚本 (Windows)
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
    exit /b 0

REM 检查 Docker 是否安装
:check_docker
    where docker >nul 2>nul
    if errorlevel 1 (
        call :log_error "Docker 未安装，请先安装 Docker"
        exit /b 1
    )
    exit /b 0

REM 检查 Docker Compose 是否安装
:check_docker_compose
    where docker-compose >nul 2>nul
    if not errorlevel 1 (
        set "DOCKER_COMPOSE_CMD=docker-compose"
        goto :compose_found
    )
    
    REM 尝试使用 docker compose 插件
    docker compose version >nul 2>nul
    if not errorlevel 1 (
        set "DOCKER_COMPOSE_CMD=docker compose"
        goto :compose_found
    )
    
    call :log_error "Docker Compose 未安装，请先安装 Docker Compose"
    exit /b 1
    
:compose_found
    call :log_info "Docker Compose 命令: %DOCKER_COMPOSE_CMD%"
    exit /b 0

REM 等待服务就绪
:wait_for_service
    setlocal
    set "service_name=%~1"
    set "url=%~2"
    set "max_attempts=%~3"
    set "attempt=1"
    
    call :log_info "等待服务 %service_name% 启动..."
    
:wait_loop
    if %attempt% gtr %max_attempts% (
        call :log_error "服务 %service_name% 启动超时"
        endlocal
        exit /b 1
    )
    
    curl -s -f "%url%" >nul 2>nul
    if not errorlevel 1 (
        call :log_success "服务 %service_name% 已就绪"
        endlocal
        exit /b 0
    )
    
    call :log_info "尝试 %attempt%/%max_attempts%: 服务 %service_name% 尚未就绪，等待 5 秒..."
    timeout /t 5 /nobreak >nul
    set /a attempt+=1
    goto :wait_loop

REM 显示服务状态
:show_services_status
    call :log_info "============================================"
    call :log_info "GGL-Hub 服务状态"
    call :log_info "============================================"
    echo.
    call :log_info "基础服务:"
    echo    Nacos ^(注册中心^):      http://localhost:8848/nacos
    echo    MySQL ^(数据库^):        localhost:3307
    echo    Redis ^(缓存^):          localhost:6379
    echo    RedisInsight ^(管理^):   http://localhost:5540
    echo.
    
    call :log_info "Java 微服务:"
    echo    网关服务:              http://localhost:8080
    echo    订单服务:              http://localhost:8081
    echo    地理信息服务:          http://localhost:8082
    echo    国际化服务:            http://localhost:8083
    echo    知识检索服务:          http://localhost:8084
    echo    AI安全防护服务:        http://localhost:8085
    echo    AI编排网关服务:        http://localhost:8086
    echo.
    
    call :log_info "监控与运维:"
    echo    Prometheus ^(监控^):     http://localhost:9090
    echo    Grafana ^(仪表板^):      http://localhost:3000
    echo    Jaeger ^(追踪^):         http://localhost:16686
    echo    Portainer ^(管理^):      http://localhost:9000
    echo    MinIO ^(对象存储^):      http://localhost:9002
    echo    Kibana ^(日志^):         http://localhost:5601
    echo.
    
    call :log_info "API 文档:"
    echo    网关 API 文档:         http://localhost:8080/doc.html
    echo    订单服务 API 文档:     http://localhost:8081/doc.html
    echo    地理服务 API 文档:     http://localhost:8082/doc.html
    echo    国际化服务 API 文档:   http://localhost:8083/doc.html
    echo    知识检索服务 API 文档: http://localhost:8084/doc.html
    echo    AI安全服务 API 文档:   http://localhost:8085/doc.html
    echo    AI网关服务 API 文档:   http://localhost:8086/doc.html
    echo.
    exit /b 0

REM 主函数
:main
    call :log_info "开始启动 GGL-Hub 所有服务..."
    call :log_info "项目根目录: %cd%"
    
    REM 检查依赖
    call :check_docker
    if errorlevel 1 exit /b 1
    call :check_docker_compose
    if errorlevel 1 exit /b 1
    
    REM 停止并清理旧容器
    call :log_info "停止并清理旧容器..."
    %DOCKER_COMPOSE_CMD% down --remove-orphans
    
    REM 启动所有服务
    call :log_info "启动所有服务..."
    %DOCKER_COMPOSE_CMD% up -d
    
    REM 等待基础服务启动
    call :log_info "等待基础服务启动..."
    call :wait_for_service "Nacos" "http://localhost:8848/nacos" 12
    if errorlevel 1 exit /b 1
    
    REM 等待 Java 微服务启动
    call :log_info "等待 Java 微服务启动..."
    call :wait_for_service "网关服务" "http://localhost:8080/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "订单服务" "http://localhost:8081/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "地理信息服务" "http://localhost:8082/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "国际化服务" "http://localhost:8083/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "知识检索服务" "http://localhost:8084/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "AI安全防护服务" "http://localhost:8085/actuator/health" 30
    if errorlevel 1 exit /b 1
    call :wait_for_service "AI编排网关服务" "http://localhost:8086/actuator/health" 30
    if errorlevel 1 exit /b 1
    
    REM 显示服务状态
    call :show_services_status
    
    call :log_success "============================================"
    call :log_success "GGL-Hub 所有服务启动完成！"
    call :log_success "============================================"
    echo.
    call :log_info "查看所有容器状态:"
    call :log_info "  %DOCKER_COMPOSE_CMD% ps"
    echo.
    call :log_info "查看服务日志:"
    call :log_info "  %DOCKER_COMPOSE_CMD% logs -f"
    echo.
    call :log_info "停止所有服务:"
    call :log_info "  %DOCKER_COMPOSE_CMD% down"
    echo.
    call :log_info "访问网关服务:"
    call :log_info "  http://localhost:8080"
    exit /b 0

REM 执行主函数
call :main
if errorlevel 1 (
    pause
    exit /b 1
)
pause
