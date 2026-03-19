import axios from 'axios';

// 使用相对路径，让Vite代理处理请求
const apiClient = axios.create({
  baseURL: '', // 使用相对路径
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

export interface ChatMessage {
  id: string;
  content: string;
  sender: 'user' | 'system';
  timestamp: Date;
  status: 'sending' | 'sent' | 'error';
}

export const chatService = {
  async sendMessage(message: string): Promise<string> {
    try {
      console.log('发送消息到API:', message);

      const response = await apiClient.get('/ai/routeAndExecute', {
        params: { str: message }
      });

      console.log('API响应状态:', response.status);
      console.log('API响应数据:', response.data);

      return response.data;
    } catch (error: unknown) {
      console.error('API调用失败:', error);

      if (axios.isAxiosError(error)) {
        console.error('错误详情:', error.response?.data || error.message);
        console.error('错误状态:', error.response?.status);
        console.error('错误headers:', error.response?.headers);
      } else if (error instanceof Error) {
        console.error('错误详情:', error.message);
      }

      throw new Error('发送消息失败，请稍后重试');
    }
  },

  generateMessageId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }
};
