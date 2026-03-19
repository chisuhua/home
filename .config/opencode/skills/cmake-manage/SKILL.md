---
name: "cmake-manage"
description: "管理 CMake 构建系统，处理依赖、预设和跨平台配置"
when_to_use: |
  当用户涉及以下操作时触发：
  - "CMakeLists.txt", "add_executable", "target_link_libraries"
  - "找不到头文件", "link error", "undefined reference"
  - "加第三方库", "vcpkg", "conan"
  - "预设", "preset", "Debug/Release 配置"
  - 跨平台构建（Windows/Linux/macOS）
---

## 核心能力

### 1. 依赖管理
**现代 CMake 方式（推荐）**:
```cmake
# 使用 FetchContent（无需外部包管理器）
include(FetchContent)
FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
  GIT_TAG        10.1.1
)
FetchContent_MakeAvailable(fmt)
target_link_libraries(myapp PRIVATE fmt::fmt)
