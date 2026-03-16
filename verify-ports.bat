@echo off
chcp 65001 >nul

echo.
echo ============================================
echo GGL-Hub 端口配置验证
echo ============================================
echo.

echo [INFO] 1. 检查launch.json端口配置...
if exist ".vscode\launch.json" (
    echo [SUCCESS] launch.json 文件存在
    
    echo [INFO]   检查服务端口配置:
    findstr /C:"Debug Order Service" ".vscode\launch.json" | findstr "9801" >nul
    if errorlevel 1 (echo [ERROR]   订单服务端口未配置为9801) else (echo [SUCCESS] 订单服务端口: 9801)
    
    findstr /C:"Debug Geo Service" ".vscode\launch.json" | findstr "9802" >nul
    if errorlevel 1 (echo [ERROR]   地理服务端口未配置为9802) else (echo [SUCCESS] 地理服务端口: 9802)
    
    findstr /C:"Debug I18n Service" ".vscode\launch.json" | findstr "9803" >nul
    if errorlevel 1 (echo [ERROR]   国际化服务端口未配置为9803) else (echo [SUCCESS] 国际化服务端口: 9803)
    
    findstr /C:"Debug RAG Service" ".vscode\launch.json" | findstr "9804" >nul
    if errorlevel 1 (echo [ERROR]   RAG服务端口未配置为9804) else (echo [SUCCESS] RAG服务端口: 9804)
    
    findstr /C:"Debug Guardrail Service" ".vscode\launch.json" | findstr "9805" >nul
    if errorlevel 1 (echo [ERROR]   护栏服务端口未配置为9805) else (echo [SUCCESS] 护栏服务端口: 9805)
    
    findstr /C:"Debug Gateway Service" ".vscode\launch.json" | findstr "9800" >nul
    if errorlevel 1 (echo [ERROR]   网关服务端口未配置为9800) else (echo [SUCCESS] 网关服务端口: 9800)
    
    findstr /C:"Debug AI Gateway Service" ".vscode\launch.json" | findstr "9806" >nul
    if errorlevel 1 (echo [ERROR]   AI网关服务端口未配置为9806) else (echo [SUCCESS] AI网关服务端口: 9806)
    
    echo [INFO]   检查复合配置:
    findstr /C:"Debug All Services" -A 10 ".vscode\launch.json" | findstr "980" >nul
    if errorlevel 1 (echo [WARNING] 复合配置可能未更新) else (echo [SUCCESS] 复合配置已更新)
) else (
    echo [ERROR]   launch.json 文件不存在
    goto :config_failed
)

echo.
echo [INFO] 2. 检查端口占用情况...
echo [INFO]   检查9800-9806端口:
for /L %%i in (9800,1,9806) do (
    netstat -ano | findstr ":%%i " >nul
    if errorlevel 1 (
        echo [SUCCESS] 端口 %%i 可用
    ) else (
        echo [WARNING] 端口 %%i 已被占用
    )
)

echo.
echo [INFO] 3. 检查基础设施端口...
echo [INFO]   MySQL端口: 3307
netstat -ano | findstr ":3307 " >nul
if errorlevel 1 (echo [ERROR]   MySQL端口3307未监听) else (echo [SUCCESS] MySQL端口3307已监听)

echo [INFO]   Redis端口: 6379
netstat -ano | findstr ":6379 " >nul
if errorlevel 1 (echo [ERROR]   Redis端口6379未监听) else (echo [SUCCESS] Redis端口6379已监听)

echo [INFO]   Nacos端口: 8848
netstat -ano | findstr ":8848 " >nul
if errorlevel 1 (echo [ERROR]   Nacos端口8848未监听) else (echo [SUCCESS] Nacos端口8848已监听)

echo.
echo ============================================
echo [SUCCESS] 端口配置验证完成！
echo ============================================
echo.
echo 端口分配总结:
echo   网关服务: 9800
echo   订单服务: 9801
echo   地理服务: 9802
echo   国际化服务: 9803
echo   RAG服务: 9804
echo   护栏服务: 9805
echo   AI网关服务: 9806
echo.
echo 基础设施端口:
echo   MySQL: 3307
echo   Redis: 6379
echo   Nacos: 8848
echo.
echo 使用说明:
echo   1. 打开VS Code
echo   2. 切换到"运行和调试"视图 (Ctrl+Shift+D)
echo   3. 选择调试配置，如"Debug Order Service (9801)"
echo   4. 点击绿色播放按钮开始调试
echo.
echo 访问地址:
echo   网关服务: http://localhost:9800
echo   订单服务: http://localhost:9801
echo   地理服务: http://localhost:9802
echo   国际化服务: http://localhost:9803
echo   RAG服务: http://localhost:9804
echo   护栏服务: http://localhost:9805
echo   AI网关服务: http://localhost:9806
echo   Nacos控制台: http://localhost:8848/nacos
echo.
goto :end

:config_failed
echo [ERROR] 配置检查失败
goto :end

:end
pause
exit /b 0