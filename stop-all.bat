@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM GGL-Hub 企业级全球化智能物流调度平台
REM 一键停止所有服务脚本 (Windows)
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
    exit /b 0

REM 主函数
:main
    call :log_info "开始停止 GGL-Hub 所有服务..."
    call :log_info "项目根目录: %cd%"
    
    REM 检查依赖
    call :check_docker_compose
    if errorlevel 1 exit /b 1
    
    REM 停止所有服务
    call :log_info "停止所有服务..."
    %DOCKER_COMPOSE_CMD% down
    
    call :log_success "============================================"
    call :log_success "GGL-Hub 所有服务已停止"
    call :log_success "============================================"
    echo.
    call :log_info "清理所有容器和网络:"
    call :log_info "  %DOCKER_COMPOSE_CMD% down --remove-orphans --volumes"
    echo.
    call :log_info "查看 Docker 容器状态:"
    call :log_info "  docker ps -a"
    echo.
    call :log_info "重新启动服务:"
    call :log_info "  start-all.bat"
    exit /b 0

REM 执行主函数
call :main
if errorlevel 1 (
    pause
    exit /b 1
)
pause
