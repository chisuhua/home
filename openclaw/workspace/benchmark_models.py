#!/usr/bin/env python3
"""全面基准测试：Bailian 平台所有模型 + 直连 Kimi/MiniMax 对比"""

import json
import time
import urllib.request
import urllib.error
from dataclasses import dataclass, asdict
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

@dataclass
class BenchmarkResult:
    model: str
    provider: str
    status: str
    total_time_ms: float
    ttfb_ms: float
    output_tokens: int
    tokens_per_second: float
    response_text: str

MODELS_TO_TEST = [
    {"provider": "bailian-coding-plan", "model": "qwen3.5-plus", "display": "qwen3.5-plus"},
    {"provider": "bailian-coding-plan", "model": "qwen3-max-2026-01-23", "display": "qwen3-max-2026-01-23"},
    {"provider": "bailian-coding-plan", "model": "qwen3-coder-next", "display": "qwen3-coder-next"},
    {"provider": "bailian-coding-plan", "model": "qwen3-coder-plus", "display": "qwen3-coder-plus"},
    {"provider": "bailian-coding-plan", "model": "minimax-m2.5-alias", "display": "minimax-m2.5-alias (Bailian)"},
    {"provider": "bailian-coding-plan", "model": "glm-5", "display": "glm-5"},
    {"provider": "bailian-coding-plan", "model": "glm-4.7", "display": "glm-4.7"},
    {"provider": "bailian-coding-plan", "model": "kimi-k2.5-bailian", "display": "kimi-k2.5-bailian"},
    {"provider": "moonshot", "model": "kimi-k2.5", "display": "kimi-k2.5 (直连)"},
    {"provider": "minimax", "model": "MiniMax-M2.7", "display": "MiniMax-M2.7 (直连)"},
]

API_KEYS = {
    "bailian-coding-plan": "sk-sp-e0fb34a4c65a429fbd9e5c263a4d6f2e",
    "moonshot": "sk-kimi-O7ogfShgNdDovd6iC0OSUQPIYTuNB6QcYVhBcN4FhrhXBrXBQXn9idtuiKtULnAE",
    "minimax": "sk-cp-9kxXVZxjL8WgTODQD5tbNYgAQdop7_FMDfqQYp59LNMcswWTTa_onzrWykHSD1nUcrVrf8qDtJ4fzOkXYfTcLhJdbySCbM0-pjGmLshKBwuQRh0wUnjoIjw",
}

API_URLS = {
    "bailian-coding-plan": "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1",
    "moonshot": "https://api.moonshot.cn/v1",
    "minimax": "https://api.minimaxi.com/anthropic/v1",
}

TEST_PROMPT = "你好，请用一句话介绍你自己。"

def test_model(model_config: dict) -> BenchmarkResult:
    provider = model_config["provider"]
    model = model_config["model"]
    display = model_config["display"]
    
    api_key = API_KEYS.get(provider)
    base_url = API_URLS.get(provider)
    
    if not api_key or not base_url:
        return BenchmarkResult(display, provider, "error", 0, 0, 0, 0, "未找到 API Key 或 URL")
    
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}
    
    if provider in ["bailian-coding-plan", "minimax"]:
        payload = {"model": model, "messages": [{"role": "user", "content": TEST_PROMPT}], "max_tokens": 1024}
        url = f"{base_url}/messages"
    elif provider == "moonshot":
        payload = {"model": model, "messages": [{"role": "user", "content": TEST_PROMPT}], "max_tokens": 1024}
        url = f"{base_url}/chat/completions"
    else:
        return BenchmarkResult(display, provider, "error", 0, 0, 0, 0, f"未知 provider: {provider}")
    
    start_time = time.time()
    ttfb = None
    
    try:
        req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers=headers, method='POST')
        with urllib.request.urlopen(req, timeout=120) as response:
            ttfb = (time.time() - start_time) * 1000
            data = json.loads(response.read().decode('utf-8'))
        
        total_time = (time.time() - start_time) * 1000
        
        if provider == "moonshot":
            content = data["choices"][0]["message"]["content"]
            output_tokens = data.get("usage", {}).get("completion_tokens", 0)
        else:
            content = data.get("content", [{}])[0].get("text", "") if data.get("content") else ""
            output_tokens = data.get("usage", {}).get("output_tokens", 0)
        
        tokens_per_second = (output_tokens / total_time * 1000) if total_time > 0 else 0
        
        return BenchmarkResult(
            display, provider, "success", round(total_time, 2), round(ttfb, 2),
            output_tokens, round(tokens_per_second, 2),
            content[:100] + "..." if len(content) > 100 else content
        )
    except Exception as e:
        total_time = (time.time() - start_time) * 1000
        return BenchmarkResult(display, provider, "error", round(total_time, 2), round(ttfb, 2) if ttfb else 0, 0, 0, str(e))

def run_benchmark():
    print("=" * 80)
    print("全面基准测试：Bailian 平台所有模型 + 直连 Kimi/MiniMax 对比")
    print("测试时间:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("=" * 80)
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(test_model, model) for model in MODELS_TO_TEST]
        results = [f.result() for f in as_completed(futures)]
    
    results_ordered = []
    for model_config in MODELS_TO_TEST:
        for r in results:
            if r.model == model_config["display"]:
                results_ordered.append(r)
                break
    
    results_list = [asdict(r) for r in results_ordered]
    output_file = f"benchmark_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(results_list, f, ensure_ascii=False, indent=2)
    
    print(f"\n原始数据已保存：{output_file}\n")
    print("=" * 120)
    print(f"{'模型':<35} {'状态':<8} {'总时间 (ms)':<12} {'TTFB(ms)':<10} {'输出 Token':<10} {'速度 (t/s)':<10}")
    print("=" * 120)
    
    for r in results_ordered:
        status = "✅" if r.status == "success" else "❌"
        print(f"{r.model:<35} {status:<8} {r.total_time_ms:<12.2f} {r.ttfb_ms:<10.2f} {r.output_tokens:<10} {r.tokens_per_second:<10.2f}")
    
    print("=" * 120)
    
    success_results = [r for r in results_ordered if r.status == "success"]
    
    print("\n\n📊 Bailian 代理 vs 直连 对比分析")
    print("=" * 80)
    
    kimi_bailian = next((r for r in results_ordered if r.model == "kimi-k2.5-bailian"), None)
    kimi_direct = next((r for r in results_ordered if r.model == "kimi-k2.5 (直连)"), None)
    minimax_bailian = next((r for r in results_ordered if "minimax-m2.5-alias" in r.model), None)
    minimax_direct = next((r for r in results_ordered if "MiniMax-M2.7" in r.model), None)
    
    if kimi_bailian and kimi_direct:
        print("\nKimi K2.5 对比:")
        print(f"  Bailian 代理：{kimi_bailian.ttfb_ms:.2f}ms (TTFB) | {kimi_bailian.total_time_ms:.2f}ms (总计)")
        print(f"  直连 Moonshot: {kimi_direct.ttfb_ms:.2f}ms (TTFB) | {kimi_direct.total_time_ms:.2f}ms (总计)")
        if kimi_bailian.total_time_ms > 0:
            speed = ((kimi_bailian.total_time_ms - kimi_direct.total_time_ms) / kimi_bailian.total_time_ms * 100)
            print(f"  {'直连更快' if speed > 0 else 'Bailian 更快'}: {abs(speed):.1f}%")
    
    if minimax_bailian and minimax_direct:
        print("\nMiniMax 对比:")
        print(f"  Bailian 代理 (M2.5): {minimax_bailian.ttfb_ms:.2f}ms | {minimax_bailian.total_time_ms:.2f}ms")
        print(f"  直连 (M2.7): {minimax_direct.ttfb_ms:.2f}ms | {minimax_direct.total_time_ms:.2f}ms")
        print("  注意：模型版本不同 (M2.5 vs M2.7)")
    
    if success_results:
        print("\n\n🏆 按场景推荐的模型排名")
        print("=" * 80)
        
        print("\n⚡ 低延迟场景（TTFB 最低）")
        for i, r in enumerate(sorted(success_results, key=lambda x: x.ttfb_ms)[:5], 1):
            print(f"  {i}. {r.model}: {r.ttfb_ms:.2f}ms")
        
        print("\n📈 高吞吐场景（生成速度最快）")
        for i, r in enumerate(sorted(success_results, key=lambda x: x.tokens_per_second, reverse=True)[:5], 1):
            print(f"  {i}. {r.model}: {r.tokens_per_second:.2f} tokens/s")
        
        print("\n🎯 综合推荐（性价比平衡）")
        scored = []
        for r in success_results:
            if r.ttfb_ms > 0 and r.tokens_per_second > 0:
                score = (1000 / r.ttfb_ms) * 0.4 + r.tokens_per_second * 0.4 + 20
                scored.append((r, score))
        scored.sort(key=lambda x: x[1], reverse=True)
        for i, (r, score) in enumerate(scored[:5], 1):
            print(f"  {i}. {r.model}: {score:.2f}分")
    
    print("\n\n📋 opencode.json 优化建议")
    print("=" * 80)
    
    fastest = min(success_results, key=lambda x: x.ttfb_ms) if success_results else None
    highest_tp = max(success_results, key=lambda x: x.tokens_per_second) if success_results else None
    
    print("\n基于测试结果，建议调整以下 Agent 的 provider_chain:")
    print(f"  - quick（快速响应）: 优先使用 {fastest.model if fastest else 'glm-4.7'}")
    print(f"  - atlas/hephaestus（批量生成）: 优先使用 {highest_tp.model if highest_tp else 'MiniMax-M2.7'}")
    print(f"  - sisyphus（复杂决策）: 保持 qwen3.5-plus")
    
    if kimi_bailian and kimi_direct and kimi_direct.total_time_ms < kimi_bailian.total_time_ms:
        spd = ((kimi_bailian.total_time_ms - kimi_direct.total_time_ms) / kimi_bailian.total_time_ms * 100)
        print(f"\n💡 Moonshot 直连比 Bailian 代理快 {spd:.1f}% -> 建议 Kimi 使用直连")
    
    if minimax_direct and minimax_bailian and minimax_direct.total_time_ms < minimax_bailian.total_time_ms:
        spd = ((minimax_bailian.total_time_ms - minimax_direct.total_time_ms) / minimax_bailian.total_time_ms * 100)
        print(f"\n💡 MiniMax 直连比 Bailian 代理快 {spd:.1f}% -> 建议 MiniMax 使用直连")
    
    print("\n" + "=" * 80)
    print("测试完成!")
    return results_list

if __name__ == "__main__":
    run_benchmark()
