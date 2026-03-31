# Ecommerce Sentiment Skill

**技能名称**: `ecommerce-sentiment`  
**用途**: 评价情感分析、关键词提取、问题聚类  
**调用方式**: `skill_use ecommerce-sentiment`

---

## 功能

- 情感倾向分析（正面/中性/负面）
- 情感得分计算（0-1）
- 正面关键词提取
- 负面问题提取
- 问题聚类统计

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `reviews` | List[Dict] | ✅ | 评价列表 |
| `cluster` | bool | ❌ | 是否进行问题聚类（默认 True） |

**评价格式**:
```json
[
  {"content": "很好用，值得购买", "rating": 5},
  {"content": "质量一般", "rating": 3},
  {"content": "太差了", "rating": 1}
]
```

---

## 输出格式

```json
{
  "status": "success",
  "data": {
    "overall_sentiment": "positive",
    "sentiment_score": 0.75,
    "positive_count": 2,
    "neutral_count": 1,
    "negative_count": 0,
    "keywords": ["好", "值得", "推荐"],
    "issues": ["质量：材质"]
  }
}
```

---

## 使用示例

### 示例 1: 情感分析

```bash
skill_use ecommerce-sentiment \
  reviews='[{"content":"很好用","rating":5},{"content":"一般","rating":3}]'
```

### 示例 2: 带问题聚类

```bash
skill_use ecommerce-sentiment \
  reviews='[...]' \
  cluster=true
```

---

## 实现细节

**核心代码位置**: `/workspace/ecommerce/src/analysis/sentiment.py`

**封装逻辑**:
```python
# scripts/analyze_sentiment.py
import sys
sys.path.insert(0, '/workspace/ecommerce/src')

from analysis.sentiment import analyze_sentiment, cluster_issues

def main(reviews, cluster=True):
    result = analyze_sentiment(reviews)
    if cluster:
        result["issue_clusters"] = cluster_issues(reviews)
    return {"status": "success", "data": result}
```

---

## 情感词典

### 正面词汇
好、不错、满意、喜欢、推荐、值得、优秀、完美、快、流畅、清晰、舒适、方便、实用、划算

### 负面词汇
差、不好、失望、讨厌、垃圾、浪费、糟糕、劣质、慢、卡顿、模糊、麻烦、无用、贵、坑

---

## 问题分类

| 类别 | 关键词 |
|------|--------|
| 质量 | 质量，材质，做工，耐用，破损，瑕疵 |
| 物流 | 物流，快递，配送，发货，包装，速度 |
| 服务 | 服务，态度，客服，售后，响应 |
| 价格 | 价格，贵，便宜，性价比，划算 |
| 功能 | 功能，性能，效果，使用，操作 |

---

## 相关 Skills

- `ecommerce-crawler` - 商品爬取
- `ecommerce-classifier` - 商品分类
- `ecommerce-price-trend` - 价格趋势

---

**版本**: v1.0  
**创建时间**: 2026-03-29  
**状态**: 已创建
