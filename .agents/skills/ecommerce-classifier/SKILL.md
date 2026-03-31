# Ecommerce Classifier Skill

**技能名称**: `ecommerce-classifier`  
**用途**: 商品自动分类和标签提取  
**调用方式**: `skill_use ecommerce-classifier`

---

## 功能

- 商品自动分类（一级类目 + 二级类目）
- 标签提取（关键词匹配）
- 置信度评分

---

## 输入参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `title` | str | ✅ | 商品标题 |
| `description` | str | ❌ | 商品描述（可选） |
| `category_config` | str | ❌ | 分类体系 YAML 路径（可选） |

---

## 输出格式

```json
{
  "status": "success",
  "data": {
    "level1": "电子产品",
    "level1_code": "electronics",
    "level2": "手机",
    "level2_code": "mobile",
    "tags": ["手机", "智能", "5G"],
    "confidence": 0.95
  }
}
```

---

## 使用示例

### 示例 1: 商品分类

```bash
skill_use ecommerce-classifier \
  title="iPhone 15 Pro Max 256GB 深空黑色"
```

### 示例 2: 带描述的分类

```bash
skill_use ecommerce-classifier \
  title="男士休闲衬衫" \
  description="纯棉材质，商务休闲风格"
```

---

## 实现细节

**核心代码位置**: `/workspace/ecommerce/src/analysis/classifier.py`

**封装逻辑**:
```python
# scripts/classify.py
import sys
sys.path.insert(0, '/workspace/ecommerce/src')

from analysis.classifier import classify_product

def main(title, description=""):
    result = classify_product(title, description)
    return {"status": "success", "data": result}
```

---

## 分类体系

### 默认类目

| 一级类目 | 二级类目 | 关键词 |
|---------|---------|--------|
| 电子产品 | 手机/电脑/平板 | 手机，电脑，电子，数码 |
| 服装 | 男装/女装 | 衣服，服装，男，女 |
| 家居 | 家具/家纺 | 家居，家具，家 |

### 自定义分类

在 `config/categories.yaml` 中定义自定义分类体系。

---

## 相关 Skills

- `ecommerce-crawler` - 商品爬取
- `ecommerce-sentiment` - 情感分析
- `ecommerce-price-trend` - 价格趋势

---

**版本**: v1.0  
**创建时间**: 2026-03-29  
**状态**: 已创建
