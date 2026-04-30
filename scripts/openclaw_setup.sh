#!/bin/bash
# openclaw_setup.sh
# 新电脑一键安装 OpenClaw + 同步配置
# 需要有 SSH 访问 GitHub 的能力

set -e

WORKSPACE_DIR="$HOME/.openclaw/workspace"
REPO_URL="git@github.com:doublelf/my_claw_remeber.git"

echo "============================================"
echo "  V (OpenClaw) 一键安装脚本"
echo "============================================"
echo ""

# --- 检测是否已安装 ---
if command -v openclaw &> /dev/null; then
    echo "✅ OpenClaw 已安装: $(openclaw --version 2>&1 | head -1)"
else
    echo "📦 安装 OpenClaw..."
    npm install -g openclaw
    echo "✅ OpenClaw 安装完成"
fi
echo ""

# --- 生成 SSH 密钥 ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ -f "$SSH_KEY" ]; then
    echo "🔑 SSH 密钥已存在，跳过生成"
else
    echo "🔑 生成 SSH 密钥..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "v@openclaw" -f "$SSH_KEY" -N ""
    echo "✅ SSH 密钥生成完成"
fi
echo ""

# --- 打印公钥 ---
echo "============================================"
echo "  ⚠️  请将下面的公钥添加到 GitHub"
echo "============================================"
echo ""
cat "$SSH_KEY.pub"
echo ""
read -p "按回车继续（已在 GitHub 添加公钥）..."
echo ""

# --- 克隆仓库 ---
if [ -d "$WORKSPACE_DIR/.git" ]; then
    echo "📁 工作空间已存在，拉取最新..."
    cd "$WORKSPACE_DIR"
    git pull origin main
else
    echo "📡 克隆 GitHub 仓库..."
    mkdir -p "$(dirname "$WORKSPACE_DIR")"
    git clone "$REPO_URL" "$WORKSPACE_DIR"
fi
echo "✅ 仓库同步完成"
echo ""

# --- 配置脚本路径 ---
echo "⚙️  配置本地路径..."
REPO_DIR="$WORKSPACE_DIR"

for script in "$WORKSPACE_DIR/scripts/session_sync/github/save_session.sh" \
             "$WORKSPACE_DIR/scripts/session_sync/github/read_session.sh"; do
    if [ -f "$script" ]; then
        sed -i "s|REPO_DIR=\"/home/seeed/my_claw_remeber\"|REPO_DIR=\"$REPO_DIR\"|g" "$script"
        echo "  ✅ 已配置: $(basename $script)"
    fi
done
echo ""

# --- 设置开机自启 ---
echo "🚀 设置开机自启..."
mkdir -p "$HOME/.config/systemd/user/openclaw-gateway.service.d"

cat > "$HOME/.config/systemd/user/openclaw-gateway.service.d/session-sync.conf" << 'EOF'
[Service]
ExecStartPre=/home/seeed/.openclaw/workspace/scripts/session_sync/session_read.sh
EOF

# 尝试 systemd --user
if command -v systemctl &> /dev/null; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now openclaw-gateway 2>/dev/null || true
    echo "  ✅ systemd 服务已配置并启用"
else
    echo "  ⚠️ systemctl 不可用，请在启动后手动运行: openclaw gateway"
fi
echo ""

# --- 验证 GitHub 连接 ---
echo "🔍 验证 GitHub 连接..."
if ssh -T git@github.com 2>&1 | grep -q "successfully"; then
    echo "  ✅ GitHub SSH 连接成功"
else
    echo "  ⚠️ GitHub 连接验证失败，请检查公钥是否正确添加"
fi
echo ""

# --- 完成 ---
echo "============================================"
echo "  ✅ 安装完成！"
echo "============================================"
echo ""
echo "启动命令: openclaw gateway"
echo "或等待下次开机自启"
echo ""
echo "新设备标识可写入 workspace-state.json"
