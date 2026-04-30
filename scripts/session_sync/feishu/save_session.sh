#!/bin/bash
# session_sync_feishu.sh
# 将当前会话上下文保存到飞书云文档

set -e

# --- 配置区（需要填写）---
FEISHU_APP_ID=""          # 飞书应用 App ID
FEISHU_APP_SECRET=""      # 飞书应用 App Secret
DOC_TOKEN=""              # 目标文档的 token（打开文档后 URL 中可找到）
# -------------------------

# --- 会话文件 ---
SESSION_CONTENT="${1:-}"  # 支持传入内容
# -------------------------

if [ -z "$FEISHU_APP_ID" ] || [ -z "$FEISHU_APP_SECRET" ] || [ -z "$DOC_TOKEN" ]; then
    echo "❌ 请先在脚本顶部配置：FEISHU_APP_ID、FEISHU_APP_SECRET、DOC_TOKEN"
    exit 1
fi

if [ -z "$SESSION_CONTENT" ]; then
    echo "❌ 没有内容可保存"
    exit 1
fi

# 获取 tenant access token
TOKEN_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d "{\"app_id\": \"$FEISHU_APP_ID\", \"app_secret\": \"$FEISHU_APP_SECRET\"}")

TOKEN=$(echo "$TOKEN_RESP" | grep -o '"tenant_access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ 获取飞书 access token 失败: $TOKEN_RESP"
    exit 1
fi

# 写入文档（追加模式，实际使用时可先清空再写入）
# 这里用 blocks API 追加内容块
curl -s -X POST "https://open.feishu.cn/open-apis/docx/v1/documents/$DOC_TOKEN/blocks/$DOC_TOKEN/children" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"children\": [{
            \"block_type\": 2,
            \"text\": {
                \"elements\": [{\"text_run\": {\"content\": \"$SESSION_CONTENT\"}}],
                \"style\": {}
            }
        }],
        \"index\": -1
    }"

echo "✅ 会话已保存到飞书文档"
