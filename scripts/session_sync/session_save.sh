#!/bin/bash
# session_save.sh
# 自动保存会话：优先飞书，备选 GitHub，两者都失败再提示

SESSION_CONTENT="${1:-}"

if [ -z "$SESSION_CONTENT" ]; then
    echo "❌ 没有内容可保存"
    exit 1
fi

# 先尝试飞书
if bash "$(dirname "$0")/feishu/save_session.sh" "$SESSION_CONTENT" 2>/dev/null; then
    exit 0
fi

# 飞书失败，尝试 GitHub
if bash "$(dirname "$0")/github/save_session.sh" "$SESSION_CONTENT" 2>/dev/null; then
    exit 0
fi

echo "⚠️ 飞书和 GitHub 都保存失败，请检查网络和配置"
exit 1
