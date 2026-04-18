@echo off
REM 飞书技能包部署脚本 - Windows CMD
REM 用法: deploy-feishu-skills.bat [zip文件路径]

echo ============================================
echo   飞书 Lark CLI 技能包部署脚本
echo   平台: Windows (CMD)
echo ============================================

REM 1. 检查 ZIP 文件
set "ZIP_FILE=%~1"
if "%ZIP_FILE%"=="" (
    if exist "feishu-lark-cli-skills.zip" (
        set "ZIP_FILE=feishu-lark-cli-skills.zip"
    ) else (
        echo [ERROR] 未指定 ZIP 文件且当前目录未找到 feishu-lark-cli-skills.zip
        echo.
        echo 用法: deploy-feishu-skills.bat [path\to\feishu-lark-cli-skills.zip]
        echo 或者将 .zip 文件放在当前目录后重新运行
        exit /b 1
    )
)

if not exist "%ZIP_FILE%" (
    echo [ERROR] 找不到文件: %ZIP_FILE%
    exit /b 1
)

echo [INFO] 找到技能包: %ZIP_FILE%

REM 2. 检查 Hermes
set "HERMES_DIR=%USERPROFILE%\.hermes"
if not exist "%HERMES_DIR%" (
    echo [ERROR] 未找到 Hermes 目录: %HERMES_DIR%
    echo 请先安装 Hermes Agent: https://github.com/ai-playground-zzw/hermes-agent
    exit /b 1
)
echo [OK] 找到 Hermes 目录

REM 3. 检查 Node.js
where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] 未找到 Node.js，请先安装 Node.js 18+
    echo 下载: https://nodejs.org/
    exit /b 1
)
echo [OK] Node.js 已安装

REM 4. 检查/安装 lark-cli
where lark-cli >nul 2>nul
if errorlevel 1 (
    echo [WARN] 未找到 lark-cli，尝试安装...
    where npm >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] 未找到 npm，请先安装 Node.js
        exit /b 1
    )
    npm install -g @larksuite/cli
    echo [OK] lark-cli 安装完成
) else (
    echo [OK] 已安装 lark-cli
)

REM 5. 创建技能目录
set "TARGET_DIR=%HERMES_DIR%\skills\messaging"
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
echo [OK] 技能目录: %TARGET_DIR%

REM 6. 解压技能包
echo.
echo [INFO] 解压技能包...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TARGET_DIR%' -Force"
if errorlevel 1 (
    echo [ERROR] 解压失败，请检查 ZIP 文件是否损坏
    exit /b 1
)
echo [OK] 解压完成

REM 7. 验证安装
echo.
echo [INFO] 验证安装...
if exist "%TARGET_DIR%\feishu-file-send-lark-cli" echo [OK] feishu-file-send-lark-cli
if exist "%TARGET_DIR%\feishu-message-send-lark-cli" echo [OK] feishu-message-send-lark-cli
if exist "%TARGET_DIR%\feishu-doc-create-lark-cli" echo [OK] feishu-doc-create-lark-cli

REM 8. 检查 lark-cli 登录状态
echo.
lark-cli auth list --format json >nul 2>nul
if errorlevel 1 (
    echo [WARN] lark-cli 未登录或 token 失效
    echo 请运行以下命令登录：
    echo   lark-cli auth login
) else (
    echo [OK] lark-cli 已登录
)

REM 9. 重载 Hermes 技能
echo.
where hermes >nul 2>nul
if not errorlevel 1 (
    echo [INFO] 重载 Hermes 技能...
    hermes skills reload >nul 2>nul
    echo [OK] Hermes 技能已重载
)

echo.
echo ============================================
echo ✅ 部署完成！
echo ============================================
echo.
echo 快速测试：
echo   hermes
echo   /feishu-file-send-lark-cli --help
echo.
echo 获取 chat_id：
echo   lark-cli im +messages-search --query "" --format json
echo.
