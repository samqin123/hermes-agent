# 飞书 (Lark) CLI 工具技能包

一套基于 `lark-cli` 命令行工具的飞书操作技能，支持文件发送、消息发送、文档创建与更新。

---

## 📦 包含的技能

```
messaging/
├── feishu-file-send-lark-cli/      # 发送本地文件到飞书会话
├── feishu-message-send-lark-cli/   # 发送文本/富文本消息
└── feishu-doc-create-lark-cli/     # 创建/更新飞书云文档
```

---

## 🚀 快速开始

### 前置条件

1. **安装 lark-cli**（如未安装）：
   ```bash
   npm install -g @larksuite/cli
   # 或使用 npx（推荐，避免全局安装）
   ```

2. **完成登录授权**：
   ```bash
   lark-cli auth login
   # 按提示扫码登录
   ```

3. **确认 lark-cli 路径**：
   ```bash
   which lark-cli
   # 通常为 /usr/local/bin/lark-cli 或 ~/.npm/_npx/...
   ```

---

## 🎯 使用方式

### 方式一：在 Hermes CLI 中直接调用（推荐）

Hermes 已内置这些技能，只需使用 `/` 命令：

```bash
# 发送文件
/feishu-file-send-lark-cli --file "/path/to/report.md" --chat-id oc_xxx

# 发送消息
/feishu-message-send-lark-cli --text "你好" --chat-id oc_xxx
# 或
/feishu-message-send-lark-cli --markdown "**加粗**内容" --chat-id oc_xxx

# 创建文档（从 Markdown）
/feishu-doc-create-lark-cli --create --title "报告" --folder folder_token --markdown @report.md

# 更新文档内容
/feishu-doc-create-lark-cli --update --doc-id ILAudNLOuoQdKlxpK1mcZDIqnXc --markdown @report.md
```

---

### 方式二：手动调用 lark-cli 命令

#### 发送文件

```bash
# 1. 找到目标 chat_id（DM 或群聊）
lark-cli im +messages-search --query "" --format json | python -m json.tool
# 取第一条消息的 chat_id

# 2. 复制文件到 lark-cli 工作目录
cp /path/to/report.md $(dirname $(which lark-cli))/  # 或 lark-cli 所在目录

# 3. 发送文件（必须以 user 身份）
lark-cli im +messages-send \
  --as user \
  --chat-id oc_e92ded0f5dbeecd5601c811bd2247ddf \
  --file report.md \
  --format json
```

**关键参数说明：**
- `--as user`：以用户身份发送（默认是 bot，可能导致权限错误）
- `--file`：文件名（需在 lark-cli 同一目录，不支持绝对路径）
- `--chat-id`：会话 ID（群聊或私信）
- **注意**：`--text/--markdown/--content` 与 `--file` 互斥，不能同时使用

---

#### 发送消息

```bash
# 纯文本消息
lark-cli im +messages-send \
  --as user \
  --chat-id oc_xxx \
  --content '{"text":"消息内容"}' \
  --format json

# Markdown 富文本
lark-cli im +messages-send \
  --as user \
  --chat-id oc_xxx \
  --markdown "**加粗** *斜体* [链接](url)" \
  --format json
```

---

#### 创建/更新文档

```bash
# 创建新文档（Markdown 导入）
# 先获取父文件夹 token
lark-cli drive files list --format json | python -m json.tool
# 找到目标文件夹的 token（如 "病情": GQC6f9gcylTLPOdcj6FcahpQn7d）

lark-cli docs +create \
  --title "调研报告" \
  --folder GQC6f9gcylTLPOdcj6FcahpQn7d \
  --markdown @report.md \
  --format json

# 返回的 doc_token 即 doc_id（如 ILAudNLOuoQdKlxpK1mcZDIqnXc）

# 更新现有文档（全量替换）
lark-cli docs +blocks-replace \
  --doc ILAudNLOuoQdKlxpK1mcZDIqnXc \
  --markdown @report.md \
  --format json
```

---

## 🔍 常见问题

### Q: 提示 "unauthorized" 或 "token expired"
A: 重新登录：
```bash
lark-cli auth logout
lark-cli auth login
```

### Q: `--file` 参数报错 "file not found"
A: 文件必须在 lark-cli 当前工作目录。先 `cp` 过去，或用绝对路径的变通方法：
```bash
cd $(dirname $(which lark-cli))
cp /abs/path/file.md .
lark-cli im +messages-send --as user --chat-id oc_xxx --file file.md
```

### Q: DM 找不到 chat_id（`/im chats list` 只显示群聊）
A: 私信 chat_id 需要通过消息搜索获取：
```bash
lark-cli im +messages-search --query "" --format json
# 从 messages[0].chat_id 提取（最近的会话）
```

### Q: `--as user` 和 `--as bot` 的区别
A:
- `user`：以你的个人身份发送（显示"我"）
- `bot`：以机器人身份发送（显示机器人名称，需要机器人有权限）
**发送文件必须用 `--as user`**，bot 无文件上传权限。

### Q: 文档创建成功但内容为空
A: 创建时 `--markdown @file.md` 必须指定本地文件。如果文件内容为空或路径错误，文档会是空的。先用 `cat file.md` 确认文件有内容。

---

## 📚 相关资源

- [飞书 Open API 文档](https://open.feishu.cn/document/)
- [lark-cli GitHub](https://github.com/larksuite/lark-cli)
- Hermes 技能系统：`~/.hermes/skills/`

---

## 📝 版本历史

- v1.0.0 (2026-04-18)：初始版本，包含文件发送、消息发送、文档创建三个技能
