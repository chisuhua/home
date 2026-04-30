# OpenCode 环境变量配置

## 设置方法

### Linux/macOS

在 `~/.bashrc` 或 `~/.zshrc` 中添加：

```bash
# OpenCode API Keys
export KIMI_API_KEY="your-kimi-api-key"
export MINIMAX_API_KEY="your-minimax-api-key"
export DASHSCOPE_API_KEY="your-dashscope-api-key"
```

### 生效

```bash
source ~/.bashrc
```

或重启终端。

## API Key 获取

| Provider | 获取地址 |
|----------|----------|
| KIMI_API_KEY | https://platform.moonshot.cn/ |
| MINIMAX_API_KEY | https://platform.minimaxi.com/ |
| DASHSCOPE_API_KEY | https://dashscope.console.aliyun.com/ |

## 验证配置

```bash
echo $KIMI_API_KEY
echo $MINIMAX_API_KEY
echo $DASHSCOPE_API_KEY
```

确保输出非空即为成功。