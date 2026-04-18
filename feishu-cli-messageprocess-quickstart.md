# 飞书 CLI 消息处理技能包 - 快速部署指南

## 📥 解压技能包

```bash
# macOS/Linux/WSL
unzip feishu-cli-messageprocess-skills-package.zip
cd feishu-cli-messageprocess-skills-package

# Windows (PowerShell)
Expand-Archive feishu-cli-messageprocess-skills-package.zip
cd feishu-cli-messageprocess-skills-package
```

---

## 🚀 一键安装（自动检测平台）

### macOS / Linux / WSL

```bash
./scripts/install.sh
```

### Windows

```powershell
# PowerShell（推荐）
powershell -ExecutionPolicy Bypass -File scripts\install.ps1

# 或 CMD
scripts\install.bat
```

---

## 🎯 手动安装（指定平台）

```bash
# Hermes Agent
./scripts/install.sh hermes

# OpenClaw
./scripts/install.sh openclaw

# OpenAI Codex
./scripts/install.sh codex

# Claude Code
./scripts/install.sh claude

# AMP
./scripts/install.sh amp

# OpenCode
./scripts/install.sh opencode
```

---

## ✅ 验证安装

```bash
# 检查技能是否加载
hermes skills list | grep feishu

# 测试文件发送技能
hermes
/feishu-file-send-lark-cli --help

# 检查 lark-cli 登录状态
lark-cli auth list --format json
```

---

## 🔧 故障排除

### 技能未显示

```bash
hermes skills reload
# 或
hermes restart
```

### lark-cli 未安装

```bash
# 使用 npm 全局安装
npm install -g @larksuite/cli

# 或使用 npx（无需安装）
# 技能包会自动检测并使用 npx
```

### Windows 执行策略错误

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 完整文档

详见 `README.md`（项目根目录）

---

## 🆘 获取帮助

- 技能使用问题：`/feishu-file-send-lark-cli --help`
- lark-cli 文档：https://github.com/larksuite/lark-cli
- Hermes 文档：https://github.com/ai-playground-zzw/hermes-agent

---

**版本**: 1.0.0  
**更新**: 2026-04-18  
**支持平台**: Hermes / OpenClaw / Codex / Claude Code / AMP / OpenCode
