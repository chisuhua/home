# 飞书消息格式化技能

## 功能
自动根据消息内容类型选择最佳飞书消息格式，优化手机端阅读体验。

## 消息类型选择规则

| 内容特征 | 消息类型 | type 值 | 说明 |
|---------|---------|--------|------|
| 纯对话/简短回复 | text | 1 | 默认，加载快 |
| 包含代码块/多段落 | post | 2 | 富文本卡片，结构化 |
| 任务汇报/进度更新 | post | 2 | 分段清晰，重点突出 |
| 代码审查结果 | post | 2 | ✅/❌ 状态可视化 |
| 包含链接 | text + 预览 | 1 | 飞书自动解析预览 |
| @mention | 原生 @ | - | 自动转换 `<at>` 标签 |

## 使用方法

### 方式 1：在 message 工具中指定 type 参数

```javascript
message({
  action: "send",
  channel: "feishu",
  target: "ou_xxx",
  message: "内容",
  type: 2  // post 类型
})
```

### 方式 2：自动检测（推荐）

在发送前根据内容特征自动选择：

```javascript
// 检测是否需要富文本格式
function needsRichFormat(content) {
  // 包含代码块
  if (content.includes("```")) return true;
  // 包含多级标题
  if (content.match(/^#{2,}\s/m)) return true;
  // 包含表格
  if (content.includes("|") && content.includes("---")) return true;
  // 超过 5 行
  if (content.split("\n").length > 5) return true;
  // 包含状态标记
  if (content.match(/✅|❌|⚠️|🔴|🟡/)) return true;
  return false;
}
```

## @mention 转换

飞书原生 @ 格式：
```json
{
  "text": "你好 <at user_id=\"ou_xxx\">张三</at>",
  "mentions": ["ou_xxx"]
}
```

OpenClaw message 工具自动处理：
- 输入：`<at user_id="ou_xxx">name</at>`
- 输出：飞书原生 @ 格式

## 富文本卡片格式示例

### 任务汇报格式

```json
{
  "config": {
    "wide_screen_mode": true
  },
  "elements": [
    {
      "tag": "div",
      "text": {
        "content": "**任务进度汇报**\n项目：PTX-EMU\n状态：✅ 编译通过",
        "tag": "lark_md"
      }
    },
    {
      "tag": "hr"
    },
    {
      "tag": "note",
      "elements": [
        {
          "tag": "plain_text",
          "content": "下一步：性能优化"
        }
      ]
    }
  ]
}
```

## 配置建议

在 `~/.openclaw/config.json` 中添加：

```json
{
  "channels": {
    "feishu": {
      "capabilities": ["threadBindings", "acpSessions"],
      "messageFormat": {
        "default": "text",
        "richThreshold": {
          "minLines": 5,
          "hasCodeBlock": true,
          "hasTable": true,
          "hasStatusMarkers": true
        }
      }
    }
  }
}
```

## 手机端优化建议

1. **卡片宽度**：设置 `wide_screen_mode: true` 充分利用屏幕
2. **段落间距**：用 `---` 分隔线分隔大块内容
3. **重点突出**：用 `**粗体**` 标记关键信息
4. **避免长代码**：超过 20 行代码建议发文件/文档链接
5. **表情符号**：适量使用 ✅❌⚠️ 增强视觉层次
