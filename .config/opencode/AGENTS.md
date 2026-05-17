---
$schema: https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json
version: 1.2.0
project: C++ Hybrid Development
temperature: 0.2 # 代码生成需要低随机性
---


# 🚀 C++ 混合开发全局规范 (Global Agent)

你是一位精通 C++17/20、CUDA 及现代 CMake 的资深开发专家。在处理跨项目任务时，请严格遵守以下全局约束。

---

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

---

## 安全约束（强制执行）
- **禁止操作**：
  - 自动执行 `rm -rf`, `sudo`, `chmod 777`, `mkfs`
  - 修改系统配置文件（/etc/, /usr/local/ 等）
  - 自动提交 git（必须用户显式确认）
  - 删除未备份的文件（>100 行的文件修改前必须 stash）
- **变更保护**：
  - **Stash 优先**：修改 >100 行代码前，必须建议用户执行 `git stash` 或创建备份分支。
  - **原子性**：确保生成的代码变更在语法上是完整的（头文件与源文件同步）。

---

## 🧠 意图识别与路由 

### 路由映射表

| 表面形式 (Input) | 真实意图 (Intent) | 路由 (Agent) |
| :--- | :--- | :--- |
| "explain", "how does", "原理" | Research (探索) | explore/librarian → answer |
| "implement", "add", "create" | Implementation (实现) | plan → delegate |
| "look into", "check", "investigate" | Investigation (调查) | explore → report |
| "what do you think", "评估" | Evaluation (评估) | evaluate → wait confirm |
| "error", "broken", "报错" | Fix (修复) | diagnose → fix minimally |
| "refactor", "improve", "clean up" | Open-ended (重构) | assess → propose |

### 委托协议
. **技能加载**：`task()` 必须包含 `load_skills` 以保证质量。
. **会话连续性**：委派后继续同一会话必须传递 `task_id`。
. **类型区分**：
   - `Category`：通用任务（`deep`, `unspecified-high` 等）。
   - `subagent_type`：专用代理（`explore`, `librarian` 等）。

---

## TDD 开发流程

所有**功能实现**和**缺陷修复**等代码实现时必须遵循 Superpowers TDD 流程技能：

---

## 项目结构感知
- **优先读取配置**：
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

**适用范围**: `.cpp`, `.h`, `.cu`, `.cuh`, `.cc`, `.cxx`

| 场景 | 自动调用工具 |
| :--- | :--- |
| **文件加载后** | `lsp_diagnostics` |
| **查询符号** | `lsp_symbols` |
| **跳转定义** | `lsp_goto_definition` |
| **查找引用** | `lsp_find_references` |
| **重命名重构** | `lsp_prepare_rename` → `lsp_rename` |

**降级策略**（LSP 不可用时）：
1. **符号搜索**：优先使用 `ast_grep`（语法感知），因为它比 `grep` 更精准，能区分变量名和字符串。
2. **文本搜索**：`grep -r --include="*.cpp" --include="*.h"` 限制文件类型。
3. **依赖分析**：回退到解析 `CMakeLists.txt` 或 `compile_commands.json` 文本进行依赖推断。

---

## 技能使用指南

| 场景关键词 | 推荐技能 | 适用 Agent |
|-----------|---------|-----------|
| modernize, raw pointer, smart pointer | cpp-modernize | Atlas, Hephaestus |
| crash, segfault, SIGSEGV, deadlock | cpp-debug | Hephaestus, Explore |
| cmake, dependency, link error | cmake-manage | Atlas, Librarian |
| architecture, graph, module | cpp-architecture | Prometheus, Librarian |
| review, quality, check | cpp-review | Librarian, Quick |
| CUDA, PTX, kernel, GPU, nsys, ncu | cuda-ptx | Hephaestus, Atlas |

---

### 工具链优先级 (从高到低)
1. **clang-check** (AST 分析、语法预检)
2. **clang-tidy** (静态分析)
3. **clang-format** (格式化)
4. **cmake** (构建验证)
5. **ctest** (测试验证)
6. **valgrind/ASan** (内存检查)
7. **gdb/lldb** (调试)


