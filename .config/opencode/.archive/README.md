根据您的 model 列表，以下是**修正后的配置**和**Agent-Model 最优映射**：

## 修正后的 `opencode.json`

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "oh-my-opencode",
    "opencode-skillful",
    "opencode-supermemory",
    "opencode-pty"
  ],
  "instructions": [
    "~/.config/opencode/agents/AGENTS.md"
  ],
  "categories": {
    "sisyphus": {
      "description": "主编排器 - 复杂决策与路由（最强推理能力）",
      "provider_chain": [
        "bailian-coding-plan/qwen3.5-plus",
        "moonshot/kimi-k2.5",
        "bailian-coding-plan/glm-5"
      ],
      "constraints": {
        "temperature": 0.2,
        "max_tokens": 8192
      }
    },
    "prometheus": {
      "description": "规划师 - 架构分析与计划生成（长上下文理解）",
      "provider_chain": [
        "moonshot/kimi-k2.5",
        "bailian-coding-plan/qwen3-coder-plus",
        "bailian-coding-plan/qwen3.5-plus"
      ],
      "constraints": {
        "temperature": 0.3,
        "max_tokens": 32768
      }
    },
    "atlas": {
      "description": "执行者 - 批量重构与代码生成（高输出 token）",
      "provider_chain": [
        "minimax/minimax-m2.5",
        "bailian-coding-plan/qwen3-coder-next",
        "bailian-coding-plan/qwen3-coder-plus"
      ],
      "constraints": {
        "temperature": 0.3,
        "max_tokens": 65536
      }
    },
    "hephaestus": {
      "description": "深度工作者 - 复杂 C++ 实现与调试",
      "provider_chain": [
        "bailian-coding-plan/qwen3-coder-plus",
        "minimax/minimax-m2.5",
        "bailian-coding-plan/qwen3-coder-next"
      ],
      "constraints": {
        "temperature": 0.2,
        "max_tokens": 65536
      }
    },
    "explore": {
      "description": "代码搜索 - 快速定位与轻量分析（低成本）",
      "provider_chain": [
        "bailian-coding-plan/glm-4.7",
        "bailian-coding-plan/qwen3-max-2026-01-23",
        "moonshot/kimi-k2.5"
      ],
      "constraints": {
        "temperature": 0.1,
        "max_tokens": 4096
      }
    },
    "librarian": {
      "description": "文档专家 - API 理解与注释生成",
      "provider_chain": [
        "moonshot/kimi-k2.5",
        "bailian-coding-plan/qwen3.5-plus",
        "bailian-coding-plan/glm-5"
      ],
      "constraints": {
        "temperature": 0.4,
        "max_tokens": 16384
      }
    },
    "quick": {
      "description": "快速查询/补全（低成本、低延迟）",
      "provider_chain": [
        "bailian-coding-plan/glm-4.7",
        "bailian-coding-plan/qwen3-max-2026-01-23",
        "moonshot/kimi-k2.5"
      ],
      "constraints": {
        "temperature": 0.5,
        "max_tokens": 2000
      }
    }
  },
  "provider": {
    "moonshot": {
      "name": "Kimi (Moonshot)",
      "baseURL": "https://api.moonshot.cn/v1",
      "apiKey": "sk-kimi-xxx",
      "models": {
        "kimi-k2.5": {
          "name": "Kimi K2.5",
          "contextWindow": 256000,
          "maxTokens": 32768,
          "supportsVision": true
        }
      }
    },
    "minimax": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MiniMax CodingPlan",
      "baseURL": "https://api.minimax.com/anthropic",
      "apiKey": "你的 MiniMax API Key",
      "models": {
        "minimax-m2.5": {
          "name": "MiniMax M2.5",
          "contextWindow": 256000,
          "maxTokens": 65536,
          "supportsVision": false
        }
      }
    },
    "bailian-coding-plan": {
      "npm": "@ai-sdk/anthropic",
      "name": "Model Studio Coding Plan",
      "baseURL": "https://coding.dashscope.aliyuncs.com/apps/anthropic/v1",
      "apiKey": "sk-sp-xxx",
      "models": {
        "qwen3.5-plus": {
          "name": "Qwen3.5 Plus",
          "contextWindow": 1000000,
          "maxTokens": 65536,
          "supportsVision": true,
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 8192
            }
          }
        },
        "qwen3-max-2026-01-23": {
          "name": "Qwen3 Max 2026-01-23",
          "contextWindow": 262144,
          "maxTokens": 32768,
          "supportsVision": false
        },
        "qwen3-coder-next": {
          "name": "Qwen3 Coder Next",
          "contextWindow": 262144,
          "maxTokens": 65536,
          "supportsVision": false
        },
        "qwen3-coder-plus": {
          "name": "Qwen3 Coder Plus",
          "contextWindow": 1000000,
          "maxTokens": 65536,
          "supportsVision": false
        },
        "minimax-m2.5-alias": {
          "name": "MiniMax M2.5 (via Bailian)",
          "contextWindow": 196608,
          "maxTokens": 24576,
          "supportsVision": false,
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 8192
            }
          }
        },
        "glm-5": {
          "name": "GLM-5",
          "contextWindow": 202752,
          "maxTokens": 16384,
          "supportsVision": false,
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 8192
            }
          }
        },
        "glm-4.7": {
          "name": "GLM-4.7",
          "contextWindow": 202752,
          "maxTokens": 16384,
          "supportsVision": false,
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 8192
            }
          }
        },
        "kimi-k2.5-alias": {
          "name": "Kimi K2.5 (via Bailian)",
          "contextWindow": 262144,
          "maxTokens": 32768,
          "supportsVision": true,
          "options": {
            "thinking": {
              "type": "enabled",
              "budgetTokens": 8192
            }
          }
        }
      }
    }
  }
}
```

---

## 最优 Agent-Model 映射表

| Agent | 主要职责 | 首选 Model | 备选 Model | 选择理由 |
|-------|---------|-----------|-----------|---------|
| **Sisyphus** | 主编排、复杂决策、路由判断 | **qwen3.5-plus** (1M context) | kimi-k2.5 → glm-5 | 需要最强推理 + 长上下文理解整体架构 |
| **Prometheus** | 架构分析、计划生成、依赖梳理 | **kimi-k2.5** (256K context) | qwen3-coder-plus → qwen3.5-plus | 长上下文理解 C++ 大型代码库依赖关系 |
| **Atlas** | 批量重构、代码生成、执行计划 | **minimax-m2.5** (65K output) | qwen3-coder-next → qwen3-coder-plus | 高输出 token 支持大批量代码生成 |
| **Hephaestus** | 深度实现、复杂算法、调试 | **qwen3-coder-plus** (1M context) | minimax-m2.5 → qwen3-coder-next | 专业代码模型，支持超长上下文处理复杂实现 |
| **Explore** | 代码搜索、快速定位、轻量分析 | **glm-4.7** (低成本) | qwen3-max-2026-01-23 → kimi-k2.5 | 快速响应，低成本，适合后台持续索引 |
| **Librarian** | 文档生成、API 理解、注释 | **kimi-k2.5** (vision支持) | qwen3.5-plus → glm-5 | 擅长技术文档生成，支持图像（UML/架构图理解） |
| **Quick** | 快速补全、简单查询、语法检查 | **glm-4.7** (最快) | qwen3-max-2026-01-23 → kimi-k2.5 | 最低成本，低延迟，适合高频调用 |

---

## 对应的 `AGENTS.md` 配置

```markdown
# AGENTS.md - Agent 与 Model 映射配置

## Sisyphus（主编排器）
- **category**: sisyphus
- **model**: bailian-coding-plan/qwen3.5-plus (思考模式启用)
- **职责**: 
  - 识别 C++ 任务复杂度（分析 vs 重构）
  - 决策使用单步执行还是多智能体并行
  - 负载均衡：简单任务降级到 quick category，复杂任务升级
- **关键约束**: 
  - 必须使用 delegate_task 委派，禁止直接回答复杂问题
  - 上下文 > 100K tokens 时必须启用 thinking 模式

## Prometheus（规划师）
- **category**: prometheus  
- **model**: moonshot/kimi-k2.5
- **触发**: 当检测到"分析"、"重构"、"架构"、"依赖"等关键词
- **职责**:
  - 生成详细执行计划（含文件依赖图）
  - 标记高风险修改点（需人工 review）
  - 为每个子任务分配最优 category
- **输出**: 结构化计划 JSON，供 Atlas 消费

## Atlas（执行者）
- **category**: atlas
- **model**: minimax/minimax-m2.5 (65K 高输出)
- **触发**: 接收 Prometheus 的计划后自动激活
- **职责**:
  - 并行执行批量重构（利用 65K output 一次性处理大文件）
  - 使用 skillful 加载 C++ 特定技能（modernize/architecture）
  - 本地验证：clang-tidy + 编译检查
- **约束**: 每次修改后更新 state，失败时回滚到 git checkpoint

## Hephaestus（深度工作者）
- **category**: hephaestus
- **model**: bailian-coding-plan/qwen3-coder-plus (1M context)
- **职责**:
  - 处理复杂模板元编程、内存安全重构
  - 利用 1M context 理解超大文件（>1000 行）
  - 生成详细的重构说明和测试建议
- **特殊能力**: 可处理 vision 输入（查看编译错误截图）

## Explore（代码搜索）
- **category**: explore
- **model**: bailian-coding-plan/glm-4.7 (轻量快速)
- **后台运行**: 始终启用，维护代码库索引
- **职责**:
  - 快速 grep 替代，语义搜索（类/函数定义）
  - 预加载文件依赖关系到 supermemory
  - 低成本持续运行（几乎无 API 费用）

## Librarian（文档专家）
- **category**: librarian
- **model**: moonshot/kimi-k2.5 (vision 支持)
- **职责**:
  - 分析头文件生成 API 文档
  - 理解 UML 图/架构图生成实现代码
  - 多语言注释（中英文混合项目优化）

## Quick（快速响应）
- **category**: quick
- **model**: bailian-coding-plan/glm-4.7 (最低成本)
- **触发**: 单文件修改、语法问题、简单询问
- **职责**: 快速补全、格式化、简单解释
- **约束**: 禁止处理跨文件依赖（自动转交给 Prometheus）

## 委派策略示例

**场景 1: 大型重构任务**
1. Sisyphus (qwen3.5-plus) 判断复杂度 → 委派给 Prometheus
2. Prometheus (kimi-k2.5) 分析全项目依赖 → 生成 batch 计划
3. Atlas (minimax-m2.5) 并行执行 5 个文件重构（利用 65K output）
4. Hephaestus (qwen3-coder-plus) 处理其中 2 个复杂模板文件
5. Explore (glm-4.7) 后台验证修改后符号引用完整性

**场景 2: 快速修复**
1. Sisyphus (qwen3.5-plus) 识别为简单任务 → 直接委派 Quick
2. Quick (glm-4.7) 单文件修改，< 2秒响应，成本接近 0

**场景 3: 架构分析**
1. Sisyphus → Prometheus (kimi-k2.5) 生成架构图
2. Librarian (kimi-k2.5) 分析现有文档差距
3. Hephaestus (qwen3-coder-plus) 根据分析结果生成改进代码
```

---

## 关键修正说明

1. **修正了 provider ID**: 原配置使用了错误的 `kimi/k2.5` 格式，实际应为 `moonshot/kimi-k2.5`（与 provider key 匹配）

2. **优化了模型分配**:
   - **Qwen3.5 Plus** (1M context, vision) → Sisyphus（需要全局视野）
   - **MiniMax M2.5** (65K output) → Atlas/Hephaestus（需要大量代码生成）
   - **GLM-4.7** (轻量) → Explore/Quick（低成本高频调用）

3. **移除了不存在的模型引用**: 原配置中的 `minimax/m1`, `minimax/ab6-coding`, `minimax/s1` 等不在 provider 列表中，已修正为实际存在的 `minimax-m2.5`

4. **启用了思考模式**: 为需要推理的模型（qwen3.5-plus, glm-5, glm-4.7）显式启用了 `thinking` 配置

5. **修正了 vision 支持**: kimi-k2.5 和 qwen3.5-plus 支持 vision，可在 Librarian 中用于分析架构图
