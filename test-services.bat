@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================
REM GGL-Hub 服务测试脚本
REM 测试所有服务是否正常运行
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

REM 测试服务端点
:test_endpoint
    setlocal
    set "service_name=%~1"
    set "url=%~2"
    set "timeout=%~3"
    
    call :log_info "测试服务: %service_name%"
    call :log_info "URL: %url%"
    
    curl -s -f --max-time %timeout% "%url%" >nul 2>nul
    if errorlevel 1 (
        call :log_error "服务 %service_name% 测试失败"
        endlocal
        exit /b 1
    )
    
    call :log_success "服务 %service_name% 测试成功"
    endlocal
    exit /b 0

REM 主函数
:main
    call :log_info "开始测试 GGL-Hub 所有服务..."
    call :log_info "项目根目录: %cd%"
    
    REM 测试基础服务
    call :log_info "测试基础服务..."
    call :test_endpoint "Nacos" "http://localhost:8848/nacos" 10
    if errorlevel 1 exit /b 1
    
    REM 测试 Java 微服务健康端点
    call :log_info "测试 Java 微服务健康端点..."
    
    call :test_endpoint "网关服务" "http://localhost:8080/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "订单服务" "http://localhost:8081/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "地理信息服务" "http://localhost:8082/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "国际化服务" "http://localhost:8083/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "知识检索服务" "http://localhost:8084/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "AI安全防护服务" "http://localhost:8085/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    call :test_endpoint "AI编排网关服务" "http://localhost:8086/actuator/health" 10
    if errorlevel 1 exit /b 1
    
    REM 测试 API 文档端点
    call :log_info "测试 API 文档端点..."
    
    call :test_endpoint "网关 API 文档" "http://localhost:8080/doc.html" 10
    if errorlevel 1 (
        call :log_warning "网关 API 文档不可用，跳过..."
    )
    
    REM 显示测试结果
    call :log_success "============================================"
    call :log_success "所有服务测试完成！"
    call :log_success "============================================"
    echo.
    call :log_info "服务状态汇总:"
    echo.
    call :log_info "基础服务:"
    echo    Nacos:           http://localhost:8848/nacos
    echo    MySQL:           localhost:3307
    echo    Redis:           localhost:6379
    echo.
    call :log_info "Java 微服务:"
    echo    网关服务:        http://localhost:8080
    echo    订单服务:        http://localhost:8081
    echo    地理信息服务:    http://localhost:8082
    echo    国际化服务:      http://localhost:8083
    echo    知识检索服务:    http://localhost:8084
    echo    AI安全防护服务:  http://localhost:8085
    echo    AI编排网关服务:  http://localhost:8086
    echo.
    call :log_info "监控服务:"
    echo    Prometheus:      http://localhost:9090
    echo    Grafana:         http://localhost:3000
    echo    Jaeger:          http://localhost:16686
    echo.
    call :log_info "管理界面:"
    echo    Portainer:       http://localhost:9000
    echo    RedisInsight:    http://localhost:5540
    echo    MinIO Console:   http://localhost:9003
    echo    Kibana:          http://localhost:5601
    echo.
    call :log_info "下一步操作:"
    call :log_info "  1. 访问网关服务: http://localhost:8080"
    call :log_info "  2. 查看服务日志: docker-compose logs -f"
    call :log_info "  3. 停止所有服务: stop-all.bat"
    exit /b 0

REM 执行主函数
call :main
if errorlevel 1 (
    pause
    exit /b 1
)
pause
