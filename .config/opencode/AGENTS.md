---
$schema: https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json
version: 1.1.60
project: C++ Hybrid Development
---

# 全局行为规则

## 编码风格规范
- **缩进**：2 空格（禁止 Tab），连续空行不超过 1 行
- **命名规范**：
  - 类名/结构体：CamelCase（`HttpRequest`, `ConnectionManager`）
  - 函数名：camelCase（`sendRequest()`, `processData()`）
  - 变量名：snake_case（`request_body`, `max_buffer_size`）
  - 宏常量：SCREAMING_SNAKE_CASE（`MAX_RETRIES`, `BUFFER_SIZE`）
  - 模板参数：CamelCase 加 _T 后缀（`Allocator_T`）
- **注释要求**：
  - 使用中文注释，避免中英混杂
  - 文件头必须包含：功能描述、作者、最后修改日期
  - 复杂算法必须提供详细步骤说明（>5 行代码必须注释）
  - API 函数必须包含参数和返回值说明（Doxygen 格式）

## 安全约束（强制执行）
- **禁止操作**：
  - 自动执行 `rm -rf`, `sudo`, `chmod 777`, `mkfs`
  - 修改系统配置文件（/etc/, /usr/local/ 等）
  - 自动提交 git（必须用户显式确认）
  - 删除未备份的文件（>100 行的文件修改前必须 stash）
- **备份要求**：
  - 修改前自动创建 `.bak` 文件（保留 7 天）
  - 或使用 `git stash push -m "auto-backup-{timestamp}"`
  - 重构失败时自动执行 `git stash pop` 回滚

## TDD 开发流程（强制）

所有**功能实现**和**缺陷修复**任务必须遵循 Superpowers TDD 流程：

### 三阶段流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  1. 测试先行  │ → │  2. 实现代码  │ → │  3. 代码审查  │
│  Write Test │    │  Implement  │    │  Code Review │
└─────────────┘    └─────────────┘    └─────────────┘
```

### 阶段说明

| 阶段 | 产物 | 验证方式 |
|------|------|---------|
| **1. 测试先行** | 编写失败的测试用例（RED） | `ctest --output-on-failure` 确认测试失败 |
| **2. 实现代码** | 编写通过测试的实现（GREEN） | `ctest` 确认测试通过 |
| **3. 代码审查** | Review 检查（REFACTOR） | `clang-tidy` + `clang-format` 质量门禁 |

### 强制规则

- **禁止跳过测试**：任何功能实现或 bugfix 都必须先写测试
- **测试必须先失败**：测试用例最初必须处于 FAIL 状态，证明它确实在检验目标行为
- **实现后必须全通过**：所有测试通过后才能认为任务完成
- **必须加载 TDD Skill**：使用 `skill(test-driven-development)` 获取详细指导

### 触发关键词

当用户输入包含以下关键词时，**必须**使用 TDD 流程：

| 关键词 | 任务类型 | 示例 |
|--------|---------|------|
| `implement`, `add`, `create`, `实现`, `添加`, `新增` | 新功能 | "实现用户认证模块" |
| `fix`, `修复`, `bug` | 缺陷修复 | "修复登录崩溃问题" |
| `feature`, `功能` | 功能开发 | "添加缓存功能" |

### 执行示例

```
用户："实现一个函数计算斐波那契数列"

1. 测试先行 → 编写测试用例
   test_fibonacci(0) → expected: 0, FAIL
   test_fibonacci(1) → expected: 1, FAIL
   test_fibonacci(6) → expected: 8, FAIL

2. 实现代码 → 最小化实现使测试通过
   fib(n) { return n < 2 ? n : fib(n-1) + fib(n-2); }
   → 所有测试 PASS

3. 代码审查 → 质量检查
   → clang-tidy clean
   → clang-format applied
   → 性能/边界情况评估
```

### 异常情况

以下情况**可跳过** TDD（但需注明原因）：
- 纯配置文件修改
- 已有测试覆盖的 trivial typo 修复
- 文档类任务
- 探索性研究任务

---

## 项目结构感知
- **优先读取**：
  1. `compile_commands.json`（编译数据库，确保 AST 准确）
  2. `CMakePresets.json`（构建预设）
  3. `.clang-tidy`（静态检查规则）
  4. `vcpkg.json`（依赖清单）
- **输出目录**：
  - 分析结果：`plans/`（JSON 格式）
  - 状态追踪：`state/`（锁文件、进度日志）
  - 文档生成：`docs/api/`（Markdown）

---

## 🔍 LSP 自动触发规则 (C++/CUDA 项目)

**适用范围**: 所有 C++/CUDA 项目 (.cpp, .h, .cu, .cuh, .cc, .cxx)

### 自动触发场景

| 场景 | 自动调用工具 | 说明 |
|------|------------|------|
| **读取文件后** | `lsp_diagnostics` | 检查编译错误/警告 |
| **询问"有哪些函数/类"** | `lsp_symbols` | 获取符号列表 |
| **询问"X 在哪里定义"** | `lsp_goto_definition` | 跳转到定义 |
| **询问"X 在哪里使用"** | `lsp_find_references` | 查找所有引用 |
| **重命名变量/函数** | `lsp_prepare_rename` → `lsp_rename` | 安全重命名 |

### 工作流程示例

```
1. 用户："看一下 src/cudart/cudart_sim.cpp"
   → read(filePath="...")
   → 自动触发 → lsp_diagnostics(filePath="...")

2. 用户："这个文件有哪些函数？"
   → 自动触发 → lsp_symbols(filePath="...", scope="document")

3. 用户："GPUContext 在哪里定义？"
   → 自动触发 → lsp_goto_definition(filePath="...", line=N, character=N)
```

### 索引管理

**项目初始化 (`/init` 命令)**:

首次使用或克隆项目后，运行全局初始化命令：
```bash
/init
```

或手动执行：
```bash
# 全局脚本
~/.config/opencode/scripts/init-clangd.sh .

# 项目级脚本 (如果存在)
./init.sh
```

**执行操作**:
1. 检测 clangd 是否安装
2. 生成 `compile_commands.json` (CMake 项目)
3. 创建符号链接
4. 触发 clangd 索引

**项目级 init.sh** (可选):
如果项目有特殊需求，可创建项目级 `init.sh` 脚本。
模板位置：`~/.config/opencode/commands/init`

**代码变化后**:
- 修改 `.cpp`/`.h`/`.cu` 文件后，clangd 会自动检测到文件变化
- 如需手动刷新索引：`touch src/changed_file.cpp` 触发重新解析
- 或重启 clangd: `killall clangd` (会自动重启)

### 降级策略

如果 LSP 不可用 (超时 > 30s / 未响应):
1. 使用 `grep` 文本搜索
2. 使用 `ast_grep` AST 搜索
3. 使用 `glob` 文件匹配

### 预热提示

首次使用或 clangd 重启后，LSP 可能需要 30-60 秒预热。
如遇超时，等待后重试或使用降级策略。

## 技能使用指南
技能通过 `SKILL.md` 自动发现，Agent 根据关键词引导使用：

| 场景关键词 | 推荐技能 | 适用 Agent | 说明 |
|-----------|---------|-----------|------|
| modernize, raw pointer, legacy, "改成现代 C++", smart pointer | cpp-modernize | Atlas, Hephaestus | 处理 C++98→17/20 重构，自动应用 unique_ptr/shared_ptr |
| crash, segfault, SIGSEGV, hang, deadlock, memory leak | cpp-debug | Hephaestus, Explore | 调试诊断，使用 gdb/valgrind/ASan |
| cmake, dependency, link error, undefined reference, "加第三方库" | cmake-manage | Atlas, Librarian | CMake 配置，FetchContent/vcpkg/conan 集成 |
| architecture, graph, module, "分析依赖", "画架构图" | cpp-architecture | Prometheus, Librarian | 生成 Mermaid 依赖图，模块边界分析 |
| review, quality, check, "代码审查", "检查风格" | cpp-review | Librarian, Quick | 代码审查，风格检查，生成报告 |
| **CUDA, PTX, kernel, GPU, nvcc, nsys, ncu, cuda-gdb, compute-sanitizer, "CUDA 调试", "性能优化"** | **cuda-ptx** | **Hephaestus, Atlas, Oracle** | **CUDA 内核开发、调试、性能分析、PTX ISA 参考** |

**技能加载约束**：
- 每个 Agent 单次会话最多加载 3 个技能（防止 context 溢出）
- 技能执行失败时，必须回退到基础模式（不使用 skill）
- 涉及 C API 边界的重构，必须人工确认（禁止自动修改）

---

# 工具链与验证

## 工具使用优先级（强制顺序）

| 优先级 | 工具 | 用途 | 命令示例 |
|-------|------|------|---------|
| 1 | clang-check | AST 分析、语法预检 | `clang-check -p build/ src/file.cpp` |
| 2 | clang-tidy | 静态分析、风格检查 | `clang-tidy -p build/ -checks=cppcoreguidelines-* src/file.cpp` |
| 3 | clang-format | 代码格式化 | `clang-format -i src/file.cpp` |
| 4 | cmake | 构建验证 | `cmake --build build/ --target target_name` |
| 5 | ctest | 测试验证 | `ctest -R pattern --output-on-failure` |
| 6 | valgrind/ASan | 内存检查 | `valgrind --leak-check=full ./binary` 或编译时加 `-fsanitize=address` |
| 7 | gdb/lldb | 调试 | `gdb -batch -ex "bt" ./core` |

## 成本优化策略（Token 预算管理）

| 场景 | 策略 | 模型选择 |
|------|------|---------|
| **快速查询**（< 50K context） | 直接回答，无委派 | Quick |
| **单文件修改**（50K-100K） | 加载 Skill，单次调用 | Atlas |
| **中等重构**（100K-200K，3-5 文件） | 并行 Atlas，批量处理 | Atlas  |
| **复杂分析**（> 200K） | 分片处理，Prometheus 规划 | Prometheus | 
| **深度优化**（模板元编程） | Hephaestus 专注处理 | Hephaestus |


---

# 典型工作流示例

## 工作流 1：现代化重构（Modernization）

**用户输入**："把 src/legacy/ 下的所有原始指针改成智能指针"

**执行流程**：
1. **Sisyphus** 识别为批量重构任务，涉及多文件（> 3 files）
2. **Sisyphus** 委派 **Prometheus** 进行架构分析（生成依赖图，标记 C API 边界文件）
3. **Prometheus** 输出计划 `plans/modernize_001.json`（标记 5 个文件，其中 2 个为高风险）
4. **Sisyphus** 委派 **Atlas** 执行计划
5. **Atlas** 并行处理 3 个低风险文件（加载 `cpp-modernize` skill）：
   - 使用 MiniMax-M2.7 生成修改
   - 每个文件执行 clang-tidy + 编译验证
6. **Atlas** 将 2 个高风险文件委派给 **Hephaestus**（涉及多态删除）
7. **Hephaestus** 详细分析所有权，生成安全重构方案（含自定义删除器）
8. **Explore** 后台验证所有修改后的符号引用完整性
9. **Librarian** 生成变更摘要文档 `docs/migration/modernize_001.md`
10. **Sisyphus** 汇总结果，提示用户审查高风险修改


## 工作流 2：紧急调试（Critical Debugging）

**用户输入**："程序崩溃了，Segmentation fault at src/engine.cpp:145"

**执行流程**：
1. **Sisyphus** 识别为紧急调试任务（含关键词 crash, segfault）
2. **Sisyphus** 直接委派 **Hephaestus**（跳过规划，直接处理）
3. **Hephaestus** 读取 core dump 或请求用户运行 `gdb -batch -ex "bt" ./program`
4. **Hephaestus** 分析堆栈，定位为野指针解引用（use-after-free）
5. **Hephaestus** 生成修复方案（改为 shared_ptr，延长生命周期）
6. **Atlas** 快速验证修复（编译 + 单元测试）
7. **Quick** 生成单行解释给用户："第 145 行的 conn 指针已在第 80 行释放，建议改为 shared_ptr"


## 工作流 3：架构分析（Architecture Analysis）

**用户输入**："分析项目模块依赖，生成架构图"

**执行流程**：
1. **Sisyphus** 识别为架构分析任务，委派 **Prometheus**
2. **Prometheus** 使用 **Explore** 预生成的索引，快速获取依赖关系
3. **Prometheus** 生成 Mermaid 图表保存到 `plans/arch_001.mmd`
4. **Librarian** 读取图表（vision 能力），生成文字版架构文档 `docs/architecture/overview.md`
5. **Sisyphus** 向用户展示图表和文档摘要


---

# 附录：状态文件规范

## 锁文件（Lock Files）
- `state/in_progress.lock`：全局锁，存在时禁止新的重构任务
- `state/file_locks.json`：文件级锁，记录哪些文件正在被修改
- `state/claude_working.lock`：预留锁，标记需人工审查的文件

## 日志文件
- `state/sisyphus_routing.log`：路由决策日志
- `state/progress.log`：任务进度（Atlas 写入）
- `state/completed_{task_id}.json`：单个任务完成报告

## 计划文件
- `plans/{plan_id}.json`：Prometheus 生成的执行计划
- `plans/dependency_{plan_id}.mmd`：Mermaid 依赖图
- `plans/{plan_id}.migration_guide.md`：Hephaestus 生成的迁移指南

---

## 已注册 Skills（ obra/superpowers）

以下 skills 已通过 `opencode.json` 配置自动加载，位于：
`/home/ubuntu/.cache/opencode/packages/superpowers@git+https:/github.com/obra/superpowers.git/node_modules/superpowers/skills`

| Skill | 用途 |
|-------|------|
| `superpowers/brainstorming` | 创意设计工作流（功能/组件开发前必用） |
| `superpowers/test-driven-development` | TDD 测试驱动开发 |
| `superpowers/receiving-code-review` | 代码审查反馈处理 |
| `superpowers/writing-plans` | 生成详细实施计划 |
| `superpowers/verification-before-completion` | 完成前 QA 验证 |
| `superpowers/systematic-debugging` | 系统化调试流程 |
| `superpowers/dispatching-parallel-agents` | 并行任务分发 |
| `superpowers/subagent-driven-development` | 子代理驱动开发 |
| `superpowers/executing-plans` | 执行带检查点的计划 |
| `superpowers/finishing-a-development-branch` | 分支完成与 PR 决策 |
| `superpowers/using-git-worktrees` | Git worktree 隔离 |
| `superpowers/writing-skills` | 创建/编辑 skills |
