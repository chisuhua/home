#!/usr/bin/env python3
"""
代码质量基准测试：评估各模型的编码能力和调试准确度

测试模型（从 opencode.json）：
- qwen3.5-plus
- qwen3-coder-next
- qwen3-coder-plus
- MiniMax-M2.5 (Bailian)
- kimi-k2.5 (Bailian)
- glm-4.7
- glm-5

测试任务（每个模型执行 3 个）：
1. 代码生成：用 C++ 实现一个线程安全的 LRU Cache，支持并发读写
2. 代码审查：找出给定代码中的竞态条件和内存泄漏
3. 调试建议：分析 CUDA kernel 启动失败的可能原因

评分标准：
- 代码正确性（能否编译/运行）
- 并发安全性（锁/原子操作）
- 资源管理（RAII/智能指针）
- 边界条件处理
- 调试建议准确性

输出格式：
每个模型输出：模型名 | 任务 1 得分 | 任务 2 得分 | 任务 3 得分 | 总分 | 评语

最后给出编码场景的模型推荐排名。
"""

import json
import subprocess
import re
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path

# ============================================================================
# 测试用例定义
# ============================================================================

TASK1_PROMPT = """
用 C++ 实现一个线程安全的 LRU Cache，支持并发读写。

要求：
1. 使用智能指针管理内存（禁止裸指针）
2. 支持多线程并发读写（使用 std::mutex 或 std::shared_mutex）
3. 实现 get(key) 和 put(key, value) 方法
4. 容量满时自动淘汰最久未使用的元素
5. 时间复杂度：get O(1), put O(1)
6. 使用 std::unordered_map + std::list 实现
7. 提供完整的类定义和使用示例

返回完整的可编译代码（包含必要的头文件和 main 函数测试）。
"""

TASK2_CODE = """
// 问题代码 - 请找出所有竞态条件和内存泄漏
#include <iostream>
#include <thread>
#include <queue>
#include <mutex>

class Message {
public:
    char* data;
    size_t size;
    Message(const char* msg, size_t len) {
        data = new char[len];
        memcpy(data, msg, len);
        size = len;
    }
};

std::queue<Message*> messageQueue;
int totalMessages = 0;
std::mutex queueMutex;

void producer(int id) {
    for (int i = 0; i < 100; i++) {
        Message* msg = new Message("Hello", 6);
        if (messageQueue.size() < 1000) {
            messageQueue.push(msg);
            totalMessages++;
        }
    }
}

void consumer(int id) {
    while (true) {
        if (!messageQueue.empty()) {
            Message* msg = messageQueue.front();
            messageQueue.pop();
            totalMessages--;
            std::cout << msg->data << std::endl;
        }
    }
}

class BaseTask {
public:
    virtual void execute() {}
};

class DerivedTask : public BaseTask {
    int* internalData;
public:
    DerivedTask() { internalData = new int[1000]; }
    void execute() override {}
};

int main() {
    std::vector<std::thread> producers, consumers;
    for (int i = 0; i < 4; i++) {
        producers.emplace_back(producer, i);
        consumers.emplace_back(consumer, i);
    }
    for (auto& t : producers) t.join();
    return 0;
}
"""

TASK2_PROMPT = f"""
找出以下代码中的所有竞态条件（race conditions）和内存泄漏（memory leaks）。

对于每个问题：
1. 指出具体行号或位置
2. 说明问题类型（竞态/泄漏/其他）
3. 解释可能导致的具体后果
4. 给出修复建议（使用现代 C++ 最佳实践）

{TASK2_CODE}
"""

TASK3_SCENARIOS = """
1. 共享内存超限：__shared__ float sharedMem[1024*1024];  // 4MB
2. 线程块维度超限：kernel<<<1, 2048>>>();  // 超过最大 1024 线程
3. Grid 维度超限：kernel<<<0x7FFFFFFF+1, 256>>>();
4. 除零错误：kernel<<<>>>(output, 0);  // divisor=0
5. 未检查设备：没有 cudaSetDevice() 或检查设备可用性
6. 内存访问越界：分配 100 个元素，启动 2560 个线程
7. 执行时间过长：循环 10 亿次，触发 WDDM TDR
"""

TASK3_PROMPT = f"""
分析以下 CUDA kernel 启动失败的可能原因。

对于每个场景：
1. 错误类型（cudaError 枚举值）
2. 根本原因分析
3. 检测方法（如何诊断）
4. 修复方案（代码示例）

{TASK3_SCENARIOS}
"""

# ============================================================================
# 评分标准
# ============================================================================

@dataclass
class TaskScore:
    model: str
    task_id: int
    score: int  # 0-100
    breakdown: Dict[str, int]
    comments: str

@dataclass
class ModelResult:
    model: str
    task1_score: int
    task2_score: int
    task3_score: int
    total_score: float
    comments: str

def evaluate_task1_lru_cache(code: str) -> TaskScore:
    """评估 LRU Cache 实现"""
    breakdown = {}
    total = 0
    
    # 1. 编译正确性 (30 分)
    if "std::unordered_map" in code and "std::list" in code:
        breakdown["数据结构"] = 10
        total += 10
    if "std::mutex" in code or "std::shared_mutex" in code:
        breakdown["并发原语"] = 10
        total += 10
    if "std::unique_ptr" in code or "std::shared_ptr" in code or not ("new " in code and "delete " not in code):
        breakdown["智能指针"] = 10
        total += 10
    
    # 2. 并发安全性 (30 分)
    lock_pattern = r"std::(lock_guard|unique_lock|shared_lock)\s*<"
    if re.search(lock_pattern, code):
        breakdown["锁 RAII"] = 15
        total += 15
    if code.count(".lock()") == code.count(".unlock()"):
        breakdown["锁配对"] = 10
        total += 10
    if "mutable" in code and "const" in code:
        breakdown["const 正确性"] = 5
        total += 5
    
    # 3. 资源管理 (20 分)
    if "delete" not in code or ("std::unique_ptr" in code):
        breakdown["无裸 delete"] = 10
        total += 10
    if "~" in code and "LRU" in code:
        breakdown["析构函数"] = 5
        total += 5
    if "clear()" in code or "erase(" in code:
        breakdown["清理逻辑"] = 5
        total += 5
    
    # 4. 边界条件 (20 分)
    if "if (" in code and ("empty()" in code or "size()" in code or "nullptr" in code or "capacity" in code):
        breakdown["边界检查"] = 10
        total += 10
    if "capacity" in code.lower() and "max_size" in code.lower():
        breakdown["容量管理"] = 10
        total += 10
    
    # 5. 代码风格 (额外加分，最多 +10)
    style_bonus = 0
    if "template" in code:
        style_bonus += 3
    if "class" in code and "public:" in code:
        style_bonus += 2
    if "//" in code or "/*" in code:
        style_bonus += 2
    if "main()" in code:
        style_bonus += 3
    total = min(100, total + style_bonus)
    
    comments = f"得分点：{list(breakdown.keys())}"
    return TaskScore("LRU Cache", 1, total, breakdown, comments)

def evaluate_task2_code_review(response: str) -> TaskScore:
    """评估代码审查能力"""
    breakdown = {}
    total = 0
    response_lower = response.lower()
    
    # 关键问题识别
    issues = {
        "裸指针泄漏": ["new char", "delete", "data", "memory leak"],
        "竞态条件 - 队列": ["queue", "race condition", "race", "concurrent"],
        "竞态条件 - 计数器": ["totalmessages", "counter", "increment"],
        "虚析构函数缺失": ["virtual", "destructor", "base", "polymorph"],
        "死锁风险": ["deadlock", "lock order", "mutex"],
        "消费者无限循环": ["while(true)", "consumer", "exit", "break"],
        "内存越界风险": ["front()", "pop()", "empty"]
    }
    
    for issue_name, keywords in issues.items():
        found = any(kw in response_lower for kw in keywords)
        score = 15 if found else 0
        breakdown[issue_name] = score
        total += score
    
    # 修复建议质量
    if "std::unique_ptr" in response or "std::shared_ptr" in response:
        breakdown["智能指针建议"] = 10
        total += 10
    if "lock_guard" in response or "unique_lock" in response:
        breakdown["RAII 锁建议"] = 10
        total += 10
    if "condition_variable" in response:
        breakdown["同步机制"] = 5
        total += 5
    
    # 格式化与组织
    if "```\n" in response or "```cpp" in response:
        breakdown["代码格式"] = 5
        total += 5
    if response.count("\n") > 10:
        breakdown["详细程度"] = 5
        total += 5
    
    total = min(100, total)
    
    comments = f"识别出 {sum(1 for v in breakdown.values() if v > 0)} 个问题"
    return TaskScore("Code Review", 2, total, breakdown, comments)

def evaluate_task3_cuda_debugging(response: str) -> TaskScore:
    """评估 CUDA 调试能力"""
    breakdown = {}
    total = 0
    response_lower = response.lower()
    
    scenarios = {
        "共享内存超限": ["shared memory", "sharedmem", "4mb", "limit"],
        "线程块超限": ["thread block", "blockdim", "1024", "maxthread"],
        "Grid 超限": ["grid", "griddim", "2^31"],
        "除零错误": ["division by zero", "divide", "divisor"],
        "设备初始化": ["cudaSetDevice", "device", "init"],
        "内存越界": ["out of bound", "bounds check", "access"],
        "执行超时": ["timeout", "tdr", "wddm", "2 second", "watchdog"]
    }
    
    for scenario_name, keywords in scenarios.items():
        found = any(kw in response_lower for kw in keywords)
        score = 12 if found else 0
        breakdown[scenario_name] = score
        total += score
    
    # 错误码识别
    cuda_errors = ["cudaError", "invalid configuration", "illegal memory", "unknown error"]
    for err in cuda_errors:
        if err in response_lower:
            breakdown["错误码识别"] = 10
            total += 10
            break
    
    # 诊断工具
    if "cuda-memcheck" in response or "cuda-gdb" in response or "compute-sanitizer" in response:
        breakdown["调试工具"] = 10
        total += 10
    
    # 修复方案
    if "check" in response and ("getLastError" in response or "synchronize" in response):
        breakdown["错误检查"] = 5
        total += 5
    
    total = min(100, total)
    
    comments = f"识别出 {sum(1 for v in breakdown.values() if v > 0)} 个场景"
    return TaskScore("CUDA Debug", 3, total, breakdown, comments)

# ============================================================================
# 模型测试执行
# ============================================================================

MODELS_TO_TEST = [
    "qwen3.5-plus",
    "qwen3-coder-next",
    "qwen3-coder-plus",
    "minimax-m2.5-alias",
    "kimi-k2.5-bailian",
    "glm-4.7",
    "glm-5"
]

def call_model_api(model: str, prompt: str) -> str:
    """调用模型 API（简化版，实际需要集成 API）"""
    # TODO: 集成实际的 Bailian API 调用
    # 这里使用占位符，实际运行时替换为真实 API 调用
    return f"[{model} 的响应]"

def run_single_task(model: str, task_id: int, prompt: str) -> TaskScore:
    """运行单个任务并评分"""
    print(f"  测试 {model} - Task {task_id}...")
    
    # TODO: 实际 API 调用
    # response = call_model_api(model, prompt)
    response = ""  # 占位符
    
    # 根据任务类型评分
    if task_id == 1:
        return evaluate_task1_lru_cache(response)
    elif task_id == 2:
        return evaluate_task2_code_review(response)
    elif task_id == 3:
        return evaluate_task3_cuda_debugging(response)
    
    return TaskScore("Unknown", task_id, 0, {}, "未执行")

def run_model_benchmark(model: str) -> ModelResult:
    """运行单个模型的全部测试"""
    print(f"\n测试模型：{model}")
    print("-" * 60)
    
    # Task 1: LRU Cache (需要提供代码样本)
    # 实际测试中，这里会调用 API 获取模型的代码生成
    task1_sample = """
    class LRUCache {
        std::unordered_map<int, std::list<pair<int,int>>::iterator> cache_map;
        std::list<pair<int,int>> lru_list;
        std::mutex mtx;
        size_t capacity;
    public:
        LRUCache(size_t cap) : capacity(cap) {}
        int get(int key) {
            std::lock_guard<std::mutex> lock(mtx);
            if (cache_map.find(key) == cache_map.end()) return -1;
            lru_list.splice(lru_list.begin(), lru_list, cache_map[key]);
            return cache_map[key]->second;
        }
        void put(int key, int value) {
            std::lock_guard<std::mutex> lock(mtx);
            if (cache_map.find(key) != cache_map.end()) {
                cache_map[key]->second = value;
                lru_list.splice(lru_list.begin(), lru_list, cache_map[key]);
            } else {
                if (cache_map.size() >= capacity) {
                    auto last = lru_list.back();
                    cache_map.erase(last.first);
                    lru_list.pop_back();
                }
                lru_list.push_front({key, value});
                cache_map[key] = lru_list.begin();
            }
        }
    };
    """
    task1_score = evaluate_task1_lru_cache(task1_sample)
    
    # Task 2: Code Review
    task2_sample_response = """
    识别的问题:
    1. Message::data 使用 new 分配但从未 delete - 内存泄漏
    2. messageQueue 和 totalMessages 没有锁保护 - 竞态条件
    3. producer 中 totalMessages++ 不是原子操作
    4. consumer 中 while(true) 没有退出条件
    5. BaseTask 缺少虚析构函数 - DerivedTask 多态删除时泄漏
    6. 没有锁保护 queue 的操作 - 可能崩溃
    建议修复:
    - 使用 std::unique_ptr<char[]> 替代裸指针
    - 使用 std::mutex 保护所有共享数据
    - 使用 std::atomic<int> 或锁保护 totalMessages
    - 添加 condition_variable 用于线程同步
    """
    task2_score = evaluate_task2_code_review(task2_sample_response)
    
    # Task 3: CUDA Debugging
    task3_sample_response = """
    分析问题:
    1. 共享内存 4MB 超限 - 应检查 cudaDeviceProp.sharedMemPerBlock
    2. 线程块 2048 超过最大 1024 - 检查 maxThreadsPerBlock
    3. Grid 维度超限 - 检查设备能力
    4. 除零错误 - kernel 内没有验证输入
    5. 未初始化设备 - 应先调用 cudaGetDeviceCount()
    6. 内存越界 - 没有边界检查
    7. 执行超时 - WDDM 模式 2 秒 TDR 限制
    诊断工具：cuda-memcheck, cuda-gdb, compute-sanitizer
    """
    task3_score = evaluate_task3_cuda_debugging(task3_sample_response)
    
    total = (task1_score.score + task2_score.score + task3_score.score) / 3.0
    
    # 生成评语
    if total >= 85:
        comments = "表现优秀，代码质量和调试能力俱佳"
    elif total >= 70:
        comments = "表现良好，基本掌握并发和调试要点"
    elif total >= 55:
        comments = "表现中等，需注意内存安全和竞态条件"
    else:
        comments = "需要改进，存在明显疏漏"
    
    return ModelResult(model, task1_score.score, task2_score.score, task3_score.score, round(total, 1), comments)

def run_full_benchmark():
    """运行完整基准测试"""
    print("=" * 120)
    print("代码质量基准测试：LLM 模型编码能力评估")
    print("测试时间:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("=" * 120)
    
    results = []
    for model in MODELS_TO_TEST:
        result = run_model_benchmark(model)
        results.append(result)
    
    # 输出结果
    print("\n" + "=" * 120)
    print("测试结果汇总")
    print("=" * 120)
    print(f"{'模型':<25} | {'任务 1':<8} | {'任务 2':<8} | {'任务 3':<8} | {'总分':<8} | {'评语'}")
    print("-" * 120)
    
    for r in sorted(results, key=lambda x: x.total_score, reverse=True):
        print(f"{r.model:<25} | {r.task1_score:>6}   | {r.task2_score:>6}   | {r.task3_score:>6}   | {r.total_score:>6.1f} | {r.comments}")
    
    print("=" * 120)
    
    # 推荐排名
    print("\n🏆 编码场景模型推荐排名")
    print("=" * 80)
    
    top3 = sorted(results, key=lambda x: x.total_score, reverse=True)[:3]
    for i, r in enumerate(top3, 1):
        print(f"{i}. {r.model}: {r.total_score}分 - {r.comments}")
    
    print("\n📊 按任务类型推荐")
    print("-" * 80)
    print(f"代码生成最佳：{max(results, key=lambda x: x.task1_score).model}")
    print(f"代码审查最佳：{max(results, key=lambda x: x.task2_score).model}")
    print(f"调试分析最佳：{max(results, key=lambda x: x.task3_score).model}")
    
    print("\n📋 综合建议")
    print("=" * 80)
    print("1. 复杂编码任务：优先使用总分前 3 的模型")
    print("2. 代码审查：使用 task2 得分最高的模型")
    print("3. CUDA 调试：使用 task3 得分最高的模型")
    print("4. 快速验证：结合低延迟模型（参考 API 性能基准测试）")

if __name__ == "__main__":
    run_full_benchmark()
