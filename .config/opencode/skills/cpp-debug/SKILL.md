---
name: "cpp-debug"
description: "C++ 运行时故障排查（崩溃、死锁、内存泄漏）"
when_to_use: |
  当用户遇到以下问题时触发：
  - "segmentation fault", "segfault", "崩溃了"
  - "死锁", "卡住不动", "hang"
  - "内存泄漏", "valgrind", "asan"
  - "core dumped", "SIGSEGV"
  - 编译成功但运行失败
skills_required: ["cpp-modernize"]  # 如果修复涉及指针修改，依赖 modernize
---

## 诊断流程

### 步骤 1: 信息收集
1. 请求用户提供（若未提供）：
   - 崩溃时的堆栈跟踪（`bt` 或 `addr2line` 输出）
   - 触发问题的输入数据或操作序列
   - 是否启用了编译优化（-O2/-O3 会影响调试）

2. 本地分析：
   - 检查 `build/` 目录是否存在 `compile_commands.json`
   - 查看最近的 git diff（确认是否因近期修改引入）

### 步骤 2: 分类诊断

**Case A: 段错误 (SIGSEGV)**
- 检查空指针解引用
- 检查迭代器失效（vector 扩容后）
- 检查 dangling pointer（返回局部变量引用）

**Case B: 死锁**
- 检查 `std::lock_guard` 顺序是否一致
- 检查递归锁（`std::recursive_mutex` 需求）
- 检查条件变量等待条件是否可达

**Case C: 内存泄漏**
- 建议运行：`valgrind --leak-check=full ./program`
- 或 AddressSanitizer: 编译时添加 `-fsanitize=address`

### 步骤 3: CppHDL 特定问题

**CppHDL ch_module 生命周期错误**

若遇到以下错误或现象，可能是 `ch_module` 使用不当：
- `"Child component has been destroyed unexpectedly in io()!"`
- `"Error: No active parent Component found when creating ch_module!"`
- `sim.tick()` 挂起或 SIGSEGV

**诊断步骤**：
1. 检查 `ch_module` 是否在 `Component::describe()` 内部调用
2. 确认不是在 TEST_CASE 或 main() 中直接调用
3. 测试嵌套组件（Pipeline + ITCM + DTCM）需要 PipelineTop 包装

**正确模式**：
```cpp
// ✅ ch_device 用于测试
TEST_CASE("test", "[unit]") {
    ch::ch_device<MyTop> top;
    Simulator sim(top.context());
    sim.tick();
}

// ✅ ch_module 用于组件内部
class MyTop : public ch::Component {
    void describe() override {
        ch::ch_module<Child> child{"child"};
    }
};
```

### 步骤 4: 修复与验证
- 生成最小可复现测试用例
- 应用修复后，必须在 valgrind/ASan 下零错误
- 对于并发问题，建议使用 ThreadSanitizer (`-fsanitize=thread`)

## 工具链配置
- **调试器**: gdb 或 lldb
- **内存检查**: valgrind, AddressSanitizer (ASan)
- **线程检查**: ThreadSanitizer (TSan)
- **静态分析**: clang-static-analyzer
