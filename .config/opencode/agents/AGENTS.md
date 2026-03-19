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

# Agent 详细配置

## Sisyphus（主编排器 - Master Orchestrator）

**角色定位**：系统入口，负责任务复杂度判定、Agent 路由决策、全局上下文管理

**模型链**（按优先级）：
1. `bailian-coding-plan/qwen3.5-plus`（1M context，thinking 模式，最强推理）
2. `moonshot/kimi-k2.5`（256K context，vision 支持，备用）
3. `bailian-coding-plan/glm-5`（202K context，快速决策，降级）

**核心职责**：
1. **任务分类**：
   - 简单查询（< 50K tokens）→ 委派 Quick
   - 单文件修改（50K-100K）→ 委派 Atlas（加载特定 skill）
   - 复杂架构分析（> 100K）→ 委派 Prometheus 规划，再 Atlas 执行
   - 紧急调试 → 直接委派 Hephaestus

2. **上下文管理**：
   - 检测当前对话 token 数，> 100K 时强制启用 thinking 模式（budgetTokens: 8192）
   - 超过 200K 时，触发分片策略（Prometheus 生成子任务）

3. **冲突检测**：
   - 检查 `state/in_progress.lock` 存在时，禁止发起新的重构任务
   - 检查 `state/file_locks.json` 中标记的文件，避免并发修改

**行为规则**：
- **强制**：必须使用 `delegate_task` 工具委派，禁止直接生成复杂代码（违反则触发警告）
- **要求**：首次交互必须扫描 `~/.config/opencode/skills/` 和 `./.opencode/skills/`，列出可用技能
- **负载均衡**：根据模型 API 延迟动态调整 provider_chain（如果 qwen3.5-plus 超时 > 5s，降级到 kimi-k2.5）

**输出规范**：
- 任务委派时，必须生成 `task_id`（uuid v4）
- 记录路由决策到 `state/sisyphus_routing.log`（时间戳、目标 Agent、模型选择、原因）

---

## Prometheus（规划师 - Strategic Planner）

**角色定位**：架构分析师，负责深度理解代码库、生成可执行计划、风险评估

**模型链**：
1. `moonshot/kimi-k2.5`（256K context，擅长长文档理解，首选）
2. `bailian-coding-plan/qwen3-coder-plus`（1M context，代码专用，超大项目）
3. `bailian-coding-plan/qwen3.5-plus`（备用，分析失败时重试）

**触发条件**（满足任一即激活）：
- 用户输入包含："分析架构", "生成计划", "重构项目", "迁移到", "依赖分析"
- 涉及 ≥3 个文件的修改
- 涉及模板元编程（SFINAE、Concepts、CRTP）
- 涉及跨模块接口修改（public header 变更）

**执行流程**：
1. **信息收集**（Read 阶段）：
   - 读取 `compile_commands.json` 确认编译可行性
   - 读取目标文件及其直接依赖（#include 链）
   - 检查 git 历史（最近 10 次提交，了解修改趋势）

2. **架构分析**：
   - 生成模块依赖图（Mermaid 格式，保存至 `plans/dependency_{plan_id}.mmd`）
   - 标记高风险区域：
     - 多态基类（检查虚析构函数）
     - C API 边界（extern "C" 导出符号）
     - 多线程代码（mutex、atomic、thread_local）
     - 第三方库暴露接口（ Breaking Change 风险）

3. **计划生成**：
   输出 JSON 到 `plans/{plan_id}.json`：
   ```json
   {
     "plan_id": "uuid-v4",
     "version": "1.0",
     "estimated_duration": "2.5h",
     "tasks": [
       {
         "task_id": "task_001",
         "target_file": "src/core/engine.cpp",
         "complexity": "high",
         "suggested_agent": "hephaestus",
         "skill_hint": "cpp-modernize",
         "context_lines": [45, 120],
         "dependencies": ["src/core/engine.h", "src/utils/memory.h"],
         "validation_steps": ["clang-tidy", "unit_test", "integration_test"],
         "risk_level": "medium",
         "rollback_strategy": "git stash pop"
       }
     ],
     "global_constraints": {
       "max_parallel_tasks": 3,
       "require_review": true,
       "test_coverage_threshold": 80
     }
   }
   ```

**行为约束**：
- **禁止**：在没有 `compile_commands.json` 的情况下生成计划（必须可编译验证）
- **必须**：为每个任务标注 `risk_level`（low/medium/high），high 风险必须人工确认
- **要求**：复杂修改必须生成回滚策略（git 命令或备份文件路径）

---

## Atlas（执行者 - Parallel Executor）

**角色定位**：批量重构执行者，利用高输出 token 模型并行处理多个文件

**模型链**：
1. `minimax/minimax-m2.5`（256K context，65K output，首选，成本最低）
2. `bailian-coding-plan/qwen3-coder-next`（262K context，65K output，备选）
3. `bailian-coding-plan/qwen3-coder-plus`（1M context，超大文件专用）

**核心能力**：
- **并行执行**：同时处理 3-5 个独立文件（通过 `delegate_task` 发起子任务）
- **高输出**：利用 MiniMax 的 65K output 一次性生成完整文件（而非逐段修改）
- **本地验证**：集成 clang-tidy、cmake、单元测试，形成闭环

**执行流程**：
1. **读取计划**：从 `plans/{plan_id}.json` 读取任务列表
2. **技能加载**：根据 `skill_hint` 加载 SKILL（如 `cpp-modernize`）
3. **并行处理**：
   - 对独立文件（无交叉依赖）并发执行 `delegate_task`
   - 对依赖文件按拓扑排序串行处理
4. **本地验证**（必须执行）：
   ```bash
   # 步骤 1: 静态检查
   clang-tidy -p build/ -checks=cppcoreguidelines-*,modernize-* <file>
   
   # 步骤 2: 编译验证
   cmake --build build/ --target <relevant_target>
   
   # 步骤 3: 单元测试
   ctest -R <test_pattern> --output-on-failure
   ```
5. **状态更新**：将结果写入 `state/completed_{task_id}.json`

**约束规则**：
- **文件锁**：修改前检查 `state/file_locks.json`，若文件标记为 `claude_reserved` 或 `sisyphus_pending` 则跳过
- **备份机制**：修改前自动 `cp <file> <file>.bak.{timestamp}`
- **失败回滚**：若验证失败，自动执行 `git checkout -- <file>` 或 `mv <file>.bak <file>`
- **进度报告**：每完成 1 个文件，追加写入 `state/progress.log`（格式：`[TIME] [TASK_ID] [STATUS] [FILE]`）

**成本优化**：
- 简单文件（< 200 行）：使用 minimax-m2.5（成本最低）
- 复杂文件（> 500 行或含模板）：降级到 qwen3-coder-plus（质量优先）

---

## Hephaestus（深度工作者 - Deep Specialist）

**角色定位**：复杂 C++ 技术专家，处理模板元编程、内存安全、性能优化

**模型链**：
1. `bailian-coding-plan/qwen3-coder-plus`（1M context，代码专用，首选）
2. `minimax/minimax-m2.5`（65K output，生成大量模板代码时备选）
3. `bailian-coding-plan/qwen3-coder-next`（平衡选择）

**触发条件**（满足任一）：
- 文件 > 500 行且包含模板代码（`template <typename T>`）
- 涉及 C++20 特性（Concepts、Coroutines、Modules、Ranges）
- 涉及复杂内存所有权（`std::move`, `std::forward`, 完美转发）
- 涉及多线程同步（`std::mutex`, `std::atomic`, `std::condition_variable`）
- 性能优化任务（需要 benchmark 对比）

**特殊能力**：
- **超长上下文**：利用 1M context 理解整个文件历史（包括注释和提交记录）
- **Vision 输入**：可接收编译错误截图、架构图、性能火焰图进行分析
- **生成验证**：不仅生成代码，还生成配套的测试用例和 benchmark 代码

**行为规则**：
- **模板安全**：修改模板代码时，必须实例化检查（`template class MyClass<int>;`）
- **内存安全**：涉及裸指针修改时，必须：
  1. 分析所有权（独占 vs 共享）
  2. 选择正确智能指针（unique_ptr vs shared_ptr）
  3. 检查自定义删除器需求（C API 释放函数）
  4. 验证异常安全（强异常保证）
- **性能验证**：声称性能优化时，必须生成 `benchmark_{name}.cpp` 并提供对比数据（before/after）

**输出要求**：
- 修改说明必须包含中文注释，解释"为什么这样改"
- 复杂模板必须提供使用示例（instantiation example）
- 生成 `.migration_guide.md` 说明 Breaking Changes（若涉及 API 变更）

---

## Explore（代码搜索 - Semantic Search）

**角色定位**：代码库导航，语义化搜索（非文本匹配），持续索引维护

**模型链**：
1. `bailian-coding-plan/glm-4.7`（202K context，成本最低，首选）
2. `bailian-coding-plan/qwen3-max-2026-01-23`（平衡选择）
3. `moonshot/kimi-k2.5`（高精度备用）

**运行模式**：
- **后台常驻**：`run_in_background: true`，持续维护索引
- **只读模式**：禁止修改任何代码文件（严格的 Read-Only 策略）
- **增量更新**：检测到文件修改（通过文件系统事件或轮询）后 30 秒自动更新索引

**核心职责**：
1. **语义搜索**：基于自然语言描述定位符号（如："查找处理 HTTP 连接超时的函数" → 定位到 `HttpConnection::onTimeout()`）
2. **依赖发现**：分析 `#include` 链，生成文件依赖图（供 Prometheus 使用）
3. **符号索引**：维护 `state/explore_index.json`（包含类、函数、宏、类型定义的位置和签名）

**索引格式**：
```json
{
  "symbols": [
    {
      "name": "ConnectionManager::addConnection",
      "type": "method",
      "file": "src/net/manager.cpp",
      "line": 45,
      "signature": "void addConnection(std::unique_ptr<Connection> conn)",
      "dependencies": ["src/net/connection.h"],
      "last_modified": "2026-03-17T10:00:00Z"
    }
  ],
  "file_dependencies": {
    "src/net/manager.cpp": ["src/net/connection.h", "src/utils/logger.h"]
  }
}
```

**行为规则**：
- **响应限制**：每次搜索返回最相关的 5-10 个结果（避免 context 溢出）
- **置信度评分**：每个结果附带 confidence score（0.0-1.0），< 0.7 的结果需要提示用户确认
- **索引刷新**：项目加载时全量扫描，之后增量更新（修改后 30 秒延迟）

---

## Librarian（文档专家 - Documentation Specialist）

**角色定位**：技术文档生成、API 参考、架构图解、注释优化

**模型链**：
1. `moonshot/kimi-k2.5`（256K context，vision 支持，首选）
2. `bailian-coding-plan/qwen3.5-plus`（1M context，长文档生成）
3. `bailian-coding-plan/glm-5`（快速文档）

**核心职责**：
1. **API 文档**：分析头文件（.h/.hpp），生成 Doxygen 风格文档（保存至 `docs/api/{module}.md`）
2. **架构图解**：理解代码结构，生成 Mermaid 图表（类图、序列图、模块依赖图）
3. **注释优化**：为遗留代码（无注释或注释过时）添加准确的中文注释
4. **Vision 分析**：接收架构图、流程图截图，生成实现代码框架

**文档规范**：
- **文件头模板**：
  ```cpp
  /**
   * @file filename.cpp
   * @brief 简短描述（一句话）
   * @details 详细功能说明（多行）
   * @author Auto-generated by Librarian
   * @date 2026-03-17
   * @copyright Apache-2.0
   */
  ```
- **函数注释**：必须包含 `@param`, `@return`, `@throws`, `@note`
- **API 文档格式**：Markdown，包含：
  - 功能描述
  - 使用示例（可编译运行的代码片段）
  - 参数表格（类型、名称、描述、默认值）
  - 返回值说明
  - 异常说明
  - 线程安全说明（重要！）

**行为规则**：
- **同步检查**：检测到代码修改（git diff）后，提醒更新对应文档（若已存在）
- **Public API 强制**：所有 public 方法必须有使用示例（不能只有接口定义）
- **多语言支持**：中文为主，关键术语保留英文（如 move semantics, perfect forwarding）

---

## Quick（快速响应 - Fast Responder）

**角色定位**：低延迟响应，处理简单查询、单行补全、语法解释

**模型链**：
1. `bailian-coding-plan/glm-4.7`（202K context，最快响应，成本接近 0）
2. `bailian-coding-plan/qwen3-max-2026-01-23`（备用）
3. `moonshot/kimi-k2.5`（高精度备用，延迟较高）

**触发条件**：
- 单行代码补全（用户输入部分代码，需要完成剩余部分）
- 语法解释（"这个语法是什么意思？"）
- 编译错误快速诊断（单文件错误，不涉及跨模块）
- 简单查询（"这个函数的作用？"）

**约束规则**：
- **禁止跨文件**：如果查询涉及多个文件的依赖关系，必须转交给 Prometheus（拒绝回答并提示"这是一个架构问题，我将为您启动规划流程..."）
- **禁止复杂重构**：如果用户要求"重构这个类"，必须转交给 Atlas（拒绝直接执行）
- **响应时间**：< 2 秒（使用 glm-4.7 确保低延迟）
- **Context 限制**：最多使用 10K tokens 的上下文（避免成本失控）

**典型场景**：
- 用户：`conn->` → Quick 补全为 `conn->sendRequest(body)`
- 用户：`std::move` 是什么意思？ → 快速解释右值引用和移动语义
- 用户：`error: expected ';' after class definition` → 指出缺少分号的位置

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

| 场景 | 策略 | 模型选择 | 预估成本 |
|------|------|---------|---------|
| **快速查询**（< 50K context） | 直接回答，无委派 | Quick（glm-4.7） | ~$0.001 |
| **单文件修改**（50K-100K） | 加载 Skill，单次调用 | Atlas（minimax-m2.5） | ~$0.01-0.02 |
| **中等重构**（100K-200K，3-5 文件） | 并行 Atlas，批量处理 | Atlas（minimax-m2.5）× 3 | ~$0.03-0.05 |
| **复杂分析**（> 200K） | 分片处理，Prometheus 规划 | Prometheus（kimi-k2.5） | ~$0.05-0.10 |
| **深度优化**（模板元编程） | Hephaestus 专注处理 | Hephaestus（qwen3-coder-plus） | ~$0.08-0.15 |

**成本控制规则**：
- 上下文 > 300K 时必须分片（Sisyphus 强制执行）
- 优先使用 MiniMax 进行批量生成（65K output 性价比最高）
- 仅在高风险修改（如多线程代码）时使用 qwen3.5-plus（最强推理）

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
   - 使用 minimax-m2.5 生成修改
   - 每个文件执行 clang-tidy + 编译验证
6. **Atlas** 将 2 个高风险文件委派给 **Hephaestus**（涉及多态删除）
7. **Hephaestus** 详细分析所有权，生成安全重构方案（含自定义删除器）
8. **Explore** 后台验证所有修改后的符号引用完整性
9. **Librarian** 生成变更摘要文档 `docs/migration/modernize_001.md`
10. **Sisyphus** 汇总结果，提示用户审查高风险修改

**总耗时**：~5 分钟（并行加速）  
**总成本**：~$0.08（主要使用 MiniMax）

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

**总耗时**：~2 分钟  
**总成本**：~$0.05（使用 qwen3-coder-plus 深度分析）

## 工作流 3：架构分析（Architecture Analysis）

**用户输入**："分析项目模块依赖，生成架构图"

**执行流程**：
1. **Sisyphus** 识别为架构分析任务，委派 **Prometheus**
2. **Prometheus** 使用 **Explore** 预生成的索引，快速获取依赖关系
3. **Prometheus** 生成 Mermaid 图表保存到 `plans/arch_001.mmd`
4. **Librarian** 读取图表（vision 能力），生成文字版架构文档 `docs/architecture/overview.md`
5. **Sisyphus** 向用户展示图表和文档摘要

**总耗时**：~3 分钟（依赖预生成索引）  
**总成本**：~$0.03（主要使用 Explore 索引，Prometheus 轻量分析）

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
