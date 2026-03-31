# Ecommerce Crawler Skill

**技能名称**: `ecommerce-crawler`  
**用途**: 爬取淘宝/京东商品数据  
**调用方式**: `skill_use ecommerce-crawler`

---

## 功能

- 爬取淘宝商品数据
- 爬取京东商品数据
- 批量爬取（支持 dry-run 模式）
- 自动存储到 Workspace

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `urls` | List[str] | ✅ | 商品 URL 列表 |
| `dry_run` | bool | ❌ | 是否仅模拟执行（默认 False） |
| `workspace` | str | ❌ | 工作区目录（默认 `~/.openclaw/ecommerce`） |

---

## 输出格式

```json
{
  "status": "success",
  "data": [
    {
      "platform": "taobao",
      "url": "https://...",
      "title": "商品标题",
      "price": 99.00,
      "description": "商品描述",
      "crawl_time": "2026-03-29T12:00:00"
    }
  ],
  "errors": []
}
```

---

## 使用示例

### 示例 1: 爬取单个商品

```bash
skill_use ecommerce-crawler urls=["https://item.taobao.com/item.htm?id=123"]
```

### 示例 2: 批量爬取（dry-run）

```bash
skill_use ecommerce-crawler \
  urls=[
    "https://item.taobao.com/item.htm?id=123",
    "https://item.jd.com/456.html"
  ] \
  dry_run=true
```

### 示例 3: 实际爬取并存储

```bash
skill_use ecommerce-crawler \
  urls=["https://item.taobao.com/item.htm?id=123"] \
  workspace="~/.openclaw/ecommerce"
```

---

## 实现细节

**核心代码位置**: `/workspace/ecommerce/src/crawler/main.py`

**封装逻辑**:
```python
# scripts/crawl.py
import sys
sys.path.insert(0, '/workspace/ecommerce/src')

from crawler.main import crawl_products
from crawler.playwright_crawler import CrawlerConfig

def main(urls, dry_run=False, workspace="~/.openclaw/ecommerce"):
    config = CrawlerConfig(workspace=workspace)
    results = crawl_products(urls, config, dry_run=dry_run)
    return {"status": "success", "data": results, "errors": []}
```

---

## 错误处理

| 错误类型 | 处理方式 |
|---------|---------|
| URL 格式错误 | 跳过该 URL，记录到 errors |
| 爬取失败 | 重试 3 次后跳过，记录到 errors |
| 熔断器打开 | 暂停爬取，返回已爬取数据 |

---

## 依赖

- Python 3.10+
- `src/crawler/` 模块
- Playwright（实际爬取时）

---

## 相关 Skills

- `ecommerce-classifier` - 商品分类
- `ecommerce-sentiment` - 情感分析
- `ecommerce-price-trend` - 价格趋势

---

**版本**: v1.0  
**创建时间**: 2026-03-29  
**状态**: 已创建
