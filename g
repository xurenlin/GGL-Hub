@echo off
REM 设置项目使用 Java 17
set JAVA_HOME=H:\software\java17
set PATH=%JAVA_HOME%\bin;%PATH%

REM 执行 Maven 命令
call mvn %*
