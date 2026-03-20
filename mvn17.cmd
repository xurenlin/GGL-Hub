@echo off
REM 设置项目专用的 Java 17 环境
set JAVA_HOME=H:\software\Java17
set PATH=%JAVA_HOME%\bin;%PATH%

REM 调用 Maven Wrapper
call "%~dp0mvnw.cmd" %*
