#!/usr/bin/env python3
"""
Ecommerce Sentiment Skill 执行脚本

用法:
    python analyze_sentiment.py --reviews '<JSON>' [--cluster]
"""

import sys
import json
import argparse
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "ecommerce" / "src"))

from analysis.sentiment import analyze_sentiment, cluster_issues


def main():
    parser = argparse.ArgumentParser(description="情感分析 Skill")
    parser.add_argument(
        "--reviews",
        type=str,
        required=True,
        help="评价列表（JSON 格式）"
    )
    parser.add_argument(
        "--cluster",
        action="store_true",
        help="是否进行问题聚类"
    )
    
    args = parser.parse_args()
    
    try:
        reviews = json.loads(args.reviews)
        
        result = analyze_sentiment(reviews)
        
        if args.cluster:
            result["issue_clusters"] = cluster_issues(reviews)
        
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
