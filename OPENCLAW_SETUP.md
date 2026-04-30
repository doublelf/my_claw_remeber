# OpenClaw 新设备安装指南

在新电脑上安装 OpenClaw 并同步配置，只需运行一个脚本。

---

## 快速开始

### 方法一：一键脚本（推荐）

```bash
# 克隆仓库（获取安装脚本）
git clone git@github.com:doublelf/my_claw_remeber.git /tmp/openclaw_setup
cd /tmp/openclaw_setup

# 运行安装脚本
bash scripts/openclaw_setup.sh
```

脚本会自动完成以下步骤：

1. 检测并安装 OpenClaw（如未安装）
2. 生成 SSH 密钥，打印公钥
3. 克隆 GitHub 仓库到 `~/.openclaw/workspace`
4. 自动配置脚本路径
5. 设置开机自启 + 自动读取合并

---

### 方法二：手动安装

如果网络不允许克隆，可手动创建文件。

#### 第一步：安装 OpenClaw

```bash
npm install -g openclaw
```

#### 第二步：生成 SSH 密钥

```bash
ssh-keygen -t ed25519 -C "v@openclaw"
```

将公钥添加到 GitHub：
```bash
cat ~/.ssh/id_ed25519.pub
```
复制输出，到 GitHub → Settings → SSH and GPG keys → New SSH key

#### 第三步：克隆仓库

```bash
git clone git@github.com:doublelf/my_claw_remeber.git ~/.openclaw/workspace
```

#### 第四步：配置脚本路径

编辑以下脚本，将 `REPO_DIR` 改为本地路径：

```bash
nano ~/.openclaw/workspace/scripts/session_sync/github/save_session.sh
nano ~/.openclaw/workspace/scripts/session_sync/github/read_session.sh
```

将 `REPO_DIR="/home/seeed/my_claw_remeber"` 替换为 `REPO_DIR="$HOME/.openclaw/workspace"`

#### 第五步：设置开机自启

```bash
mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d

cat > ~/.config/systemd/user/openclaw-gateway.service.d/session-sync.conf << 'EOF'
[Service]
ExecStartPre=/home/seeed/.openclaw/workspace/scripts/session_sync/session_read.sh
EOF

systemctl --user daemon-reload
systemctl --user enable --now openclaw-gateway
```

---

## 验证安装

```bash
openclaw --version
systemctl --user status openclaw-gateway
```

---

## 安装完成后的效果

- 每次开机自动拉取 GitHub 最新配置并合并
- 会话同步：飞书优先，GitHub 备选
- 所有配置、脚本、身份文件与主设备完全一致

---

## 相关文件

- 安装脚本：`scripts/openclaw_setup.sh`
- 会话同步：`scripts/session_sync/`
- 工作空间：`~/.openclaw/workspace/`

---

## 故障排查

**GitHub 连接失败**
```bash
ssh -T git@github.com
```
确认输出包含 "successfully authenticated"

**OpenClaw 无法启动**
```bash
journalctl --user -u openclaw-gateway -n 50
```

**飞书读取失败**
确认应用已开通云文档权限，且 DOC_TOKEN 对应的文档存在
