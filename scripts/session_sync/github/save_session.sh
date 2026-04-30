#!/bin/bash
# session_sync_github.sh
# 将当前会话上下文保存到 GitHub 私有仓库

set -e

# --- 配置区（需要填写）---
REPO_DIR="/home/seeed/my_claw_remeber"           # 本地 git 仓库路径，例如 ~/sync-repo
BRANCH="main"
COMMIT_MSG="sync: $(date '+%Y-%m-%d %H:%M')"

# --- 会话文件 ---
SESSION_FILE="session_context.md"
# -------------------------

if [ -z "$REPO_DIR" ]; then
    echo "❌ 请先在脚本顶部配置 REPO_DIR（本地 git 仓库路径）"
    exit 1
fi

TARGET_DIR="$REPO_DIR"
TARGET_FILE="$TARGET_DIR/$SESSION_FILE"

# 写入内容（接收 stdin 或参数）
if [ -t 0 ]; then
    # 无管道输入，读取第一个参数
    CONTENT="${1:-}"
else
    CONTENT=$(cat)
fi

if [ -z "$CONTENT" ]; then
    echo "❌ 没有内容可保存"
    exit 1
fi

# 写入文件
mkdir -p "$TARGET_DIR"
echo "$CONTENT" > "$TARGET_FILE"

# git 提交推送
cd "$REPO_DIR"
git add "$SESSION_FILE"
git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"

echo "✅ 会话已保存并推送到 GitHub"
