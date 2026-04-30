#!/bin/bash
# read_session_feishu.sh
# 从飞书云文档读取上一个会话的内容

set -e

FEISHU_APP_ID="cli_a979ad05e13b9cb2"
FEISHU_APP_SECRET="BQTqnzkt6kUXS9ZAcRkBVIVxUGdfPDkO"
DOC_TOKEN="Jr9TdFT91oVbt2xrS2fctC3znBc"

if [ -z "$FEISHU_APP_ID" ] || [ -z "$FEISHU_APP_SECRET" ] || [ -z "$DOC_TOKEN" ]; then
    echo "❌ 请先在脚本顶部配置：FEISHU_APP_ID、FEISHU_APP_SECRET、DOC_TOKEN"
    exit 1
fi

echo "📥 ===== 读取飞书会话 ====="
echo ""

# 获取 tenant access token
echo "📡 正在连接飞书..."
TOKEN_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
    -H "Content-Type: application/json" \
    -d "{\"app_id\": \"$FEISHU_APP_ID\", \"app_secret\": \"$FEISHU_APP_SECRET\"}")

TOKEN=$(echo "$TOKEN_RESP" | grep -o '"tenant_access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ 获取飞书 access token 失败"
    exit 1
fi

echo "✅ 已连接飞书文档"
echo ""

# 读取文档内容（获取 blocks 并提取文本）
RESP=$(curl -s -X GET "https://open.feishu.cn/open-apis/docx/v1/documents/$DOC_TOKEN/blocks?page_size=500" \
    -H "Authorization: Bearer $TOKEN")

CODE=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('code',''))")

if [ "$CODE" -ne 0 ]; then
    echo "❌ 读取文档失败: $(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('msg',''))")"
    exit 1
fi

echo "📖 文档内容："
echo ""
echo "$RESP" | python3 -c "
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
