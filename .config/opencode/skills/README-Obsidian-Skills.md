# Obsidian 技能安装指南

## 已安装的技能

### 1. obsidian-markdown 💎
**来源：** kepano/obsidian-skills（Obsidian CEO 创建的官方技能）

**功能：**
- 创建和编辑 Obsidian Flavored Markdown (OFM)
- 支持双向链接（wikilinks）：`[[Note Name]]`
- 嵌入内容：`![[image.png]]`
- 调用块（Callouts）：`> [!note]`
- 属性（Properties/Frontmatter）
- 标签系统：`#tag`、`#nested/tag`
- LaTeX 数学公式
- Mermaid 图表
- 脚注

**使用场景：**
- 在 Obsidian 中创建笔记
- 编写带有双向链接的文档
- 创建包含图表、公式的技术文档
- 管理知识库

---

### 2. planning-with-files 📋
**来源：** openclaw/skills（基于 Manus AI 的 $2B 收购模式）

**功能：**
- Manus 风格的基于文件的规划工作流
- 创建三个核心规划文件：
  - `task_plan.md` - 阶段跟踪和决策记录
  - `findings.md` - 研究发现和知识积累
  - `progress.md` - 会话日志和进度追踪
- 自动会话恢复（session catchup）
- 错误跟踪和 3-strike 协议
- 2-action 规则（每 2 次操作后保存发现）

**核心文件结构：**
```
project/
├── task_plan.md      # 任务计划和进度
├── findings.md       # 研究发现
├── progress.md       # 会话日志
└── ... your code
```

**使用场景：**
- 多步骤复杂任务（3+ 阶段）
- 研究项目
- 功能开发
- Bug 调查
- 任何需要 >5 次工具调用的任务

---

## 快速开始

### 使用 obsidian-markdown 技能

当你需要创建或编辑 Obsidian 笔记时，该技能会自动激活。

**示例工作流：**

```markdown
1. 添加 frontmatter：
   ---
   title: 我的笔记
   date: 2026-03-17
   tags:
     - project
     - active
   ---

2. 创建双向链接：[[相关笔记]]

3. 嵌入内容：![[图表.png|600]]

4. 添加 callout：
   > [!important] 关键信息
   > 这是重要内容
```

---

### 使用 planning-with-files 技能

#### 步骤 1：初始化规划文件

在任何复杂任务开始前，创建规划文件：

```bash
# 在你的项目根目录
# 技能会自动提示创建，也可以手动创建
```

或者使用提供的脚本：
```bash
~/.config/opencode/skills/planning-with-files/scripts/init-session.sh .
```

#### 步骤 2：填写任务计划

编辑 `task_plan.md`：

```markdown
# Task Plan

## Goal Statement
完成用户认证模块的开发

## Phases

### Phase 1: 设计认证流程
- [x] Status: `complete`
- Tasks:
  - [x] 研究 JWT 最佳实践
  - [x] 设计 API 端点
- Success criteria: 完成设计文档

### Phase 2: 实现登录功能
- [ ] Status: `in_progress`
- Tasks:
  - [ ] 创建登录 API 端点
  - [ ] 实现密码验证
  - [ ] 生成 JWT token
- Success criteria: 登录功能可工作
```

#### 步骤 3：记录发现

在 `findings.md` 中记录研究结果：

```markdown
# Findings

## Research: JWT 最佳实践

**Sources:**
- https://auth0.com/blog/jwt-security-best-practices/

**Key Points:**
- Token 过期时间应该短（15-30 分钟）
- 使用 refresh token 轮换
- 永远不要在前端存储敏感信息

**Implications:**
- 需要实现 refresh token 端点
- 考虑使用 httpOnly cookies
```

#### 步骤 4：更新进度

在 `progress.md` 中记录会话日志：

```markdown
# Progress Log

## Session Information
- **Date:** 2026-03-17
- **Start Time:** 10:00
- **End Time:** 12:00

## Session Log

### 10:00-10:30
**Action:** 研究 JWT 库
**Result:** 选择了 jsonwebtoken (npm)
**Next Steps:** 实现登录端点

### 10:30-11:00
**Action:** 创建登录路由
**Result:** 基本框架完成
**Next Steps:** 添加密码验证
```

---

## 核心原则

### planning-with-files 的工作原则

1. **Create Plan First**
   - 在开始任何复杂任务之前，先创建 `task_plan.md`
   - 这是不可协商的规则

2. **2-Action Rule**
   - 每进行 2 次查看/搜索操作后，立即保存关键发现到文件
   - 防止视觉/多模态信息丢失

3. **Read Before Decide**
   - 在做重大决策前，重新阅读计划文件
   - 保持目标在注意力窗口中

4. **Update After Act**
   - 完成每个阶段后：标记完成、记录错误、记录修改的文件

5. **3-Strike Error Protocol**
   - 第 1 次：诊断并修复
   - 第 2 次：尝试不同方法
   - 第 3 次：重新思考假设，向用户求助

---

## 技能配置

### 技能位置
```
~/.config/opencode/skills/
├── obsidian-markdown/
│   └── SKILL.md
└── planning-with-files/
    ├── SKILL.md
    ├── templates/
    │   ├── task_plan.md
    │   ├── findings.md
    │   └── progress.md
    ├── scripts/
    │   ├── init-session.sh
    │   ├── check-complete.sh
    │   └── session-catchup.py
    └── references/
        └── manus-principles.md
```

### 自动激活

这些技能会在以下场景自动激活：

**obsidian-markdown:**
- 编辑 `.md` 文件时
- 用户提到 wikilinks、callouts、frontmatter 时
- 创建 Obsidian 笔记时

**planning-with-files:**
- 开始复杂任务时（>3 步骤）
- 用户提到"planning"、"create plan"时
- 需要追踪进度时

---

## 最佳实践

### 对于 Obsidian 笔记

1. **始终使用 frontmatter**
   - 定义 title、tags、aliases
   - 便于搜索和组织

2. **使用双向链接**
   - `[[Note Name]]` 链接到内部笔记
   - Obsidian 会自动追踪重命名

3. **合理使用 callouts**
   - 突出重要信息
   - 使用正确的类型（note、warning、tip 等）

4. **嵌入而非复制**
   - 使用 `![[Note#Section]]` 嵌入相关内容
   - 保持单一事实源

### 对于文件规划

1. **在开始之前创建文件**
   - 不要边做边想
   - 先规划，后执行

2. **频繁更新**
   - 每个阶段后更新状态
   - 发现新信息立即记录

3. **诚实记录错误**
   - 每个错误都有学习价值
   - 建立错误知识库

4. **使用脚本辅助**
   - `session-catchup.py` 检查会话状态
   - `check-complete.sh` 验证完成度

---

## 故障排除

### 技能未激活

如果技能没有按预期激活：

1. 检查技能文件是否存在：
   ```bash
   ls ~/.config/opencode/skills/
   ```

2. 验证 SKILL.md 格式正确
3. 重启 Claude Code 会话

### 规划文件位置

**错误：** 在技能目录中创建规划文件
**正确：** 在项目根目录创建规划文件

规划文件应该与你的代码在一起，而不是在技能安装目录。

### 会话恢复

如果会话中断后需要恢复：

```bash
# 运行会话捕获脚本
python ~/.config/opencode/skills/planning-with-files/scripts/session-catchup.py $(pwd)
```

---

## 参考资源

- [Obsidian 官方文档](https://help.obsidian.md/)
- [Obsidian Flavored Markdown](https://help.obsidian.md/obsidian-flavored-markdown)
- [Manus 规划原则](references/manus-principles.md)
- [planning-with-files 原始仓库](https://github.com/OthmanAdi/planning-with-files)
- [obsidian-skills 原始仓库](https://github.com/kepano/obsidian-skills)

---

## 更新技能

要更新到最新版本：

```bash
# 重新下载 SKILL.md 文件
# 或者删除技能目录后重新安装
rm -rf ~/.config/opencode/skills/obsidian-markdown
rm -rf ~/.config/opencode/skills/planning-with-files
# 然后重新运行安装脚本
```

---

**安装日期：** 2026-03-17
**版本：** obsidian-markdown v1.0, planning-with-files v2.10.0
