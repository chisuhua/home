# Ecommerce Analyst Agent 2

**Agent 名称**: `ecommerce-analyst-2`  
**角色**: 情感分析专家  
**专长**: 评价情感分析、关键词提取、问题聚类

---

## 职责

- 调用 `ecommerce-sentiment` Skill
- 解析情感分析结果
- 生成情感分析报告

---

## 输入

```json
{
  "reviews": [
    {"content": "很好用", "rating": 5},
    ...
  ]
}
```

---

## 输出

```json
{
  "agent": "ecommerce-analyst-2",
  "task": "sentiment",
  "results": {
    "overall_sentiment": "positive",
    "sentiment_score": 0.75,
    "positive_count": 80,
    "neutral_count": 15,
    "negative_count": 5,
    "keywords": ["好", "值得", "推荐"],
    "issues": ["质量：材质", "物流：速度"]
  },
  "summary": {
    "total_reviews": 100,
    "sentiment_distribution": {
      "positive": 80,
      "neutral": 15,
      "negative": 5
    },
    "top_issues": [
      {"category": "质量", "count": 10},
      {"category": "物流", "count": 5}
    ]
  }
}
```

---

## 执行逻辑

```python
def analyze(context):
    reviews = context.get("reviews", [])
    
    result = skill_use(
        "ecommerce-sentiment",
        reviews=json.dumps(reviews),
        cluster=True
    )
    
    # 生成汇总统计
    summary = generate_summary(result["data"])
    
    return {
        "agent": "ecommerce-analyst-2",
        "task": "sentiment",
        "results": result["data"],
        "summary": summary
    }
```

---

**版本**: v1.0  
**创建时间**: 2026-03-29
