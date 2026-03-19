---
name: cpp-modernize
description: |-
  将旧版 C++ 代码（C++98/03）现代化到 C++17/20，处理裸指针、NULL、typedef 等。
  使用场景：当代码包含大量 new/delete、NULL 宏、手动循环时。
  示例：
    - 用户："把 src/legacy.cpp 改成现代 C++" → 使用本技能重构
    - 用户："这些原始指针改成智能指针" → 应用 unique_ptr/shared_ptr 转换
license: Apache-2.0
compatibility: Requires clang-tidy, cmake, C++17+ compiler
---

## 执行策略

### Phase 1: 模式识别
扫描目标文件，标记以下模式：
1. **裸指针所有权** → `std::unique_ptr&lt;T&gt;`
2. **NULL 宏** → `nullptr`
3. **typedef** → `using Alias = Original;`

### Phase 2: 安全重构规则
**禁止修改的情况**：
- 涉及多态删除的裸指针（需先分析虚析构函数）
- 暴露给 C API 的指针（extern "C" 边界）

**验证命令**：
```bash
clang-tidy -p build/ src/engine.cpp
cmake --build build/ --target engine_test
./build/engine_test
