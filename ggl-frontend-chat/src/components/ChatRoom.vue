<template>
  <div class="chat-room">
    <div class="chat-header">
      <h2>GGL AI 聊天室</h2>
      <p class="subtitle">智能路由与执行系统</p>
    </div>

    <div class="chat-container">
      <!-- 消息列表区域 -->
      <div class="message-list" ref="messageListRef">
        <div v-if="messages.length === 0" class="empty-state">
          <el-icon :size="48" color="#909399">
            <ChatLineRound />
          </el-icon>
          <p>开始对话吧！输入消息并发送</p>
        </div>

        <div
          v-for="message in messages"
          :key="message.id"
          :class="['message-item', message.sender]"
        >
          <div class="message-avatar">
            <el-avatar
              :size="32"
              :style="{
                backgroundColor: message.sender === 'user' ? '#409EFF' : '#67C23A'
              }"
            >
              {{ message.sender === 'user' ? '我' : 'AI' }}
            </el-avatar>
          </div>
          <div class="message-content">
            <div class="message-header">
              <span class="sender-name">
                {{ message.sender === 'user' ? '我' : 'GGL AI' }}
              </span>
              <span class="message-time">
                {{ formatTime(message.timestamp) }}
              </span>
            </div>
            <div class="message-body">
              <div v-if="message.status === 'sending'" class="sending-indicator">
                <el-icon class="is-loading">
                  <Loading />
                </el-icon>
                发送中...
              </div>
              <div v-else-if="message.status === 'error'" class="error-message">
                <el-icon color="#F56C6C">
                  <Warning />
                </el-icon>
                发送失败: {{ message.content }}
              </div>
              <div v-else class="message-text">
                {{ message.content }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 输入区域 -->
      <div class="input-area">
        <div class="input-wrapper">
          <el-input
            v-model="inputMessage"
            type="textarea"
            :rows="3"
            placeholder="请输入您的问题..."
            :disabled="isSending"
            @keydown.enter.exact.prevent="handleSendMessage"
          />
          <div class="input-actions">
            <el-button
              type="primary"
              :loading="isSending"
              :disabled="!inputMessage.trim()"
              @click="handleSendMessage"
            >
              <template #icon>
                <el-icon><Promotion /></el-icon>
              </template>
              发送
            </el-button>
            <el-button
              type="info"
              :disabled="messages.length === 0"
              @click="clearMessages"
            >
              <template #icon>
                <el-icon><Delete /></el-icon>
              </template>
              清空
            </el-button>
          </div>
        </div>
        <div class="input-hint">
          <el-icon><InfoFilled /></el-icon>
          按 Enter 发送，Shift+Enter 换行
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted, onUpdated } from 'vue'
import { ElMessage } from 'element-plus'
import {
  ChatLineRound,
  Loading,
  Warning,
  Promotion,
  Delete,
  InfoFilled
} from '@element-plus/icons-vue'
import { chatService, type ChatMessage } from '@/services/api'

const messages = ref<ChatMessage[]>([])
const inputMessage = ref('')
const isSending = ref(false)
const messageListRef = ref<HTMLElement>()

// 滚动到最新消息
const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  })
}

// 格式化时间
const formatTime = (date: Date) => {
  return date.toLocaleTimeString('zh-CN', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 发送消息
const handleSendMessage = async () => {
  const content = inputMessage.value.trim()
  if (!content || isSending.value) return

  // 创建用户消息
  const userMessage: ChatMessage = {
    id: chatService.generateMessageId(),
    content,
    sender: 'user',
    timestamp: new Date(),
    status: 'sending'
  }

  messages.value.push(userMessage)
  inputMessage.value = ''
  isSending.value = true
  scrollToBottom()

  try {
    // 发送到API
    const response = await chatService.sendMessage(content)

    // 更新用户消息状态
    userMessage.status = 'sent'

    // 创建系统回复
    const systemMessage: ChatMessage = {
      id: chatService.generateMessageId(),
      content: response,
      sender: 'system',
      timestamp: new Date(),
      status: 'sent'
    }

    messages.value.push(systemMessage)
    scrollToBottom()
  } catch (error) {
    // 更新用户消息状态为错误
    userMessage.status = 'error'
    userMessage.content = error instanceof Error ? error.message : '未知错误'

    ElMessage.error('发送消息失败，请检查网络连接或稍后重试')
  } finally {
    isSending.value = false
  }
}

// 清空消息
const clearMessages = () => {
  messages.value = []
  ElMessage.success('已清空聊天记录')
}

// 初始化时添加欢迎消息
onMounted(() => {
  const welcomeMessage: ChatMessage = {
    id: chatService.generateMessageId(),
    content: '您好！我是GGL AI助手，我可以帮您处理订单查询、地理位置分析等问题。请问有什么可以帮您的？',
    sender: 'system',
    timestamp: new Date(),
    status: 'sent'
  }
  messages.value.push(welcomeMessage)
})

// 消息更新时自动滚动
onUpdated(() => {
  scrollToBottom()
})
</script>

<style scoped>
.chat-room {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  overflow: hidden;
}

.chat-header {
  padding: 20px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  text-align: center;
  flex-shrink: 0;
}

.chat-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.chat-header .subtitle {
  margin: 8px 0 0;
  font-size: 14px;
  opacity: 0.8;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  padding: 20px;
  min-height: 0; /* 重要：允许flex子元素收缩 */
}

.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 12px;
  margin-bottom: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  min-height: 0; /* 重要：允许滚动 */
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #909399;
  text-align: center;
}

.empty-state p {
  margin-top: 16px;
  font-size: 16px;
}

.message-item {
  display: flex;
  margin-bottom: 24px;
  animation: fadeIn 0.3s ease;
}

.message-item.user {
  flex-direction: row-reverse;
}

.message-avatar {
  flex-shrink: 0;
  margin: 0 12px;
}

.message-content {
  max-width: 70%;
}

.message-item.user .message-content {
  align-items: flex-end;
}

.message-header {
  display: flex;
  align-items: center;
  margin-bottom: 8px;
  font-size: 12px;
  color: #909399;
}

.message-item.user .message-header {
  flex-direction: row-reverse;
}

.sender-name {
  font-weight: 600;
  margin-right: 8px;
}

.message-item.user .sender-name {
  margin-right: 0;
  margin-left: 8px;
}

.message-time {
  opacity: 0.7;
}

.message-body {
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.5;
}

.message-item.user .message-body {
  background: #409EFF;
  color: white;
  border-bottom-right-radius: 4px;
}

.message-item.system .message-body {
  background: #f0f9ff;
  color: #303133;
  border-bottom-left-radius: 4px;
  border: 1px solid #e4e7ed;
}

.sending-indicator {
  display: flex;
  align-items: center;
  color: #909399;
}

.sending-indicator .el-icon {
  margin-right: 8px;
}

.error-message {
  display: flex;
  align-items: center;
  color: #F56C6C;
}

.error-message .el-icon {
  margin-right: 8px;
}

.input-area {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.input-wrapper {
  margin-bottom: 12px;
}

.input-actions {
  display: flex;
  gap: 12px;
  margin-top: 12px;
}

.input-hint {
  display: flex;
  align-items: center;
  font-size: 12px;
  color: #909399;
}

.input-hint .el-icon {
  margin-right: 6px;
  font-size: 14px;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 滚动条样式 */
.message-list::-webkit-scrollbar {
  width: 6px;
}

.message-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.message-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.message-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
