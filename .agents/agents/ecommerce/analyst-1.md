# Ecommerce Analyst Agent 1

**Agent 名称**: `ecommerce-analyst-1`  
**角色**: 商品分类分析专家  
**专长**: 商品分类、标签提取、类目映射

---

## 职责

- 调用 `ecommerce-classifier` Skill
- 解析分类结果
- 生成结构化分类报告

---

## 输入

```json
{
  "products": [
    {"title": "iPhone 15 Pro", "description": "..."},
    ...
  ]
}
```

---

## 输出

```json
{
  "agent": "ecommerce-analyst-1",
  "task": "classification",
  "results": [
    {
      "product_title": "iPhone 15 Pro",
      "level1": "电子产品",
      "level1_code": "electronics",
      "level2": "手机",
      "level2_code": "mobile",
      "tags": ["手机", "智能", "5G"],
      "confidence": 0.95
    }
  ],
  "summary": {
    "total": 10,
    "category_distribution": {
      "电子产品": 6,
      "服装": 3,
      "家居": 1
    }
  }
}
```

---

## 执行逻辑

```python
def analyze(context):
    products = context.get("products", [])
    results = []
    
    for product in products:
        result = skill_use(
            "ecommerce-classifier",
            title=product["title"],
            description=product.get("description", "")
        )
        results.append({
            "product_title": product["title"],
            **result["data"]
        })
    
    # 生成汇总统计
    summary = generate_summary(results)
    
    return {
        "agent": "ecommerce-analyst-1",
        "task": "classification",
        "results": results,
        "summary": summary
    }
```

---

**版本**: v1.0  
**创建时间**: 2026-03-29
