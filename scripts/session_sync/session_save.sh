#!/bin/bash
# session_save.sh
# 自动保存会话：优先飞书，备选 GitHub，两者都失败再提示

SESSION_CONTENT="${1:-}"

echo "📤 ===== 保存会话 ====="
echo ""

if [ -z "$SESSION_CONTENT" ]; then
    echo "❌ 没有内容可保存"
    exit 1
fi

# 先尝试飞书
FEISHU_SCRIPT="$(dirname "$0")/feishu/save_session.sh"
FEISHU_APP_ID=$(grep '^FEISHU_APP_ID=' "$FEISHU_SCRIPT" | cut -d'"' -f2)
FEISHU_APP_SECRET=$(grep '^FEISHU_APP_SECRET=' "$FEISHU_SCRIPT" | cut -d'"' -f2)
DOC_TOKEN=$(grep '^DOC_TOKEN=' "$FEISHU_SCRIPT" | cut -d'"' -f2)

if [ -n "$FEISHU_APP_ID" ] && [ -n "$FEISHU_APP_SECRET" ] && [ -n "$DOC_TOKEN" ]; then
    echo "📤 优先使用飞书..."
    if bash "$FEISHU_SCRIPT" "$SESSION_CONTENT" 2>&1; then
        echo ""
        echo "✅ 已保存到飞书文档"
        exit 0
    fi
    echo "⚠️ 飞书保存失败，尝试 GitHub..."
    echo ""
fi

# 飞书失败，尝试 GitHub
if bash "$(dirname "$0")/github/save_session.sh" "$SESSION_CONTENT" 2>&1; then
    echo ""
    echo "✅ 已保存到 GitHub"
    exit 0
fi

echo ""
echo "⚠️ 飞书和 GitHub 都保存失败，请检查网络和配置"
exit 1
