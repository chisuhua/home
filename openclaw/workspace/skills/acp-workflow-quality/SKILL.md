# acp-workflow-quality - ACP 工作流质量控制技能

**版本**: v1.0  
**创建时间**: 2026-04-02  
**用途**: 确保 ACP-Workflow 驱动的开发任务遵循高质量标准

---

## 📋 用途

本技能用于在使用 OpenCode 或其他 ACP Agent 进行开发时，自动执行质量控制检查，确保：
1. 架构设计先行
2. 编译零警告
3. 系统性问题解决
4. 技能复用/创建
5. 流程规范遵循

---

## 🎯 触发条件

当通过 `sessions_spawn` 启动 ACP 任务时，自动激活本技能进行质量控制。

---

## 🔧 使用方法

### 方法 1: 在任务描述中包含质量检查要求

```markdown
# 任务描述模板

## 质量检查清单
- [ ] 架构设计文档已创建/更新
- [ ] 编译无错误、无警告
- [ ] 单元测试通过
- [ ] 已搜索现有技能
- [ ] 已考虑技能创建

## 工作流程
[按照 WORK_PRINCIPLES.md 执行]
```

### 方法 2: 使用本技能进行代码审查

```bash
# 代码审查命令
openclaw skill acp-workflow-quality review <file_path>
```

### 方法 3: 在 ACP 会话中引用本技能

```markdown
请遵循 acp-workflow-quality 技能的质量控制要求。
参考文档：`/home/ubuntu/.openclaw/workspace/docs/WORK_PRINCIPLES.md`
```

---

## ✅ 质量检查清单

### 架构质量检查

```markdown
## 架构设计
- [ ] 是否有架构图/模块划分图？
- [ ] 模块接口是否清晰定义？
- [ ] 数据流是否明确？
- [ ] 是否与现有系统兼容？
- [ ] 是否有设计文档？
```

### 编码质量检查

```markdown
## 代码质量
- [ ] 编译是否无错误？
- [ ] 编译是否无警告？
- [ ] 是否遵循框架编码规范？
- [ ] IO 端口访问是否正确？
- [ ] 类型是否匹配？
- [ ] 字面量格式是否正确？
- [ ] 是否有单元测试？
```

### 问题解决检查

```markdown
## 问题解决
- [ ] 错误信息是否完整收集？
- [ ] 错误是否已分类？
- [ ] 根因是否已分析？
- [ ] 解决方案是否系统性？
- [ ] 是否有验证方法？
- [ ] 是否有预防措施？
```

### 技能复用检查

```markdown
## 技能复用
- [ ] 是否搜索了现有技能？
- [ ] 是否有可复用的代码？
- [ ] 是否可以创建新技能？
- [ ] 技能是否有文档？
- [ ] 技能是否已测试？
```

### 流程规范检查

```markdown
## 流程规范
- [ ] 任务是否已分解？
- [ ] ACP 会话是否已创建？
- [ ] 任务说明是否清晰？
- [ ] 验收标准是否明确？
- [ ] 是否有超时设置？
- [ ] 结果是否已验收？
```

---

## 📊 质量评分卡

### 评分标准

| 等级 | 分数 | 标准 |
|------|------|------|
| A+ | 95-100 | 所有检查项通过，有额外优化 |
| A | 85-94 | 所有核心检查项通过 |
| B | 70-84 | 核心检查项基本通过，有轻微问题 |
| C | 60-69 | 部分检查项未通过，需要改进 |
| D | <60 | 多项检查项未通过，需要重大改进 |

### 评分模板

```markdown
## 质量评分

### 架构质量：__/20
- 模块划分：__/5
- 接口定义：__/5
- 数据流：__/5
- 文档完整性：__/5

### 编码质量：__/30
- 编译通过：__/10
- 无警告：__/5
- 代码规范：__/5
- 单元测试：__/10

### 问题解决：__/20
- 根因分析：__/10
- 解决方案：__/10

### 技能复用：__/15
- 技能搜索：__/5
- 技能创建：__/10

### 流程规范：__/15
- 任务分解：__/5
- ACP 使用：__/5
- 结果验收：__/5

### 总分：__/100 (等级：__)
```

---

## 🛠️ 实施工具

### 工具 1: 架构审查脚本

```bash
#!/bin/bash
# 架构审查脚本
# 用法：./review-architecture.sh <project_dir>

echo "=== 架构审查 ==="
echo "1. 检查架构图..."
find $1 -name "*.md" -exec grep -l "```mermaid" {} \;

echo "2. 检查模块接口..."
find $1 -name "*.h" -exec grep -l "__io(" {} \;

echo "3. 检查文档完整性..."
find $1 -name "README.md" -o -name "DESIGN.md"
```

### 工具 2: 编译质量检查脚本

```bash
#!/bin/bash
# 编译质量检查脚本
# 用法：./check-build-quality.sh <project_dir>

cd $1
make clean
make 2>&1 | tee build.log

ERRORS=$(grep -c "error:" build.log)
WARNINGS=$(grep -c "warning:" build.log)

echo "=== 编译质量报告 ==="
echo "错误数：$ERRORS"
echo "警告数：$WARNINGS"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ 编译质量：优秀"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️ 编译质量：良好 (有警告)"
else
    echo "❌ 编译质量：需要改进"
fi
```

### 工具 3: 技能搜索脚本

```bash
#!/bin/bash
# 技能搜索脚本
# 用法：./search-skills.sh <keyword>

echo "=== 搜索现有技能 ==="
echo "1. 本地技能..."
find ~/.agents/skills -name "SKILL.md" -exec grep -l "$1" {} \;

echo "2. ClawHub..."
# 调用 ClawHub API 搜索

echo "3. 项目内技能..."
find . -name "*skill*" -o -name "*Skill*"
```

---

## 📚 参考文档

- [WORK_PRINCIPLES.md](/home/ubuntu/.openclaw/workspace/docs/WORK_PRINCIPLES.md) - 工作原则总纲
- [skill-creator](~/.bun/install/global/node_modules/openclaw/skills/skill-creator/SKILL.md) - 技能创建指南
- [ClawHub](https://clawhub.ai) - 技能分享平台

---

## 🧪 测试

### 测试用例 1: 架构审查

```markdown
输入：RV32I 核心项目目录
预期输出：
- 架构图存在
- 模块接口清晰
- 文档完整
```

### 测试用例 2: 编译检查

```markdown
输入：CppHDL 项目
预期输出：
- 编译无错误
- 编译无警告
- 测试通过
```

### 测试用例 3: 技能搜索

```markdown
输入：关键词 "RV32I"
预期输出：
- 列出相关技能
- 提供复用建议
```

---

## 🔄 持续改进

### 改进记录

| 日期 | 改进内容 | 原因 |
|------|---------|------|
| 2026-04-02 | 初始版本 | 根据用户要求创建 |

### 待改进项

- [ ] 添加自动化检查工具
- [ ] 集成到 CI/CD 流程
- [ ] 添加质量趋势分析
- [ ] 创建质量仪表板

---

**维护者**: DevMate  
**许可证**: MIT
