# session_sync - 会话同步工具

将对话上下文保存到云端，实现多设备无缝切换。

## 优先级

1. **飞书**（优先）
2. **GitHub**（备选）
3. 两者都失败 → 提示用户

## 目录结构

```
session_sync/
├── session_save.sh       # 保存会话（自动选择可用平台）
├── session_read.sh       # 读取会话（自动选择可用平台）
├── feishu/
│   ├── save_session.sh   # 飞书保存脚本
│   └── read_session.sh   # 飞书读取脚本（待完善）
└── github/
    ├── save_session.sh   # GitHub 保存脚本
    └── read_session.sh   # GitHub 读取脚本
```

## 配置步骤

### GitHub
1. 在 GitHub 创建私有仓库
2. 克隆到本地，例如 `~/sync-repo`
3. 编辑 `github/save_session.sh`，填入 `REPO_DIR`
4. 编辑 `github/read_session.sh`，填入 `REPO_DIR`

### 飞书
1. 在飞书开放平台创建应用，获取 App ID 和 App Secret
2. 创建或找到目标云文档，复制文档 token（URL 中 `/d/` 后面的部分）
3. 编辑 `feishu/save_session.sh`，填入配置

## 使用方式

**保存会话：**
```bash
bash session_save.sh "要保存的内容"
```

**读取会话：**
```bash
bash session_read.sh
```

**在 OpenClaw 中触发：**
- 威少说"保存会话" → 我执行 save
- 威少说"读取上一个会话" → 我执行 read

## 注意

- 脚本不会自动执行，需要威少明确触发
- 所有操作有日志，可追溯
- 读取前会先说明读取了哪些内容，征得同意后再加载
