# Gateway Notify for Hermes

这是一个面向 **Hermes Agent** 的 `gateway-notify` 兼容分支。

它把原来为 **OpenClaw** 设计的“网关重启通知”思路，移植到了 **Hermes** 的网关、Hook 和消息投递体系上。

## 为什么要做这个分支

原项目是给 **OpenClaw** 用的，但 Hermes 的实现方式不同：

- Hook 目录不同
- Hook 清单格式不同
- 启动事件机制不同
- 消息发送方式不同
- 平台 home channel 路由方式不同

所以不能直接拿原版脚本和文档照搬，需要一个 **Hermes 原生版**。

## 这个项目解决什么问题

当 Hermes gateway 重启时，用户经常会遇到：

- 不知道 gateway 是否已经恢复在线
- 不知道重启是否成功
- 不知道上一条回复是不是因为重启被打断

这个项目解决的是：

> **“Hermes 重启后没有任何提示”**

也就是：

- gateway 启动后主动发一条通知
- 告诉你 Hermes 已恢复在线
- 提示你如果上一条消息被打断，可以回复 **“继续”**

## 它会做什么

在 `gateway:startup` 事件触发时，Hook 会向指定目标发送一条消息，内容包括：

- 启动时间
- 当前模型
- 当前已连接平台
- “如果上一条消息因为重启被打断，回复继续即可” 的提示

## 它不会做什么

这个项目 **不会自动恢复** 被重启打断的那条回复。

也就是说：

- ✅ 能解决：重启后无提示
- ✅ 能解决：用户不知道 Hermes 是否已经恢复
- ✅ 能解决：重启后的可见性问题
- ❌ 不能解决：自动接着发完被中断的回复

这是 Hermes 当前网关设计本身的限制：普通 in-flight 消息在重启时会被取消。

## 特性

- 🚀 Hermes gateway 启动后自动通知
- 💬 使用 Hermes 原生 `send_message` 路径发送消息
- 🌐 支持 Hermes 已连接的平台
- 🧩 基于 Hermes Hook 系统
- 🏠 支持 home channel 路由
- ⚙️ 用环境变量即可完成配置

## 适用于 Hermes 的机制

这个分支依赖以下 Hermes 原生能力：

- `gateway:startup` 生命周期事件
- `~/.hermes/hooks/` 用户 Hook 目录
- `HOOK.yaml + handler.py` Hook 结构
- Hermes `send_message` 工具
- 平台 home channel 配置
- `~/.hermes/.env` 环境变量配置

## 快速开始

### 1）安装 Hook

```bash
scripts/setup_gateway_notify.sh feishu
```

如果你已经配置了飞书 home channel，这样就够了。

### 2）或者指定明确目标

```bash
scripts/setup_gateway_notify.sh feishu oc_xxx
scripts/setup_gateway_notify.sh telegram -1001234567890
scripts/setup_gateway_notify.sh feishu:oc_xxx
```

### 3）重启 Hermes gateway

```bash
hermes gateway restart
```

重启完成后，Hook 会自动发送一条启动通知。

## 安装脚本说明

`scripts/setup_gateway_notify.sh` 会：

1. 把 Hook 安装到 `~/.hermes/hooks/gateway-restart-notify`
2. 把 `GATEWAY_NOTIFY_ENABLED=true` 写入 `~/.hermes/.env`
3. 把 `GATEWAY_NOTIFY_TARGETS=...` 写入 `~/.hermes/.env`
4. 提示你重启 gateway 以生效

默认 **不会自动重启**，避免打断你当前正在使用的聊天会话。

如果你想让脚本安装后自动重启：

```bash
scripts/setup_gateway_notify.sh feishu --restart
```

## 配置方式

### 最小配置：发到所有已配置 home channel

```bash
GATEWAY_NOTIFY_ENABLED=true
```

### 只发到飞书

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

### 发到多个目标

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu,telegram
```

### 指定明确 chat_id

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu:oc_xxx,telegram:-1001234567890
```

### 自定义模板

可用占位符：

- `{time}`
- `{model}`
- `{platforms}`

例如：

```bash
GATEWAY_NOTIFY_TEMPLATE=🚀 Hermes 已重启\n时间：{time}\n模型：{model}\n平台：{platforms}
```

## 示例通知

```text
🚀 Hermes gateway 已重启并恢复在线

⏰ Time: 2026-04-10 12:14:39
🤖 Model: gpt-5.4
🌐 Platforms: telegram, feishu

如果你上一条消息因为重启被打断，直接回复“继续”即可。
```

## 仓库定位建议

如果你要给这个 fork 写一句简介，我建议这样描述：

> Hermes-compatible port of gateway-notify. Adds restart notifications for Hermes gateway so users know the agent is back online after a restart.

或者中文：

> 这是一个面向 Hermes Agent 的 gateway-notify 兼容分支，用来解决 gateway 重启后“恢复在线但用户无感知”的问题。

## 后续可以继续增强的方向

- 只在“确实有一条消息被打断”时才发送通知
- 为 Hermes 提供更完整的安装向导
- 支持更多模板变量
- 支持更细粒度的平台/频道策略
- 以后如果 Hermes 原生支持“重启后恢复回复”，可进一步接入

## 许可证

MIT

## 致谢

灵感来自原始 `gateway-notify` 项目，这个分支对其思路进行了 **Hermes 兼容化移植**。
