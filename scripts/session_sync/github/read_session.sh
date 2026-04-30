#!/bin/bash
# read_session_github.sh
# 从 GitHub 私有仓库读取上一个会话并自动合并

set -e

REPO_DIR="/home/seeed/my_claw_remeber"
SESSION_FILE="session_context.md"
BRANCH="main"
WORKSPACE_DIR="/home/seeed/.openclaw/workspace"

cd "$REPO_DIR"

# 1. 拉取远程最新
echo "📡 拉取远程更新..."
git fetch origin "$BRANCH"

# 2. 检查本地是否有未提交的修改
LOCAL_CHANGES=$(git status --porcelain)
if [ -n "$LOCAL_CHANGES" ]; then
    echo "⚠️ 本地有未提交的修改，先暂存..."
    git stash push -m "local changes before session sync"
fi

# 3. 检查本地是否有比远程更新的版本
LOCAL_COMMITS=$(git rev-list HEAD..origin/$BRANCH --count 2>/dev/null || echo "0")
if [ "$LOCAL_COMMITS" -eq 0 ]; then
    echo "📦 远程没有新提交，直接用本地版本"
    exit 0
fi

# 4. 尝试合并（自动合并，无冲突则自动完成）
echo "🔀 尝试自动合并..."
if git merge origin/$BRANCH --no-edit 2>&1; then
    echo "✅ 合并成功！以下文件已更新："
    git diff --name-only HEAD~1 HEAD
    echo ""
    echo "📋 变更详情："
    git diff --stat HEAD~1 HEAD
else
    # 有冲突
    echo "⚠️ 检测到冲突文件："
    git diff --name-only --diff-filter=U
    echo ""
    echo "请手动解决冲突后告诉我，我会继续。"
    git merge --abort
fi
