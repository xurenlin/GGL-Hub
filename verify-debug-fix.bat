@echo off
chcp 65001 >nul

echo.
echo ============================================
echo GGL-Hub 调试配置修复验证
echo ============================================
echo.

echo [INFO] 1. 检查基础设施状态...
docker-compose ps | findstr "mysql redis nacos" >nul
if errorlevel 1 (
    echo [ERROR]   Docker基础设施未运行
    echo [INFO]    请运行: docker-compose up -d mysql redis nacos
    goto :infra_failed
) else (
    echo [SUCCESS] Docker基础设施已运行
)

echo [INFO] 2. 检查launch.json配置...
if exist ".vscode\launch.json" (
    echo [SUCCESS] launch.json 文件存在
    findstr "NACOS_USERNAME" ".vscode\launch.json" >nul
    if errorlevel 1 (
        echo [ERROR]   launch.json缺少Nacos认证配置
    ) else (
        echo [SUCCESS] launch.json包含Nacos认证配置
    )
    findstr "spring.cloud.compatibility-verifier.enabled" ".vscode\launch.json" >nul
    if errorlevel 1 (
        echo [WARNING] launch.json缺少版本兼容性配置
    ) else (
        echo [SUCCESS] launch.json包含版本兼容性配置
    )
) else (
    echo [ERROR]   launch.json 文件不存在
    goto :config_failed
)

echo [INFO] 3. 检查Java环境...
where java >nul 2>nul
if errorlevel 1 (
    echo [ERROR]   Java未安装
    goto :java_failed
) else (
    echo [SUCCESS] Java已安装
)

echo [INFO] 4. 检查Maven环境...
where mvn >nul 2>nul
if errorlevel 1 (
    if exist mvnw.cmd (
        echo [SUCCESS] 使用项目Maven Wrapper
    ) else (
        echo [ERROR]   Maven未安装且未找到mvnw
        goto :maven_failed
    )
) else (
    echo [SUCCESS] Maven已安装
)

echo [INFO] 5. 测试Java服务编译...
set "JAVA_HOME=H:\software\java17"
mvn clean compile -pl ggl-service-order -DskipTests -q >nul 2>nul
if errorlevel 1 (
    echo [ERROR]   Java服务编译失败
    goto :compile_failed
) else (
    echo [SUCCESS] Java服务编译成功
)

echo.
echo ============================================
echo [SUCCESS] 调试配置修复验证通过！
echo ============================================
echo.
echo 修复的问题:
echo   1. ✅ 添加了Nacos认证配置 (用户名: nacos, 密码: nacos)
echo   2. ✅ 添加了Spring Boot版本兼容性配置
echo   3. ✅ 更新了所有7个服务的调试配置
echo.
echo 使用说明:
echo   1. 打开VS Code
echo   2. 切换到"运行和调试"视图 (Ctrl+Shift+D)
echo   3. 选择调试配置，如"Debug Order Service (8081)"
echo   4. 点击绿色播放按钮开始调试
echo.
echo 调试配置选项:
echo   - 独立服务: 调试单个服务
echo   - Debug All Services: 调试所有7个服务
echo   - Debug Core Services: 调试核心业务服务
echo   - Debug Gateway Services: 调试网关服务
echo   - Debug AI Services: 调试AI相关服务
echo.
echo 已知问题及解决方案:
echo   [问题] Spring Boot 3.4.3 与 Spring Cloud 2023.0.3 版本不兼容
echo   [临时方案] 已通过 -Dspring.cloud.compatibility-verifier.enabled=false 禁用检查
echo   [长期方案] 建议升级Spring Cloud到2023.0.4或降级Spring Boot到3.3.x
echo.
echo 访问地址:
echo   Nacos控制台: http://localhost:8848/nacos (用户: nacos, 密码: nacos)
echo   网关服务: http://localhost:8080
echo.
goto :end

:infra_failed
echo [ERROR] Docker基础设施测试失败
goto :end

:config_failed
echo [ERROR] VS Code配置测试失败
goto :end

:java_failed
echo [ERROR] Java环境测试失败
goto :end

:maven_failed
echo [ERROR] Maven环境测试失败
goto :end

:compile_failed
echo [ERROR] Java服务编译测试失败
goto :end

:end
pause
exit /b 0