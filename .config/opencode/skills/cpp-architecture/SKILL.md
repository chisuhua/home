---
name: "cpp-architecture"
description: "分析 C++ 项目架构依赖和模块边界"
when_to_use: "当用户询问'这个类在哪里被使用'、'模块依赖'、'架构图'时"
---

## 工具使用
- 使用 `clang-check` 生成 AST
- 使用 `cmake --build` 验证修改后编译
- 生成 Mermaid 依赖图
