# HydraForge Session Memory

## 项目信息
- **名称**: HydraForge (原 AgenticDSL)
- **路径**: /workspace/project/HydraForge
- **语言**: C++20
- **构建**: CMake 3.20+
- **测试**: Catch2

## 核心架构
- **引擎**: DSLEngine (src/core/engine.h)
- **解析器**: MarkdownParser → ParsedGraph
- **调度器**: TopoScheduler (DAG 拓扑)
- **执行器**: NodeExecutor
- **LLM**: LlamaAdapter (llama.cpp 封装)
- **工具**: ToolRegistry

## 目录结构
```
src/
├── core/           # types/, engine.h
├── common/         # llm/, tools/, utils/
└── modules/        # parser/, scheduler/, executor/, context/, budget/, trace/, library/, system/
lib/                # DSL 标准库 (.md 文件)
external/           # 第三方依赖
tests/              # Catch2 测试
examples/           # 示例程序
```

## 已知约束
- 禁止 include_directories() 全局包含
- 禁止 link_directories()
- 禁止空 catch 块
- 2 空格缩进，中文注释

## 活跃任务
- (空)

## 技术决策
- (待记录)

## 最后更新
2026-05-13