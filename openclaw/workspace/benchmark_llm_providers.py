#!/usr/bin/env python3
"""
LLM Provider Benchmark Test
比较 Kimi、MiniMax、Bailian 三个模型的 API 响应速度
"""

import subprocess
import json
import time
import re
import sys
from dataclasses import dataclass
from typing import Optional

@dataclass
class BenchmarkResult:
    provider: str
    model: str
    dns_time: Optional[float] = None
    tcp_time: Optional[float] = None
    tls_time: Optional[float] = None
    ttfb: Optional[float] = None
    total_time: Optional[float] = None
    tokens_per_sec: Optional[float] = None
    total_tokens: int = 0
    error: Optional[str] = None

def run_curl_benchmark(url: str, data: dict, headers: dict, timeout: int = 120) -> tuple[str, dict]:
    time_format = "%{time_namelookup} %{time_connect} %{time_appconnect} %{time_pretransfer} %{time_starttransfer} %{time_total}"
    
    cmd = [
        "curl", "-s", "-o", "/dev/stdout",
        "-w", f"\n\n__TIMES__:{time_format}",
        "-X", "POST",
        "-H", "Content-Type: application/json",
    ]
    
    for key, value in headers.items():
        cmd.extend(["-H", f"{key}: {value}"])
    
    cmd.extend([
        "-d", json.dumps(data),
        "--max-time", str(timeout),
        url
    ])
    
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout + 10)
    
    if result.returncode != 0:
        raise Exception(f"curl failed: {result.stderr}")
    
    parts = result.stdout.split("\n\n__TIMES__:")
    if len(parts) != 2:
        raise Exception(f"Failed to parse curl output: {result.stdout[:500]}")
    
    response_body = parts[0]
    time_str = parts[1].strip()
    
    times = list(map(float, time_str.split()))
    time_dict = {
        "dns": times[0],
        "tcp": times[1] - times[0],
        "tls": times[2] - times[1],
        "ttfb": times[4],
        "total": times[5],
    }
    
    return response_body, time_dict


def test_kimi(api_key: str, prompt: str = "Hello") -> BenchmarkResult:
    url = "https://api.moonshot.cn/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
    }
    data = {
        "model": "kimi-k2.5",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 100,
        "temperature": 0.3,
        "stream": False
    }
    
    try:
        start = time.time()
        response, times = run_curl_benchmark(url, data, headers)
        
        resp_json = json.loads(response)
        usage = resp_json.get("usage", {})
        total_tokens = usage.get("total_tokens", 0)
        
        tokens_per_sec = total_tokens / times["total"] if times["total"] > 0 else 0
        
        return BenchmarkResult(
            provider="Kimi (Moonshot)",
            model="kimi-k2.5",
            dns_time=times["dns"],
            tcp_time=times["tcp"],
            tls_time=times["tls"],
            ttfb=times["ttfb"],
            total_time=times["total"],
            tokens_per_sec=tokens_per_sec,
            total_tokens=total_tokens
        )
    except Exception as e:
        return BenchmarkResult(
            provider="Kimi (Moonshot)",
            model="kimi-k2.5",
            error=str(e)
        )


def test_minimax(api_key: str, prompt: str = "Hello") -> BenchmarkResult:
    url = "https://api.minimaxi.com/anthropic/v1/messages"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "anthropic-version": "2023-06-01",
    }
    data = {
        "model": "MiniMax-M2.7",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 100,
        "temperature": 0.3,
        "stream": False
    }
    
    try:
        response, times = run_curl_benchmark(url, data, headers)
        
        resp_json = json.loads(response)
        usage = resp_json.get("usage", {})
        output_tokens = usage.get("output_tokens", 0)
        input_tokens = usage.get("input_tokens", 0)
        total_tokens = output_tokens + input_tokens
        
        tokens_per_sec = output_tokens / times["total"] if times["total"] > 0 else 0
        
        return BenchmarkResult(
            provider="MiniMax",
            model="MiniMax-M2.7",
            dns_time=times["dns"],
            tcp_time=times["tcp"],
            tls_time=times["tls"],
            ttfb=times["ttfb"],
            total_time=times["total"],
            tokens_per_sec=tokens_per_sec,
            total_tokens=total_tokens
        )
    except Exception as e:
        return BenchmarkResult(
            provider="MiniMax",
            model="MiniMax-M2.7",
            error=str(e)
        )


def test_bailian(api_key: str, prompt: str = "Hello") -> BenchmarkResult:
    url = "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1/messages"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "anthropic-version": "2023-06-01",
        "X-DashScope-Thinking": "false",
    }
    data = {
        "model": "qwen3.5-plus",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 100,
        "temperature": 0.3,
        "stream": False
    }
    
    try:
        response, times = run_curl_benchmark(url, data, headers)
        
        resp_json = json.loads(response)
        usage = resp_json.get("usage", {})
        output_tokens = usage.get("output_tokens", 0)
        input_tokens = usage.get("input_tokens", 0)
        total_tokens = output_tokens + input_tokens
        
        tokens_per_sec = output_tokens / times["total"] if times["total"] > 0 else 0
        
        return BenchmarkResult(
            provider="Bailian (阿里云)",
            model="qwen3.5-plus",
            dns_time=times["dns"],
            tcp_time=times["tcp"],
            tls_time=times["tls"],
            ttfb=times["ttfb"],
            total_time=times["total"],
            tokens_per_sec=tokens_per_sec,
            total_tokens=total_tokens
        )
    except Exception as e:
        return BenchmarkResult(
            provider="Bailian (阿里云)",
            model="qwen3.5-plus",
            error=str(e)
        )


def format_table(results: list[BenchmarkResult]) -> str:
    header = "| 服务商 | 模型 | DNS(ms) | TCP(ms) | TLS(ms) | TTFB(ms) | 总时间 (ms) | Tokens | Tokens/秒 |"
    separator = "|--------|--------|---------|---------|---------|----------|-------------|--------|-----------|"
    
    lines = [header, separator]
    
    for r in results:
        if r.error:
            lines.append(f"| {r.provider} | {r.model} | ❌ 错误 | - | - | - | - | - | - |")
            lines.append(f"|   └─ 错误信息：{r.error}")
        else:
            lines.append(
                f"| {r.provider} | {r.model} | "
                f"{r.dns_time*1000:.1f} | {r.tcp_time*1000:.1f} | {r.tls_time*1000:.1f} | "
                f"{r.ttfb*1000:.1f} | {r.total_time*1000:.1f} | {r.total_tokens} | {r.tokens_per_sec:.1f} |"
            )
    
    return "\n".join(lines)


def format_conclusion(results: list[BenchmarkResult]) -> str:
    valid_results = [r for r in results if not r.error]
    
    if len(valid_results) < 2:
        return "⚠️ 测试数据不足，无法生成结论"
    
    conclusions = []
    
    fastest = min(valid_results, key=lambda x: x.total_time)
    conclusions.append(f"🏆 **最快总响应时间**: {fastest.provider} ({fastest.total_time*1000:.1f}ms)")
    
    lowest_ttfb = min(valid_results, key=lambda x: x.ttfb)
    conclusions.append(f"⚡ **最低延迟 (TTFB)**: {lowest_ttfb.provider} ({lowest_ttfb.ttfb*1000:.1f}ms)")
    
    fastest_gen = max(valid_results, key=lambda x: x.tokens_per_sec or 0)
    conclusions.append(f"🚀 **最快 Token 生成**: {fastest_gen.provider} ({fastest_gen.tokens_per_sec:.1f} tokens/s)")
    
    ranking = sorted(valid_results, key=lambda x: x.total_time)
    ranking_str = " | ".join([f"{i+1}. {r.provider}" for i, r in enumerate(ranking)])
    conclusions.append(f"\n📊 **综合排名**: {ranking_str}")
    
    return "\n".join(conclusions)


def main():
    KIMI_KEY = "sk-kimi-O7ogfShgNdDovd6iC0OSUQPIYTuNB6QcYVhBcN4FhrhXBrXBQXn9idtuiKtULnAE"
    MINIMAX_KEY = "sk-cp-9kxXVZxjL8WgTODQD5tbNYgAQdop7_FMDfqQYp59LNMcswWTTa_onzrWykHSD1nUcrVrf8qDtJ4fzOkXYfTcLhJdbySCbM0-pjGmLshKBwuQRh0wUnjoIjw"
    BAILIAN_KEY = "sk-sp-e0fb34a4c65a429fbd9e5c263a4d6f2e"
    
    prompt = "你好，请用一句话介绍你自己。"
    
    print("=" * 60)
    print("LLM Provider Benchmark Test")
    print("=" * 60)
    print(f"测试提示词：{prompt}")
    print()
    
    results = []
    
    print("正在测试 Kimi...")
    kimi_result = test_kimi(KIMI_KEY, prompt)
    results.append(kimi_result)
    if kimi_result.error:
        print(f"  ❌ Kimi 测试失败：{kimi_result.error}")
    else:
        print(f"  ✅ Kimi: {kimi_result.total_time*1000:.1f}ms, {kimi_result.tokens_per_sec:.1f} tokens/s")
    
    print("正在测试 MiniMax...")
    minimax_result = test_minimax(MINIMAX_KEY, prompt)
    results.append(minimax_result)
    if minimax_result.error:
        print(f"  ❌ MiniMax 测试失败：{minimax_result.error}")
    else:
        print(f"  ✅ MiniMax: {minimax_result.total_time*1000:.1f}ms, {minimax_result.tokens_per_sec:.1f} tokens/s")
    
    print("正在测试 Bailian...")
    bailian_result = test_bailian(BAILIAN_KEY, prompt)
    results.append(bailian_result)
    if bailian_result.error:
        print(f"  ❌ Bailian 测试失败：{bailian_result.error}")
    else:
        print(f"  ✅ Bailian: {bailian_result.total_time*1000:.1f}ms, {bailian_result.tokens_per_sec:.1f} tokens/s")
    
    print()
    print("=" * 60)
    print("测试结果对比")
    print("=" * 60)
    print()
    print(format_table(results))
    print()
    print("=" * 60)
    print("结论")
    print("=" * 60)
    print()
    print(format_conclusion(results))


if __name__ == "__main__":
    main()
