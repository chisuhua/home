#!/usr/bin/env python3
"""
Ecommerce Price Trend Skill 执行脚本

用法:
    python analyze_price.py --history '<JSON>' [--detect-anomaly]
"""

import sys
import json
import argparse
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "ecommerce" / "src"))

from analysis.price_trend import analyze_price_trend, detect_price_anomaly


def main():
    parser = argparse.ArgumentParser(description="价格趋势分析 Skill")
    parser.add_argument(
        "--history",
        type=str,
        required=True,
        help="历史价格数据（JSON 格式）"
    )
    parser.add_argument(
        "--detect-anomaly",
        action="store_true",
        help="是否检测异常价格"
    )
    
    args = parser.parse_args()
    
    try:
        history_data = json.loads(args.history)
        
        result = analyze_price_trend(history_data)
        
        if args.detect_anomaly:
            result["anomalies"] = detect_price_anomaly(history_data)
        
        print(json.dumps({
            "status": "success",
            "data": result
        }, ensure_ascii=False))
        return 0
        
    except Exception as e:
        print(json.dumps({
            "status": "error",
            "message": str(e)
        }, ensure_ascii=False))
        return 1


if __name__ == "__main__":
    sys.exit(main())
