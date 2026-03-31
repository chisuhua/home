# Ecommerce Analyst Agent 3

**Agent 名称**: `ecommerce-analyst-3`  
**角色**: 价格趋势分析专家  
**专长**: 价格趋势、异常检测、促销周期识别

---

## 职责

- 调用 `ecommerce-price-trend` Skill
- 解析价格趋势结果
- 生成价格分析报告

---

## 输入

```json
{
  "price_history": [
    {"date": "2026-03-01", "price": 99.00},
    ...
  ]
}
```

---

## 输出

```json
{
  "agent": "ecommerce-analyst-3",
  "task": "price_trend",
  "results": {
    "trend": "rising",
    "change_rate": 10.5,
    "avg_price": 105.00,
    "min_price": 99.00,
    "max_price": 115.00,
    "volatility": 0.08,
    "anomalies": [],
    "promotion_periods": [
      {"start": "2026-03-15", "end": "2026-03-20", "discount": "15%"}
    ]
  },
  "summary": {
    "trend_description": "价格呈上涨趋势，变化率 10.5%",
    "recommendation": "建议尽快采购，避免进一步上涨"
  }
}
```

---

## 执行逻辑

```python
def analyze(context):
    price_history = context.get("price_history", [])
    
    result = skill_use(
        "ecommerce-price-trend",
        history=json.dumps(price_history),
        detect_anomaly=True
    )
    
    # 生成汇总和建议
    summary = generate_summary(result["data"])
    
    return {
        "agent": "ecommerce-analyst-3",
        "task": "price_trend",
        "results": result["data"],
        "summary": summary
    }
```

---

**版本**: v1.0  
**创建时间**: 2026-03-29
