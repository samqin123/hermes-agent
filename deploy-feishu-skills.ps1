# 飞书技能包部署脚本 - Windows (PowerShell)
# 用法: .\deploy-feishu-skills.ps1 [zip文件路径]
# 如不提供参数，脚本会尝试在当前目录查找 .zip 文件

# 设置执行策略（仅首次需要）
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  飞书 Lark CLI 技能包部署脚本" -ForegroundColor Cyan
Write-Host "  平台: Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# 1. 确定 ZIP 文件
$ZIP_FILE = $args[0]
if (-not $ZIP_FILE -or -not (Test-Path $ZIP_FILE)) {
    $candidates = @(
        "feishu-lark-cli-skills.zip",
        "feishu-lark-cli-skills-*.zip"
    )
    foreach ($cand in $candidates) {
        $found = Get-ChildItem -Path . -Filter $cand -File | Select-Object -First 1
        if ($found) {
            $ZIP_FILE = $found.FullName
            break
        }
    }
}

if (-not $ZIP_FILE -or -not (Test-Path $ZIP_FILE)) {
    Write-Host "[ERROR] 未找到技能包 ZIP 文件" -ForegroundColor Red
    Write-Host ""
    Write-Host "用法: .\deploy-feishu-skills.ps1 [path\to\feishu-lark-cli-skills.zip]"
    Write-Host ""
    Write-Host "或者将 .zip 文件放在当前目录后重新运行"
    exit 1
}

Write-Host "[INFO] 找到技能包: $ZIP_FILE" -ForegroundColor Green

# 2. 检查 Hermes
$hermesDir = "$env:USERPROFILE\.hermes"
if (-not (Test-Path $hermesDir)) {
    Write-Host "[ERROR] 未找到 Hermes 目录: $hermesDir" -ForegroundColor Red
    Write-Host "请先安装 Hermes Agent: https://github.com/ai-playground-zzw/hermes-agent"
    exit 1
}
Write-Host "[OK] 找到 Hermes 目录" -ForegroundColor Green

# 3. 检查 Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 未找到 Node.js，请先安装 Node.js 18+" -ForegroundColor Red
    Write-Host "下载: https://nodejs.org/"
    exit 1
}
Write-Host "[OK] Node.js 版本: $(node -v)" -ForegroundColor Green

# 4. 检查/安装 lark-cli
$larkCli = Get-Command lark-cli -ErrorAction SilentlyContinue
if ($larkCli) {
    Write-Host "[OK] 已安装 lark-cli" -ForegroundColor Green
} else {
    Write-Host "[WARN] 未找到 lark-cli，尝试安装..." -ForegroundColor Yellow
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g @larksuite/cli
        Write-Host "[OK] lark-cli 安装完成" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] 未找到 npm，请先安装 Node.js 或手动安装 lark-cli" -ForegroundColor Red
        Write-Host "参考: https://github.com/larksuite/lark-cli"
        exit 1
    }
}

# 5. 创建技能目录
$targetDir = "$hermesDir\skills\messaging"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Write-Host "[OK] 技能目录: $targetDir" -ForegroundColor Green

# 6. 解压技能包
Write-Host ""
Write-Host "[INFO] 解压技能包..." -ForegroundColor Cyan
Expand-Archive -Path $ZIP_FILE -DestinationPath $targetDir -Force
Write-Host "[OK] 解压完成" -ForegroundColor Green

# 7. 验证安装
Write-Host ""
Write-Host "[INFO] 验证安装..." -ForegroundColor Cyan
$skills = @('feishu-file-send-lark-cli', 'feishu-message-send-lark-cli', 'feishu-doc-create-lark-cli')
foreach ($skill in $skills) {
    $skillPath = Join-Path $targetDir $skill
    if (Test-Path $skillPath) {
        Write-Host "[OK] $skill" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $skill" -ForegroundColor Red
    }
}

# 8. 检查 lark-cli 登录状态
Write-Host ""
try {
    $authList = lark-cli auth list --format json 2>$null | ConvertFrom-Json
    if ($authList -and $authList.status -eq 'valid') {
        Write-Host "[OK] lark-cli 已登录" -ForegroundColor Green
    } else {
        Write-Host "[WARN] lark-cli 未登录或 token 失效" -ForegroundColor Yellow
        Write-Host "请运行以下命令登录："
        Write-Host "  lark-cli auth login"
    }
} catch {
    Write-Host "[WARN] 无法检查登录状态，请手动验证" -ForegroundColor Yellow
}

# 9. 重载 Hermes 技能
Write-Host ""
if (Get-Command hermes -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] 重载 Hermes 技能..." -ForegroundColor Cyan
    hermes skills reload 2>$null
    Write-Host "[OK] Hermes 技能已重载" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "快速测试："
Write-Host "  hermes"
Write-Host "  /feishu-file-send-lark-cli --help"
Write-Host ""
Write-Host "获取 chat_id："
Write-Host "  lark-cli im +messages-search --query `"`" --format json"
Write-Host ""
