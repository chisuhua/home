# CppTLM 项目记忆

> **项目**: CppTLM — C++ TLM 混合仿真框架  
> **版本**: v2.0（实施中）  
> **最后更新**: 2026-04-09 22:38  
> **群聊 ID**: `oc_6a048de8c1eecbeb732eab7e98ed8ace`

---

## 📋 项目状态

### 当前阶段
**Phase 1: 构建系统改进**（实施中）

### 已完成决策

| ADR | 议题 | 状态 | 决策 |
|-----|------|------|------|
| **P0** | TransactionContext 设计 | ✅ 已确认 | TLM Extension 存储 |
| **P0** | 传播规则分类 | ✅ 已确认 | 透传/转换/终止 |
| **P0** | 双并行实现模式 | ✅ 已确认 | impl_type per module |
| **P0** | 时间归一化策略 | ✅ 已确认 | 简化版 GVT |
| **P1** | Bundle 共享策略 | ✅ 已确认 | 统一共享 |
| **P1** | 多端口声明方式 | ✅ 已确认 | 数组方式 |
| **P1** | Adapter 泛型设计 | ✅ 已确认 | 混合方案 |
| **P1** | Fragment/Mapper 层 | ✅ 已确认 | 独立 Mapper |
| **P1** | 双并行模式策略 | ✅ 已确认 | v2.1 实现 |
| **X.1** | 事务 ID 分配 | ✅ 已确认 | 上游分配 + 分层 ID |
| **X.2** | 错误处理策略 | ✅ 已确认 | 分层错误码 + DebugTracker |
| **X.3** | 复位策略 | ✅ 已确认 | 层次化复位 + JSON 快照 |
| **X.4** | 插件系统 | ✅ 已确认 | v2.0 静态链接 |
| **X.5** | 构建系统 | ✅ 已确认 | CMake+Ninja+ccache |
| **X.6** | TransactionContext 整合 | ✅ 已确认 | Extension+Packet 共存 |
| **X.7** | 模块/框架职责 | ✅ 已确认 | 声明式虚方法 |
| **X.8** | 分片处理 | ✅ 已确认 | TLM 智能+RTL 透传 |

---

## 📁 架构文档

| 文档 | 位置 | 状态 |
|------|------|------|
| 架构 v2.0 | `docs-pending/02-architecture/01-hybrid-architecture-v2.md` | ✅ 已完成 |
| 交易处理架构 | `docs-pending/02-architecture/02-transaction-architecture.md` | ✅ 已完成 |
| 错误调试架构 | `docs-pending/02-architecture/03-error-debug-architecture.md` | ✅ 已完成 |
| 复位检查点架构 | `docs-pending/02-architecture/04-reset-checkpoint-architecture.md` | ✅ 已完成 |
| 实施计划 | `docs-pending/04-implementation/02-implementation-plan-detailed.md` | ✅ 已完成 |

---

## 🚀 实施计划

### Phase 1: 构建系统改进（✅ 已完成）
- [x] 任务 1.1: CMakeLists.txt 重构
- [x] 任务 1.2: 构建脚本创建
- [x] 任务 1.3: GitHub Actions CI
- [x] 任务 1.4: .clang-format 配置

### Phase 2: 核心基础扩展（下一步）
- [ ] SimObject 扩展（reset/snapshot）
- [ ] Packet 扩展（transaction_id/error_code）
- [ ] ErrorCode 定义

### Phase 3: 交易处理架构
- [ ] TransactionContextExt
- [ ] TransactionTracker

### Phase 4: 错误处理架构
- [ ] ErrorContextExt
- [ ] DebugTracker

### Phase 5: 模块升级
- [ ] CacheV2
- [ ] CrossbarV2
- [ ] MemoryV2

### Phase 6: 测试与示例
- [ ] 单元测试（4 个新测试）
- [ ] 示例程序（2 个）

---

## 📊 现有代码资产

### 可直接复用
- ✅ SimObject 基础（`include/core/sim_object.hh`）
- ✅ Packet 基础（`include/core/packet.hh`）
- ✅ TLM Extension 机制（`include/ext/mem_exts.hh`）
- ✅ 模块实现（14 个模块头文件）
- ✅ Catch2 测试框架（`test/catch_amalgamated.*`）
- ✅ CppHDL 符号链接（`external/CppHDL`）
- ✅ nlohmann/json（`external/json`）

### 需要新建
- `scripts/build.sh`
- `scripts/test.sh`
- `scripts/format.sh`
- `.github/workflows/ci.yml`
- `include/framework/error_category.hh`
- `include/ext/transaction_context_ext.hh`
- `include/framework/transaction_tracker.hh`
- `include/ext/error_context_ext.hh`
- `include/framework/debug_tracker.hh`
- `include/modules/cache_v2.hh`
- `include/modules/crossbar_v2.hh`

### 需要修改
- `CMakeLists.txt`（重构为 CppTLM + ccache）
- `include/core/sim_object.hh`（扩展 reset/snapshot）
- `include/core/packet.hh`（扩展 transaction_id/error_code）
- 模块文件（升级为 V2）

---

## 🔧 构建系统配置

### CMake 选项
```bash
-DUSE_SYSTEMC=ON/OFF    # SystemC 支持（本地头文件）
-DBUILD_TESTS=ON/OFF    # 构建测试
-DBUILD_EXAMPLES=ON/OFF # 构建示例
-DENABLE_COVERAGE=ON/OFF # 覆盖率
```

### 构建命令
```bash
# 标准构建
./scripts/build.sh

# 启用 SystemC
./scripts/build.sh -DUSE_SYSTEMC=ON

# 运行测试
./scripts/test.sh
```

---

## 📝 待办事项

### 当前任务（Phase 1）
1. [ ] 重构 CMakeLists.txt（添加 ccache + 本地 SystemC）
2. [ ] 创建构建脚本（build.sh, test.sh, format.sh）
3. [ ] 创建 GitHub Actions CI 配置

### 等待确认
- 无

### 风险与问题
- 无阻塞项

---

## 📈 进度统计

| 类别 | 总数 | 已完成 | 进行中 | 待开始 | 完成率 |
|------|------|--------|--------|--------|--------|
| **ADR 决策** | 17 | 17 | 0 | 0 | 100% |
| **架构文档** | 4 | 4 | 0 | 0 | 100% |
| **实施阶段** | 6 | 1 | 0 | 5 | 17% |
| **实施任务** | 15 | 4 | 0 | 11 | 27% |

---

**维护**: DevMate  
**最后更新**: 2026-04-09 22:38  
**状态**: Phase 1 实施中
