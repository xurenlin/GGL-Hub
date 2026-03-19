# GGL AI 聊天室前端

这是一个基于Vue 3的聊天室前端应用，用于与GGL AI网关进行交互。

## 功能特性

- 🎨 现代化的聊天界面设计
- 💬 实时消息显示和自动滚动
- 🔄 消息发送状态反馈（发送中、成功、失败）
- 🎯 智能路由到不同后端服务（Order, Geo, AI等）
- 📱 响应式设计，支持移动端
- 🚀 快速开发服务器和热重载

## 技术栈

- **Vue 3** - 渐进式JavaScript框架
- **TypeScript** - 类型安全的JavaScript超集
- **Element Plus** - UI组件库
- **Vite** - 下一代前端构建工具
- **Axios** - HTTP客户端
- **Pinia** - 状态管理

## 项目结构

```
ggl-frontend-chat/
├── src/
│   ├── components/
│   │   └── ChatRoom.vue      # 主聊天室组件
│   ├── services/
│   │   └── api.ts           # API调用服务
│   ├── App.vue              # 根组件
│   └── main.ts              # 应用入口
├── public/
├── package.json
├── vite.config.ts          # Vite配置
└── README.md
```

## 快速开始

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

应用将在 http://localhost:3000 启动。

### 构建生产版本

```bash
npm run build
```

## API接口

前端应用通过Vite代理调用后端API：

- **后端地址**: http://localhost:9806
- **聊天接口**: `GET /ai/routeAndExecute?str={message}`

### 接口说明

`/ai/routeAndExecute` 接口会根据用户输入的内容智能路由到不同的服务：

1. **订单服务** - 当查询包含订单相关信息时
2. **地理位置服务** - 当查询包含地理位置信息时
3. **AI服务** - 其他类型的查询

## 配置说明

### Vite配置 (vite.config.ts)

```typescript
server: {
  port: 3000,
  proxy: {
    '/ai': {
      target: 'http://localhost:9806',
      changeOrigin: true,
      secure: false
    }
  }
}
```

### 环境变量

如果需要更改后端地址，可以修改 `src/services/api.ts` 中的 `API_BASE_URL`。

## 使用说明

1. 在输入框中输入您的问题
2. 按 Enter 键发送消息，或点击发送按钮
3. 系统会根据您的问题类型路由到相应的服务
4. 查看系统回复的消息

### 示例对话

- **用户**: "查询我的订单状态"
- **系统**: "【路由至 Order Service】: 正在查询订单..."

- **用户**: "北京到上海的路线"
- **系统**: "【路由至 Geo Service】: 正在处理坐标..."

- **用户**: "你好"
- **系统**: "【AI 回复】: 你好！有什么可以帮助您的吗？"

## 开发说明

### 添加新组件

```bash
# 在 components 目录下创建新的Vue组件
```

### 修改样式

应用使用Element Plus组件库，可以通过修改 `ChatRoom.vue` 中的样式来自定义界面。

### 扩展功能

1. **消息持久化**: 可以添加localStorage支持来保存聊天记录
2. **文件上传**: 可以扩展支持图片或文件上传
3. **用户认证**: 可以添加登录功能
4. **多语言**: 可以添加i18n支持

## 注意事项

1. 确保后端服务在 http://localhost:9806 运行
2. 如果后端端口变更，需要更新 `src/services/api.ts` 和 `vite.config.ts`
3. 生产环境需要配置正确的API地址

## 许可证

本项目基于MIT许可证。