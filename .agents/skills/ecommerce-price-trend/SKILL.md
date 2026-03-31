# Ecommerce Price Trend Skill

**技能名称**: `ecommerce-price-trend`  
**用途**: 价格趋势分析、异常检测、促销周期识别  
**调用方式**: `skill_use ecommerce-price-trend`

---

## 功能

- 价格趋势分析（上涨/下跌/稳定）
- 变化率计算
- 价格波动率分析
- 异常价格检测
- 促销周期识别

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `history_data` | List[Dict] | ✅ | 历史价格数据 |
| `detect_anomaly` | bool | ❌ | 是否检测异常（默认 True） |

**数据格式**:
```json
[
  {"date": "2026-03-01", "price": 99.00},
  {"date": "2026-03-02", "price": 105.00},
  {"date": "2026-03-03", "price": 110.00}
]
```

---

## 输出格式

```json
{
  "status": "success",
  "data": {
    "trend": "rising",
    "change_rate": 10.0,
    "avg_price": 105.00,
    "min_price": 99.00,
    "max_price": 110.00,
    "volatility": 0.05,
    "anomalies": [],
    "promotion_periods": []
  }
}
```

---

## 使用示例

### 示例 1: 价格趋势分析

```bash
skill_use ecommerce-price-trend \
  history_data='[{"date":"2026-03-01","price":99},{"date":"2026-03-02","price":105}]'
```

### 示例 2: 带异常检测

```bash
skill_use ecommerce-price-trend \
  history_data='[...]' \
  detect_anomaly=true
```

---

## 实现细节

**核心代码位置**: `/workspace/ecommerce/src/analysis/price_trend.py`

**封装逻辑**:
```python
# scripts/analyze_price.py
import sys
sys.path.insert(0, '/workspace/ecommerce/src')

from analysis.price_trend import analyze_price_trend, detect_price_anomaly

def main(history_data, detect_anomaly=True):
    result = analyze_price_trend(history_data)
    if detect_anomaly:
        result["anomalies"] = detect_price_anomaly(history_data)
    return {"status": "success", "data": result}
```

---

## 趋势判断

| 趋势 | 条件 |
|------|------|
| rising（上涨） | 变化率 > 5% |
| falling（下跌） | 变化率 < -5% |
| stable（稳定） | -5% ≤ 变化率 ≤ 5% |

---

## 异常检测

**检测规则**:
- 价格波动超过 2 个标准差
- 价格突增/突减超过 20%

---

## 相关 Skills

- `ecommerce-crawler` - 商品爬取
- `ecommerce-classifier` - 商品分类
- `ecommerce-sentiment` - 情感分析

---

**版本**: v1.0  
**创建时间**: 2026-03-29  
**状态**: 已创建
