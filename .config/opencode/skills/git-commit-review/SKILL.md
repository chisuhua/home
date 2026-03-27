# git-commit-review

**自动化 Git Commit 代码审查与修复技能**

## 适用场景

- 审查最近 N 个 commit 的代码变更
- 深度代码审查（逻辑错误、潜在 Bug、代码风格、安全性隐患、性能问题、架构设计、可维护性）
- 自动或半自动修复发现的问题
- 保持 Git 提交历史整洁

## 使用方式

```bash
# 基础用法（默认审查最近 3 个 commit）
/commit-review

# 指定审查数量
/commit-review 5

# 审查单个特定 commit（通过 commit hash）
/commit-review a1b2c3d
/commit-review abc1234def5678

# 审查 commit 范围
/commit-review a1b2c3d..e4f5g6h
/commit-review HEAD~10..HEAD~5

# 审查分支差异
/commit-review feature-branch          # 审查 feature-branch 相对于当前分支的差异
/commit-review HEAD..feature-branch    # 同上，显式语法
/commit-review main..feature-branch    # 审查 main 到 feature-branch 的差异

# 仅审查不修复
/commit-review --report-only

# 指定文件范围审查
/commit-review --files="src/*.cpp"

# 组合使用
/commit-review a1b2c3d --report-only --files="src/*.cpp"
```

### 参数格式说明

| 输入格式 | 示例 | 审查范围 |
|----------|------|----------|
| 无参数 | `/commit-review` | 最近 3 个 commit（`HEAD~3..HEAD`） |
| 数字 | `/commit-review 5` | 最近 5 个 commit（`HEAD~5..HEAD`） |
| Commit Hash（短） | `/commit-review a1b2c3d` | 单个 commit（`a1b2c3d^..a1b2c3d`） |
| Commit Hash（长） | `/commit-review abc1234def5678` | 单个 commit |
| Commit 范围 | `/commit-review a1b2c3d..e4f5g6h` | 指定范围内的所有 commit |
| 分支名 | `/commit-review feature-branch` | 当前 HEAD 到分支 tip 的差异 |
| 分支范围 | `/commit-review main..feature` | 两个分支间的差异 |

## 工作流程

### 阶段 1：获取变更内容

**步骤 1：解析输入参数**

```bash
# 检测输入类型并确定审查范围
if [[ -z "$input" ]]; then
    # 无参数：默认最近 3 个 commit
    RANGE="HEAD~3..HEAD"
    MODE="recent"
elif [[ "$input" =~ ^[0-9]+$ ]]; then
    # 纯数字：最近 N 个 commit
    RANGE="HEAD~${input}..HEAD"
    MODE="recent"
elif [[ "$input" =~ ^[a-f0-9]{7,40}$ ]]; then
    # 单个 commit hash（7-40 位十六进制）
    RANGE="${input}^..${input}"
    MODE="single"
    COMMIT_INFO=$(git log -1 --format="%H|%an|%ae|%ai|%s" "$input")
elif [[ "$input" =~ \.\. ]]; then
    # commit 范围（包含 ..）
    RANGE="$input"
    MODE="range"
else
    # 分支名或引用
    if [[ "$input" =~ ^HEAD\.\. ]]; then
        # HEAD..branch 格式
        RANGE="$input"
    else
        # 单独分支名：审查当前 HEAD 到该分支的差异
        RANGE="HEAD..$input"
    fi
    MODE="branch"
fi
```

**步骤 2：获取变更文件列表**

```bash
git diff ${RANGE} --stat
```

**步骤 3：获取完整 diff**

```bash
git diff ${RANGE}
```

**步骤 4：获取 commit 信息**

```bash
# 单个 commit 模式：显示详细信息
if [[ "$MODE" == "single" ]]; then
    git log -1 --format="Hash: %H%nAuthor: %an <%ae>%nDate: %ai%nMessage: %s%n" ${RANGE}
fi

# 多 commit 模式：显示 commit 列表
git log ${RANGE} --oneline
```

**步骤 5：读取变更的文件内容（当前工作树版本）**

### 阶段 2：深度代码审查

**审查维度**（必须全部检查）：

| 维度 | 检查项 |
|------|--------|
| **逻辑错误** | 条件判断错误、边界条件、空指针解引用、资源泄漏 |
| **潜在 Bug** | 未初始化变量、数组越界、类型转换问题、竞态条件 |
| **代码风格** | 命名规范、缩进格式、注释完整性、函数长度 |
| **安全性** | 缓冲区溢出、SQL 注入、路径遍历、敏感信息泄漏 |
| **性能问题** | 不必要的拷贝、低效循环、内存分配、I/O 操作 |
| **架构设计** | 模块耦合度、单一职责、依赖方向、接口设计 |
| **可维护性** | 代码重复度、函数复杂度、测试覆盖、文档完整性 |

**审查输出格式**：

```markdown
## 审查报告 - Commit {hash}

**Author**: {author_name} <{author_email}>
**Date**: {commit_date}
**Message**: {commit_subject}
**Full Hash**: {full_commit_hash}
**Files Changed**: {N} files, +{additions} -{deletions}

### 🔴 严重问题（必须修复）
| 文件 | 行号 | 问题描述 | 建议修复 |
|------|------|----------|----------|
| src/engine.cpp | 45 | 空指针未检查 | 添加 if (ptr != nullptr) 判断 |

### 🟡 警告（建议修复）
...

### 🟢 提示（可选改进）
...
```

**多 Commit 审查报告格式**：

```markdown
## 代码审查报告

**审查范围**: {RANGE} ({N} commits, {M} files changed)
**审查时间**: {timestamp}

### Commit 列表
| Hash | Author | Message |
|------|--------|---------|
| a1b2c3d | John Doe | feat: add new feature |
| e4f5g6h | Jane Smith | fix: resolve bug |

### 问题统计（总计）
- 🔴 严重：X 个
- 🟡 警告：Y 个
- 🟢 提示：Z 个

### 按 Commit 分组的问题
...
```

### 阶段 3：问题汇总与用户确认

1. **生成问题清单**：按严重程度排序（严重 > 警告 > 提示）
2. **估算修复工作量**：每个问题的预计修复时间
3. **等待用户确认**：
   - "发现 X 个严重问题，Y 个警告，Z 个提示。是否全部修复？"
   - 用户可选择：全部修复 / 部分修复 / 仅查看报告

### 阶段 4：执行修复

**修复原则**：

- 优先修复严重问题（🔴）
- 每个修复必须是原子操作
- 修复后必须验证编译通过
- 保持原有代码风格一致

**修复流程**：

1. 创建备份：`git stash push -m "pre-review-backup-{timestamp}"`
2. 逐个修复问题
3. 每个修复后执行：
   - 编译验证：`cmake --build build/ --target <affected_target>`
   - 静态检查：`clang-tidy -p build/ <file>`
   - 运行测试：`ctest -R <affected_test>`
4. 验证失败则回滚该修复

### 阶段 5：提交历史整理

**Squash 策略**：

```bash
# 方案 1：使用 fixup! 自动 squash
git commit --fixup=<original_commit_hash>

# 后续用户执行：git rebase -i --autosquash HEAD~N

# 方案 2：直接修改原 commit（如果只有一个 commit 需要修复）
git add .
git commit --amend --no-edit

# 方案 3：追加独立 fix commit（推荐用于多 commit 场景）
git add .
git commit -m "fix: address code review issues

- 修复问题 1 描述
- 修复问题 2 描述
- ..."
```

**选择逻辑**：

- 仅 1 个原 commit → 使用 `--amend`
- 多个原 commit → 使用 `fixup!` + 告知用户执行 `rebase --autosquash`
- 用户明确选择不修改历史 → 追加独立 fix commit

## 约束条件

**必须遵守**：

- [ ] 审查前必须确认工作树干净（`git status --porcelain`）
- [ ] 修复前必须创建备份（`git stash` 或 `.bak` 文件）
- [ ] 每个修复必须验证编译通过
- [ ] 禁止 suppress 类型错误（`as any`, `@ts-ignore`）
- [ ] 修复失败必须回滚并报告用户
- [ ] 提交信息必须清晰描述修复内容

**禁止操作**：

- ❌ 未经用户确认直接修改代码
- ❌ 自动执行 `git push --force`
- ❌ 删除或重写用户 commit 信息
- ❌ 修改与审查无关的文件

## 配置选项

在 `.opencode/skills/git-commit-review/config.json` 中可配置：

```json
{
  "default_commits": 3,
  "review_depth": "deep",
  "auto_fix_severity": ["critical", "major"],
  "skip_review_files": ["*.md", "*.txt", "docs/*"],
  "clang_tidy_checks": ["cppcoreguidelines-*", "modernize-*"],
  "require_test_coverage": true
}
```

## 输出示例

### 示例 1：单个 Commit 审查

```
## 代码审查报告

**审查范围**: a1b2c3d^..a1b2c3d (1 commit)
**Commit**: a1b2c3d4e5f6789012345678901234567890abcd
**Author**: John Doe <john.doe@example.com>
**Date**: 2026-03-25 14:30:00 +0800
**Message**: feat: add new connection pooling logic
**Files Changed**: 3 files, +145 -23

### 问题统计
- 🔴 严重：2 个
- 🟡 警告：5 个
- 🟢 提示：3 个

### 🔴 严重问题（必须修复）

#### 1. 空指针解引用风险
**文件**: src/net/connection.cpp:145
**问题**: `conn->send()` 调用前未检查 conn 是否为空
**风险**: 可能导致段错误
**建议**: 添加 `if (conn) { conn->send(); }`

#### 2. 资源泄漏
**文件**: src/core/engine.cpp:89
**问题**: 异常路径未释放 mutex 锁
**风险**: 死锁风险
**建议**: 使用 std::lock_guard 替代手动 lock/unlock

### 下一步操作
1. 是否修复所有严重问题？(Y/n)
2. 是否同时修复警告？(y/N)
3. 是否生成详细报告文件？(y/N)
```

### 示例 2：Commit 范围审查

```
## 代码审查报告

**审查范围**: a1b2c3d..e4f5g6h (5 commits, 12 files changed)
**审查时间**: 2026-03-25 14:30:00

### Commit 列表
| Hash | Author | Message |
|------|--------|---------|
| e4f5g6h | Jane Smith | fix: resolve race condition |
| d3e4f5g | John Doe | refactor: simplify connection logic |
| c2d3e4f | Jane Smith | feat: add timeout support |
| b1c2d3e | John Doe | test: add unit tests |
| a1b2c3d | Jane Smith | docs: update API docs |

### 问题统计（总计）
- 🔴 严重：3 个
- 🟡 警告：7 个
- 🟢 提示：5 个

### 问题详情
...
```

### 示例 3：分支差异审查

```
## 代码审查报告

**审查范围**: HEAD..feature-branch (8 commits ahead)
**分支**: feature-branch
**审查时间**: 2026-03-25 14:30:00

### 分支状态
- 当前分支：main (abc1234)
- 目标分支：feature-branch (def5678)
- 差异：8 commits, +234 -56

### 问题统计
...
```

## 工具依赖

- `git` (版本 >= 2.23，支持 `git restore`)
- `cmake` (构建验证)
- `clang-tidy` (静态检查)
- `ctest` (测试验证)

## 故障恢复

**如果修复过程中断**：

```bash
# 恢复备份
git stash pop

# 或恢复文件
cp src/file.cpp.bak src/file.cpp

# 清理状态
git status
```

**如果 squash 失败**：

```bash
# 中止 rebase
git rebase --abort

# 恢复原分支
git reflog
git reset --hard HEAD@{1}
```

## 版本历史

- **v1.1** (2026-03-26): 支持指定 Commit 审查
  - 新增单个 commit hash 审查（`/commit-review a1b2c3d`）
  - 新增 commit 范围审查（`/commit-review a1b2c3d..e4f5g6h`）
  - 新增分支差异审查（`/commit-review feature-branch`）
  - 增强审查报告：显示作者、日期、完整 hash、变更统计
  - 参数解析逻辑优化：自动识别输入类型（数字/hash/范围/分支）

- **v1.0** (2026-03-25): 初始版本
  - 支持自定义 commit 数量
  - 深度审查 7 个维度
  - 先报告后修复工作流
  - Squash 合并策略
