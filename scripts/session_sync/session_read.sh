#!/bin/bash
# session_read.sh
# 自动读取会话：优先飞书，备选 GitHub，两者都失败再提示

# 飞书配置不完整时直接跳过（静默）
FEISHU_SCRIPT="$(dirname "$0")/feishu/read_session.sh"

if [ -s "$FEISHU_SCRIPT" ]; then
    FEISHU_APP_ID=$(grep '^FEISHU_APP_ID=' "$FEISHU_SCRIPT" | cut -d'"' -f2)
    FEISHU_APP_SECRET=$(grep '^FEISHU_APP_SECRET=' "$FEISHU_SCRIPT" | cut -d'"' -f2)
    DOC_TOKEN=$(grep '^DOC_TOKEN=' "$FEISHU_SCRIPT" | cut -d'"' -f2)
fi

if [ -n "$FEISHU_APP_ID" ] && [ -n "$FEISHU_APP_SECRET" ] && [ -n "$DOC_TOKEN" ]; then
    FEISHU_RESULT=$(bash "$FEISHU_SCRIPT" 2>/dev/null)
    if [ -n "$FEISHU_RESULT" ]; then
        echo "$FEISHU_RESULT"
        exit 0
    fi
fi

# 飞书配置不完整或失败，尝试 GitHub
GITHUB_RESULT=$(bash "$(dirname "$0")/github/read_session.sh" 2>&1)
GITHUB_EXIT=$?

if [ $GITHUB_EXIT -eq 0 ]; then
    echo "$GITHUB_RESULT"
    exit 0
fi

echo "$GITHUB_RESULT"
exit $GITHUB_EXIT
