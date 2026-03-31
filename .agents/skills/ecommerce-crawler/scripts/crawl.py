#!/usr/bin/env python3
"""
Ecommerce Crawler Skill 执行脚本

用法:
    python crawl.py --urls "url1,url2" [--dry-run] [--workspace DIR]
"""

import sys
import json
import argparse
from pathlib import Path

# 添加项目路径
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "ecommerce" / "src"))

from crawler.main import crawl_products
from crawler.playwright_crawler import CrawlerConfig


def main():
    parser = argparse.ArgumentParser(description="电商商品爬虫 Skill")
    parser.add_argument(
        "--urls",
        type=str,
        required=True,
        help="商品 URL 列表（逗号分隔）"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="仅模拟执行，不实际爬取"
    )
    parser.add_argument(
        "--workspace",
        default="~/.openclaw/ecommerce",
        help="工作区目录"
    )
    
    args = parser.parse_args()
    
    # 解析 URL 列表
    urls = [url.strip() for url in args.urls.split(",") if url.strip()]
    
    if not urls:
        print(json.dumps({
            "status": "error",
            "message": "URL 列表为空"
        }, ensure_ascii=False))
        return 1
    
    # 执行爬取
    config = CrawlerConfig(workspace=args.workspace)
    
    try:
        results = crawl_products(urls, config, dry_run=args.dry_run)
        
        print(json.dumps({
            "status": "success",
            "data": results,
            "errors": [],
            "count": len(results)
        }, ensure_ascii=False, default=str))
        return 0
        
    except Exception as e:
        print(json.dumps({
            "status": "error",
            "message": str(e),
            "errors": [{"error": str(e), "type": "crawl_error"}]
        }, ensure_ascii=False))
        return 1


if __name__ == "__main__":
    sys.exit(main())
