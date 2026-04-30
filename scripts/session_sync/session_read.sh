#!/bin/bash
# session_read.sh
# 自动读取会话：优先飞书，备选 GitHub，两者都失败再提示

# 先尝试飞书（飞书 API 读取文档内容）
FEISHU_RESULT=$(bash "$(dirname "$0")/feishu/read_session.sh" 2>/dev/null)

if [ -n "$FEISHU_RESULT" ]; then
    echo "$FEISHU_RESULT"
    exit 0
fi

# 飞书失败，尝试 GitHub
GITHUB_RESULT=$(bash "$(dirname "$0")/github/read_session.sh" 2>/dev/null)

if [ -n "$GITHUB_RESULT" ]; then
    echo "$GITHUB_RESULT"
    exit 0
fi

echo "⚠️ 飞书和 GitHub 都读取失败，请检查网络和配置"
exit 1
