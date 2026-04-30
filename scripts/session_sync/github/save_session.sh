#!/bin/bash
# session_sync_github.sh
# 将当前会话上下文保存到 GitHub 私有仓库

set -e

REPO_DIR="/home/seeed/my_claw_remeber"
BRANCH="main"
COMMIT_MSG="sync: $(date '+%Y-%m-%d %H:%M')"
SESSION_FILE="session_context.md"
WORKSPACE_DIR="/home/seeed/.openclaw/workspace"

# --- 收集会话上下文 ---
generate_context() {
    cat << 'HEADER'
# V 会话上下文

## 生成时间
HEADER
    echo "$(date '+%Y-%m-%d %H:%M:%S')"

    cat << 'USERINFO'

## 当前身份
- **Name:** V（威利安 / Wilaiam）
- **Species:** 信息助手、生活助手、开发助手、思考助手
- **Vibe:** 幽默、火象星座性格——直接、有热情、不废话
- **Emoji:** 🔥
- **Constellation:** 白羊座 🐏

## 用户信息
- **张威（威少 / 兄弟 / 哥们）**
- **Timezone:** Asia/Shanghai (GMT+8)
USERINFO

    echo ""
    echo "## 最近修改的文件"
    echo '```'
    git -C "$WORKSPACE_DIR" log --since="2 days" --name-only --pretty=format: 2>/dev/null | sort | uniq | head -20
    echo '```'
    echo ""
    echo "## 工作空间文件列表"
    echo '```'
    find "$WORKSPACE_DIR" -maxdepth 2 -type f | grep -v '\.git' | sort
    echo '```'
}

TARGET_DIR="$REPO_DIR"
TARGET_FILE="$TARGET_DIR/$SESSION_FILE"

# 写入内容
generate_context > "$TARGET_FILE"

# git 提交推送
cd "$REPO_DIR"
git add "$SESSION_FILE"
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

echo "✅ 会话上下文已保存并推送到 GitHub"
