#!/usr/bin/env python3
"""
Ecommerce Classifier Skill 执行脚本

用法:
    python classify.py --title "商品标题" [--description "描述"]
"""

import sys
import json
import argparse
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "ecommerce" / "src"))

from analysis.classifier import classify_product


def main():
    parser = argparse.ArgumentParser(description="商品分类 Skill")
    parser.add_argument(
        "--title",
        type=str,
        required=True,
        help="商品标题"
    )
    parser.add_argument(
        "--description",
        type=str,
        default="",
        help="商品描述（可选）"
    )
    
    args = parser.parse_args()
    
    try:
        result = classify_product(args.title, args.description)
        
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
