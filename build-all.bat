@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM GGL-Hub 企业级全球化智能物流调度平台
REM 一键构建所有微服务 Docker 镜像脚本 (Windows)
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

REM 检查 Maven 是否安装
:check_maven
    where mvn >nul 2>nul
    if errorlevel 1 (
        call :log_error "Maven 未安装，请先安装 Maven"
        exit /b 1
    )
    for /f "tokens=*" %%i in ('mvn -v ^| findstr /i "Apache Maven"') do (
        call :log_info "Maven 版本: %%i"
    )
    exit /b 0

REM 检查 Docker 是否安装
:check_docker
    where docker >nul 2>nul
    if errorlevel 1 (
        call :log_error "Docker 未安装，请先安装 Docker"
        exit /b 1
    )
    for /f "tokens=*" %%i in ('docker --version') do (
        call :log_info "Docker 版本: %%i"
    )
    exit /b 0

REM 构建单个服务
:build_service
    setlocal
    set "service_name=%~1"
    set "service_dir=%~2"
    
    call :log_info "开始构建服务: %service_name%"
    
    REM 进入服务目录
    pushd "%service_dir%"
    if errorlevel 1 (
        call :log_error "无法进入目录: %service_dir%"
        exit /b 1
    )
    
    REM 清理并打包
    call :log_info "执行 Maven 清理和打包..."
    mvn clean package -DskipTests
    if errorlevel 1 (
        call :log_error "Maven 打包失败: %service_name%"
        popd
        exit /b 1
    )
    call :log_success "Maven 打包成功: %service_name%"
    
    REM 构建 Docker 镜像
    call :log_info "构建 Docker 镜像..."
    docker build -t "ggl-hub/%service_name%:latest" .
    if errorlevel 1 (
        call :log_error "Docker 镜像构建失败: %service_name%"
        popd
        exit /b 1
    )
    call :log_success "Docker 镜像构建成功: ggl-hub/%service_name%:latest"
    
    REM 返回项目根目录
    popd
    endlocal
    exit /b 0

REM 主函数
:main
    call :log_info "开始构建 GGL-Hub 所有微服务..."
    call :log_info "项目根目录: %cd%"
    
    REM 检查依赖
    call :check_maven
    if errorlevel 1 exit /b 1
    call :check_docker
    if errorlevel 1 exit /b 1
    
    REM 服务列表
    set "services=ggl-common ggl-gateway ggl-ai-gateway ggl-service-order ggl-service-geo ggl-service-i18n ggl-service-rag ggl-service-guardrail"
    
    REM 构建公共模块
    call :log_info "构建公共模块..."
    pushd ggl-common
    if errorlevel 1 (
        call :log_error "无法进入 ggl-common 目录"
        exit /b 1
    )
    mvn clean install -DskipTests
    if errorlevel 1 (
        call :log_error "公共模块构建失败"
        popd
        exit /b 1
    )
    popd
    call :log_success "公共模块构建完成"
    
    REM 构建所有服务
    for %%s in (%services%) do (
        if not "%%s"=="ggl-common" (
            call :build_service "%%s" "%%s"
            if errorlevel 1 (
                call :log_error "构建服务 %%s 失败，停止构建"
                exit /b 1
            )
        )
    )
    
    call :log_success "============================================"
    call :log_success "所有微服务 Docker 镜像构建完成！"
    call :log_success "============================================"
    echo.
    call :log_info "可用的 Docker 镜像:"
    docker images | findstr "ggl-hub"
    echo.
    call :log_info "启动所有服务:"
    call :log_info "  docker-compose up -d"
    echo.
    call :log_info "查看服务状态:"
    call :log_info "  docker-compose ps"
    echo.
    call :log_info "查看服务日志:"
    call :log_info "  docker-compose logs -f"
    exit /b 0

REM 执行主函数
call :main
if errorlevel 1 (
    pause
    exit /b 1
)
pause
