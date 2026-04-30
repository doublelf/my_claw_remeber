# my_claw_remeber

> V（威利安 / Wilaiam）的配置、脚本与记忆存储库

---

## 这是什么

这是 V 的工作空间备份仓库，用于：

- **多设备同步** — 在任意设备上快速恢复完全一致的配置
- **会话连续性** — 跨设备切换时自动合并上下文
- **配置备份** — 所有身份、规则、脚本集中管理

---

## 工作原理

```
设备A (当前)  →  保存会话  →  飞书(优先) / GitHub(备选)
设备B (新设备) →  读取会话  →  自动合并  →  完全同步
```

每次启动 OpenClaw 会自动拉取并合并最新配置。

---

## 目录结构

```
my_claw_remeber/
├── README.md               # 本文件
├── IDENTITY.md             # V 的身份定义
├── USER.md                 # 用户信息
├── SOUL.md                 # 行为准则
├── AGENTS.md               # 工作空间规范
├── HEARTBEAT.md            # 定时任务配置
├── TOOLS.md                # 本地工具笔记
├── session_context.md      # 当前会话摘要
└── scripts/
    ├── openclaw_setup.sh   # 新设备一键安装脚本
    └── session_sync/       # 会话同步工具
        ├── session_save.sh      # 保存会话（飞书优先 → GitHub备选）
        ├── session_read.sh      # 读取会话（自动合并，有冲突询问）
        ├── feishu/              # 飞书同步脚本
        └── github/              # GitHub同步脚本
```

---

## 新设备安装

```bash
git clone git@github.com:doublelf/my_claw_remeber.git /tmp/oc_setup
cd /tmp/oc_setup
bash scripts/openclaw_setup.sh
```

详细步骤请查看：`scripts/openclaw_setup.sh`

---

## 当前配置

- **V（威利安 / Wilaiam）** — 白羊座 🐏，火象星座风格
- **用户** — 张威（威少 / 兄弟 / 哥们）
- **时区** — Asia/Shanghai (GMT+8)
- **会话同步** — 飞书优先，GitHub备选
- **开机自启** — 已配置，自动拉取合并

---

## 连接状态

| 平台 | 状态 | 配置 |
|------|------|------|
| GitHub | ✅ | git@github.com:doublelf/my_claw_remeber.git |
| 飞书 | ✅ | 文档：V 会话同步文档 |
| 开机自启 | ✅ | systemd user service |

---

## 隐私规则

- 访问文件/文件夹需申请权限，说明用途
- 单次授权 or 永久授权，由用户选择
- 未经授权区域不访问
- 所有操作有日志记录
