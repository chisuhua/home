# Docker 容器目录映射配置

**记录时间**: 2026-03-29 14:55  
**容器环境**: OpenClaw Docker 容器  
**映射配置**: `/workspace/home/` → `~/` (部分目录)

---

## 📁 目录映射关系

### 符号链接映射

```bash
~/.agents → /workspace/home/.agents/
```

### 同一目录（硬链接/挂载点）

```bash
~/.openclaw = /workspace/home/.openclaw
~/ = /home/ubuntu/
```

---

## 🗂️ 完整目录结构

### 主目录 (`~` = `/home/ubuntu/`)

```
/home/ubuntu/
├── .agents → /workspace/home/.agents/  (符号链接)
├── .openclaw (与 /workspace/home/.openclaw 同一目录)
├── .claude/
├── .config/
├── .local/
├── .npm/
└── ...
```

### 工作空间 (`/workspace/`)

```
/workspace/
├── home/                    # Docker 映射源目录
│   ├── .agents/
│   ├── .openclaw/
│   ├── .claude/
│   └── ...
├── acf-workflow/            # ACF 工作流项目
├── ecommerce/               # 电商项目
├── mynotes/                 # 架构讨论（提案仓库）
└── ...
```

---

## 🔧 重要影响

### 文件操作注意事项

1. **修改 `~/.agents/` 下的文件**
   - 实际修改的是 `/workspace/home/.agents/`
   - 符号链接，双向同步

2. **修改 `~/.openclaw/` 下的文件**
   - 实际修改的是 `/workspace/home/.openclaw/`
   - 同一目录，直接修改

3. **清理文件时**
   - 需要同时检查 `~` 和 `/workspace/home/` 路径
   - 避免重复删除或遗漏

---

## 📋 常用路径对照

| 路径（~） | 路径（/workspace/home/） | 说明 |
|----------|-------------------------|------|
| `~/.agents/` | `/workspace/home/.agents/` | OpenClaw Agents（符号链接） |
| `~/.openclaw/` | `/workspace/home/.openclaw/` | OpenClaw 工作区（同一目录） |
| `~/.claude/` | `/workspace/home/.claude/` | Claude 配置 |
| `~/.config/` | `/workspace/home/.config/` | 系统配置 |

---

## 🧪 验证命令

```bash
# 检查符号链接
ls -la ~ | grep "^l"

# 检查同一目录
ls -la ~/.openclaw/
ls -la /workspace/home/.openclaw/
# 应该显示相同内容

# 检查映射后的文件
ls -la ~/.agents/skills/
ls -la /workspace/home/.agents/skills/
# 应该显示相同内容
```

---

## 📝 相关文档

- ACF 迁移文档：`/workspace/acf-workflow/docs/acf-migration-complete.md`
- ACF 清理文档：`/workspace/acf-workflow/docs/acf-cleanup-final.md`
- 容器启动脚本：待查找（可能在 `/workspace/home/my_docker_env/` 或外部）

---

**记录人**: DevMate  
**记录时间**: 2026-03-29 14:55  
**重要性**: ⭐⭐⭐⭐⭐（关键环境配置）
