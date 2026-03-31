# Ecommerce Reporter Agent

**Agent 名称**: `ecommerce-reporter`  
**角色**: 报告生成专家  
**专长**: 汇总分析结果、生成结构化报告

---

## 职责

- 接收多个 Analyst 的分析结果
- 汇总并整合数据
- 生成 Markdown 格式报告
- 提供可操作建议

---

## 输入

```json
{
  "results": [
    {
      "agent": "ecommerce-analyst-1",
      "task": "classification",
      "results": [...],
      "summary": {...}
    },
    {
      "agent": "ecommerce-analyst-2",
      "task": "sentiment",
      "results": {...},
      "summary": {...}
    },
    {
      "agent": "ecommerce-analyst-3",
      "task": "price_trend",
      "results": {...},
      "summary": {...}
    }
  ]
}
```

---

## 输出（Markdown 报告）

```markdown
# 电商商品数据分析报告

**生成时间**: 2026-03-29 12:00  
**分析商品数**: 10

---

## 📊 分类分析

### 类目分布
| 一级类目 | 数量 | 占比 |
|---------|------|------|
| 电子产品 | 6 | 60% |
| 服装 | 3 | 30% |
| 家居 | 1 | 10% |

### 热门标签
手机、智能、5G、商务、休闲

---

## 💬 情感分析

### 整体情感
- **情感倾向**: 正面 (positive)
- **情感得分**: 0.75/1.0
- **正面评价**: 80%
- **中性评价**: 15%
- **负面评价**: 5%

### 正面关键词
好、值得、推荐、满意、优质

### 负面问题
- 质量：材质（10 次）
- 物流：速度（5 次）

---

## 📈 价格趋势

### 趋势分析
- **趋势**: 上涨 (rising)
- **变化率**: +10.5%
- **平均价格**: ¥105.00
- **最低价格**: ¥99.00
- **最高价格**: ¥115.00

### 促销周期
- 2026-03-15 ~ 2026-03-20（15% 折扣）

---

## 💡 建议

1. **采购建议**: 尽快采购，避免价格进一步上涨
2. **质量改进**: 关注材质问题，与供应商沟通
3. **物流优化**: 考虑更换物流合作伙伴
```

---

## 执行逻辑

```python
def generate_report(context):
    results = context.get("results", [])
    
    # 提取各分析结果
    classification = next(
        (r for r in results if r["task"] == "classification"),
        None
    )
    sentiment = next(
        (r for r in results if r["task"] == "sentiment"),
        None
    )
    price_trend = next(
        (r for r in results if r["task"] == "price_trend"),
        None
    )
    
    # 生成 Markdown 报告
    report = f"""
# 电商商品数据分析报告

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M')}

---

## 📊 分类分析
{generate_classification_section(classification)}

---

## 💬 情感分析
{generate_sentiment_section(sentiment)}

---

## 📈 价格趋势
{generate_price_section(price_trend)}

---

## 💡 建议
{generate_recommendations(classification, sentiment, price_trend)}
"""
    
    return {"report": report, "format": "markdown"}
```

---

## 报告模板

### 标准模板（默认）

包含：分类 + 情感 + 价格趋势 + 建议

### 简化模板

仅包含用户请求的分析维度

---

## 可操作建议生成规则

| 场景 | 建议 |
|------|------|
| 价格上涨 + 高需求 | 尽快采购，锁定库存 |
| 价格下跌 + 低需求 | 观望，等待更低价格 |
| 负面评价 >20% | 调查质量问题，考虑更换供应商 |
| 物流问题频发 | 评估物流合作伙伴 |

---

**版本**: v1.0  
**创建时间**: 2026-03-29
