# HEARTBEAT.md

# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.

---

## 定时任务配置

### 每日早安问候
- **时间**: 每天早上 7:00
- **目标**: PTX-EMU 群聊
- **内容**: 问候语 + 日期

```yaml
tasks:
  - name: morning_greeting_ptx
    schedule: "0 7 * * *"
    action: message
    channel: feishu
    target: "chat:oc_1a4d6efab29f92943a9ad7ee1660a307"
    message: |
      🦊 早上好，DevMate！
      
      新的一天，代码无 bug！
      日期：{{date}}
      
      - CTO 自动问候
```

---

## 群聊列表

| 群聊名称 | Chat ID | 绑定项目 | 状态 |
|---------|---------|---------|------|
| PTX-EMU | oc_1a4d6efab29f92943a9ad7ee1660a307 | PTX-EMU | ✅ 已配置 |
| TaskRunner | oc_6f95fc3117bd54c5b5c7aa8b53481e65 | TaskRunner | ✅ 已配置 |
| UsrLinuxEmu | oc_e476c24a1ba06dfa5ca9ed2a2f0156f4 | UsrLinuxEmu | ✅ 已配置 |

---

## 配置说明

1. **Cron 格式**: `分 时 日 月 周`
   - `0 7 * * *` = 每天 7:00
   - `0 8 * * 1-5` = 工作日 8:00

2. **添加新群聊**:
   - 在"群聊列表"表格中添加
   - 在 tasks 数组中添加新任务

3. **测试定时任务**:
   - 手动触发：等待下一个调度周期
   - 或临时修改时间为测试时间
