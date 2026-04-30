#!/bin/bash
# read_session_github.sh
# 从 GitHub 私有仓库读取上一个会话的内容

set -e

# --- 配置区（需要填写）---
REPO_DIR="/home/seeed/my_claw_remeber"           # 本地 git 仓库路径，例如 ~/sync-repo
BRANCH="main"
# -------------------------

SESSION_FILE="session_context.md"

if [ -z "$REPO_DIR" ]; then
    echo "❌ 请先在脚本顶部配置 REPO_DIR（本地 git 仓库路径）"
    exit 1
fi

TARGET_FILE="$REPO_DIR/$SESSION_FILE"

if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ 未找到会话文件: $TARGET_FILE"
    exit 1
fi

cat "$TARGET_FILE"
