# API 接口规范模板

**用途**：用于 `/zcf:arch-doc "阶段 X：XXX 模块 API 规范"` 生成的标准格式

**保存位置**：`docs/architecture/phases/phase-X/<module-name>/api-spec.md`

---

## 模板结构

```markdown
# {{MODULE_NAME}} API 接口规范

**创建日期**：{{DATE}}
**最后更新**：{{LAST_UPDATE}}
**版本**：{{VERSION}}

**所属阶段**：{{PHASE_NAME}}
**所属模块**：{{MODULE_NAME}}

---

## 1. 概述

### 1.1 接口范围

{{本规范涵盖的接口范围}}

### 1.2 设计原则

{{接口设计遵循的原则}}

1. **RESTful** — 使用标准 HTTP 方法和状态码
2. **版本控制** — URL 中包含版本号（`/api/v1/`）
3. **统一响应** — 所有响应使用统一格式
4. **错误规范** — 错误响应包含错误码和说明

### 1.3 基础 URL

```
{{BASE_URL}}
```

### 1.4 认证方式

{{认证方式说明}}

---

## 2. 统一响应格式

### 2.1 成功响应

```json
{
  "success": true,
  "data": { },
  "message": "操作成功"
}
```

### 2.2 错误响应

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "人类可读的错误描述",
    "details": {}
  }
}
```

### 2.3 分页响应

```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

---

## 3. 接口列表

{{#each ENDPOINTS}}
### {{METHOD}} {{PATH}}

**描述**：{{DESCRIPTION}}

**请求参数**：

{{#if PATH_PARAMS}}
**路径参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
{{#each PATH_PARAMS}}
| {{this.name}} | {{this.type}} | {{this.required}} | {{this.description}} |
{{/each}}
{{/if}}

{{#if QUERY_PARAMS}}
**查询参数**：
| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
{{#each QUERY_PARAMS}}
| {{this.name}} | {{this.type}} | {{this.required}} | {{this.default}} | {{this.description}} |
{{/each}}
{{/if}}

{{#if BODY_PARAMS}}
**请求体**：
```json
{{BODY_EXAMPLE}}
```

**字段说明**：
| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
{{#each BODY_PARAMS}}
| {{this.name}} | {{this.type}} | {{this.required}} | {{this.description}} |
{{/each}}
{{/if}}

**响应**：

**状态码**：`{{STATUS_CODE}}`

**响应体**：
```json
{{RESPONSE_EXAMPLE}}
```

**错误码**：
| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
{{#each ERROR_CODES}}
| {{this.code}} | {{this.message}} | {{this.status}} |
{{/each}}

**使用示例**：
```bash
curl -X {{METHOD}} {{URL}} \
  -H "Content-Type: application/json" \
  -d '{{BODY_EXAMPLE}}'
```

---

{{/each}}

## 4. 错误码字典

| 错误码 | 说明 | HTTP 状态码 | 处理建议 |
|--------|------|-------------|----------|
{{#each ERROR_CODES_GLOBAL}}
| {{this.code}} | {{this.message}} | {{this.status}} | {{this.suggestion}} |
{{/each}}

---

## 5. 变更历史

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| {{DATE}} | v1.0 | 初始版本 |
| {{DATE}} | v1.1 | {{CHANGE}} |

---

## 相关文档

- [模块详细设计](./detailed-design.md)
- [数据库设计](./database-schema.md)
- [总体架构文档](../../YYYY-MM-DD-{{project-name}}.md)
```

---

## 使用示例

### 示例：爬虫模块 API 规范

```markdown
# 爬虫模块 API 接口规范

**创建日期**：2026-03-26
**最后更新**：2026-03-26
**版本**：v1.0

**所属阶段**：Phase 1: MVP
**所属模块**：爬虫模块

---

## 1. 概述

### 1.1 接口范围

本规范涵盖爬虫模块的所有对外 HTTP 接口，包括网页抓取、数据解析和 URL 管理。

### 1.2 设计原则

1. **RESTful** — 使用标准 HTTP 方法和状态码
2. **版本控制** — URL 中包含版本号（`/api/v1/`）
3. **统一响应** — 所有响应使用统一 JSON 格式
4. **异步支持** — 耗时操作支持异步轮询

### 1.3 基础 URL

```
http://localhost:8000/api/v1/crawler
```

### 1.4 认证方式

暂无（MVP 阶段），Phase 2 添加 API Key 认证。

---

## 2. 统一响应格式

### 2.1 成功响应

```json
{
  "success": true,
  "data": {},
  "message": "操作成功"
}
```

### 2.2 错误响应

```json
{
  "success": false,
  "error": {
    "code": "CRAWLER_ERROR",
    "message": "爬虫请求失败",
    "details": {
      "url": "https://example.com",
      "reason": "timeout"
    }
  }
}
```

---

## 3. 接口列表

### POST /crawl

**描述**：抓取指定 URL 的网页内容

**请求体**：
```json
{
  "url": "https://example.com/product/123",
  "timeout": 30,
  "retry_count": 3,
  "parse": true
}
```

**字段说明**：
| 字段名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| url | string | 是 | - | 要抓取的 URL |
| timeout | integer | 否 | 30 | 请求超时时间（秒） |
| retry_count | integer | 否 | 3 | 重试次数 |
| parse | boolean | 否 | true | 是否自动解析 |

**响应**：

**状态码**：`200 OK`

**响应体**：
```json
{
  "success": true,
  "data": {
    "url": "https://example.com/product/123",
    "html": "<html>...</html>",
    "parsed": {
      "title": "Product Name",
      "price": 99.99,
      "links": ["...", "..."]
    },
    "crawled_at": "2026-03-26T10:00:00Z"
  }
}
```

**错误码**：
| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| INVALID_URL | URL 格式无效 | 400 |
| CRAWLER_TIMEOUT | 请求超时 | 504 |
| CRAWLER_ERROR | 爬虫内部错误 | 500 |

**使用示例**：
```bash
curl -X POST http://localhost:8000/api/v1/crawler/crawl \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/product/123",
    "timeout": 30,
    "retry_count": 3
  }'
```

---

### GET /parse

**描述**：解析 HTML 内容，提取结构化数据

**请求体**：
```json
{
  "html": "<html>...</html>",
  "extract": ["title", "price", "links"]
}
```

**响应**：

**状态码**：`200 OK`

**响应体**：
```json
{
  "success": true,
  "data": {
    "title": "Product Name",
    "price": 99.99,
    "links": ["...", "..."]
  }
}
```

**错误码**：
| 错误码 | 说明 | HTTP 状态码 |
|--------|------|-------------|
| INVALID_HTML | HTML 格式无效 | 400 |
| PARSE_ERROR | 解析失败 | 500 |

---

### GET /url-manager/status

**描述**：获取 URL 管理器状态

**查询参数**：
| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| include_pending | boolean | 否 | false | 是否包含待抓取 URL 数量 |

**响应**：

**状态码**：`200 OK`

**响应体**：
```json
{
  "success": true,
  "data": {
    "visited_count": 1000,
    "pending_count": 50,
    "failed_count": 5
  }
}
```

---

## 4. 错误码字典

| 错误码 | 说明 | HTTP 状态码 | 处理建议 |
|--------|------|-------------|----------|
| INVALID_URL | URL 格式无效 | 400 | 检查 URL 格式 |
| CRAWLER_TIMEOUT | 请求超时 | 504 | 增加 timeout 参数 |
| CRAWLER_ERROR | 爬虫内部错误 | 500 | 查看服务器日志 |
| INVALID_HTML | HTML 格式无效 | 400 | 检查 HTML 内容 |
| PARSE_ERROR | 解析失败 | 500 | 检查选择器配置 |

---

## 5. 变更历史

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2026-03-26 | v1.0 | 初始版本 |
| 2026-03-27 | v1.1 | 添加 `retry_count` 参数 |

---

## 相关文档

- [模块详细设计](./detailed-design.md)
- [数据库设计](./database-schema.md)
- [总体架构文档](../../2026-03-26-ecommerce-analysis-system.md)
```

---

## 最佳实践

1. **版本控制** — URL 中包含版本号，便于迭代
2. **统一格式** — 所有接口使用统一的请求/响应格式
3. **错误规范** — 错误码有意义，便于问题排查
4. **示例完整** — 每个接口都有完整的请求/响应示例
5. **变更追踪** — 记录每次 API 变更的内容和日期
