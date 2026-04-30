#!/bin/bash
# read_session_feishu.sh
# 从飞书云文档读取上一个会话的内容

set -e

# --- 配置区（需要填写）---
FEISHU_APP_ID=""          # 飞书应用 App ID
FEISHU_APP_SECRET=""      # 飞书应用 App Secret
DOC_TOKEN=""              # 目标文档的 token
# -------------------------

if [ -z "$FEISHU_APP_ID" ] || [ -z "$FEISHU_APP_SECRET" ] || [ -z "$DOC_TOKEN" ]; then
    echo "❌ 请先在脚本顶部配置：FEISHU_APP_ID、FEISHU_APP_SECRET、DOC_TOKEN"
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

# 读取文档内容（获取 blocks 并提取文本）
curl -s -X GET "https://open.feishu.cn/open-apis/docx/v1/documents/$DOC_TOKEN/blocks?page_size=500" \
    -H "Authorization: Bearer $TOKEN" | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
blocks = data.get('data', {}).get('items', [])
for b in blocks:
    if b.get('block_type') == 2:
        texts = b.get('text', {}).get('elements', [])
        for t in texts:
            content = t.get('text_run', {}).get('content', '')
            if content:
                print(content, end='')
print()
"
