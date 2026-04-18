#!/bin/bash
# 飞书技能包部署脚本 - macOS / Linux / WSL
# 用法: ./deploy-feishu-skills.sh [zip文件路径]
# 如不提供参数，脚本会尝试在当前目录查找 .zip 文件

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "============================================"
echo "  飞书 Lark CLI 技能包部署脚本"
echo "  支持: macOS / Linux / WSL"
echo "============================================"

# 1. 确定 ZIP 文件
ZIP_FILE="${1:-}"
if [ -z "$ZIP_FILE" ]; then
    # 尝试自动查找
    CANDIDATES=(feishu-lark-cli-skills.zip feishu-lark-cli-skills-*.zip)
    for cand in "${CANDIDATES[@]}"; do
        if [ -f "$cand" ]; then
            ZIP_FILE="$cand"
            break
        fi
    done
fi

if [ -z "$ZIP_FILE" ] || [ ! -f "$ZIP_FILE" ]; then
    log_error "未找到技能包 ZIP 文件"
    echo ""
    echo "用法: $0 [path/to/feishu-lark-cli-skills.zip]"
    echo ""
    echo "或者将 .zip 文件放在当前目录后重新运行"
    exit 1
fi

log_info "找到技能包: $ZIP_FILE"

# 2. 检查 Hermes
if [ ! -d "$HOME/.hermes" ]; then
    log_error "未找到 Hermes 目录: $HOME/.hermes"
    echo "请先安装 Hermes Agent: https://github.com/ai-playground-zzw/hermes-agent"
    exit 1
fi
log_info "✓ 找到 Hermes 目录"

# 3. 检查 Node.js
if ! command -v node &> /dev/null; then
    log_error "未找到 Node.js，请先安装 Node.js 18+"
    echo "下载: https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    log_warn "Node.js 版本较低 (v$(node -v))，建议升级到 v18+"
fi
log_info "✓ Node.js $(node -v)"

# 4. 检查/安装 lark-cli
if command -v lark-cli &> /dev/null; then
    log_info "✓ 已安装 lark-cli ($(lark-cli --version 2>/dev/null || echo 'unknown'))"
else
    log_warn "未找到 lark-cli，尝试安装..."
    if command -v npm &> /dev/null; then
        npm install -g @larksuite/cli
        log_info "✓ lark-cli 安装完成"
    else
        log_error "未找到 npm，请先安装 Node.js 或手动安装 lark-cli"
        echo "参考: https://github.com/larksuite/lark-cli"
        exit 1
    fi
fi

# 5. 创建技能目录
TARGET_DIR="$HOME/.hermes/skills/messaging"
mkdir -p "$TARGET_DIR"
log_info "✓ 技能目录: $TARGET_DIR"

# 6. 解压技能包
echo ""
log_info "解压技能包..."
if ! unzip -o "$ZIP_FILE" -d "$TARGET_DIR" > /dev/null 2>&1; then
    log_error "解压失败，请检查 ZIP 文件是否损坏"
    exit 1
fi
log_info "✓ 解压完成"

# 7. 设置权限（仅在非 Windows 环境下）
if [ "$(uname -s)" != "Darwin" ] && [ "$(expr substr $(uname -s) 1 5)" != "MINGW" ] && [ "$(expr substr $(uname -s) 1 4)" != "MSYS" ]; then
    chmod -R 755 "$TARGET_DIR"
    log_info "✓ 权限设置完成"
fi

# 8. 验证安装
echo ""
log_info "验证安装..."
if [ -d "$TARGET_DIR/feishu-file-send-lark-cli" ]; then
    log_info "✓ feishu-file-send-lark-cli"
fi
if [ -d "$TARGET_DIR/feishu-message-send-lark-cli" ]; then
    log_info "✓ feishu-message-send-lark-cli"
fi
if [ -d "$TARGET_DIR/feishu-doc-create-lark-cli" ]; then
    log_info "✓ feishu-doc-create-lark-cli"
fi

# 9. 检查 lark-cli 登录状态
echo ""
if lark-cli auth list --format json 2>/dev/null | grep -q '"status":"valid"'; then
    log_info "✓ lark-cli 已登录"
else
    log_warn "lark-cli 未登录或 token 失效"
    echo "请运行以下命令登录："
    echo "  lark-cli auth login"
fi

# 10. 重载 Hermes 技能
echo ""
if command -v hermes &> /dev/null; then
    log_info "重载 Hermes 技能..."
    hermes skills reload 2>/dev/null || hermes restart 2>/dev/null || true
    log_info "✓ Hermes 技能已重载"
fi

echo ""
echo "============================================"
echo "✅ 部署完成！"
echo "============================================"
echo ""
echo "快速测试："
echo "  hermes"
echo "  /feishu-file-send-lark-cli --help"
echo ""
echo "获取 chat_id："
echo "  lark-cli im +messages-search --query "" --format json"
echo ""
