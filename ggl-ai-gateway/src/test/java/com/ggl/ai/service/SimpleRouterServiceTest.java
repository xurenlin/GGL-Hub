package com.ggl.ai.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.lang.reflect.Field;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.output.Response;

@ExtendWith(MockitoExtension.class)
public class SimpleRouterServiceTest {

    @Mock
    private ChatLanguageModel mockModel;

    @InjectMocks
    private SimpleRouterService service;

    @BeforeEach
    void setUp() throws Exception {
        // 如果没有使用 @InjectMocks，可以手动注入
        service = new SimpleRouterService();

        // 使用反射注入 mock 对象（因为 model 是 final 字段）
        Field modelField = SimpleRouterService.class.getDeclaredField("model");
        modelField.setAccessible(true);
        modelField.set(service, mockModel);

        // 设置 systemPrompt（如果通过 @Value 注入）
        ReflectionTestUtils.setField(service, "systemPrompt",
                "你是一个物流AI助手，请分析用户查询并返回路由指令（ORDER/GEO/OTHER）");
    }

    @Nested
    @DisplayName("意图分类测试")
    class IntentClassificationTests {

        @Test
        @DisplayName("当模型返回ORDER时，应路由到订单服务")
        void shouldRouteToOrderService_whenIntentIsOrder() {
            // 准备
            String userQuery = "查询我的订单状态";
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse("ORDER"));

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertEquals("【路由至 Order Service】: 正在查询订单...", result);
            verify(mockModel).generate(anyList());
        }

        @Test
        @DisplayName("当模型返回GEO时，应路由到地理服务")
        void shouldRouteToGeoService_whenIntentIsGeo() {
            // 准备
            String userQuery = "转换经纬度坐标";
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse("GEO"));

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertEquals("【路由至 Geo Service】: 正在处理坐标...", result);
        }

        @Test
        @DisplayName("当模型返回OTHER时，应使用AI回复")
        void shouldUseAiReply_whenIntentIsOther() {
            // 准备
            String userQuery = "今天天气怎么样";

            // 使用更精确的参数匹配
            when(mockModel.generate(ArgumentMatchers.<List<ChatMessage>>any()))
                    .thenReturn(createMockResponse("OTHER"));

            when(mockModel.generate(ArgumentMatchers.<String>any()))
                    .thenReturn("今天天气晴朗，温度25℃");

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertEquals("【AI 回复】: 今天天气晴朗，温度25℃", result);

            // 验证具体参数类型
            verify(mockModel, times(1)).generate(ArgumentMatchers.<List<ChatMessage>>any());
            verify(mockModel, times(1)).generate(ArgumentMatchers.<String>any());
        }
    }

    @Nested
    @DisplayName("异常处理测试")
    class ExceptionHandlingTests {

        @Test
        @DisplayName("当模型调用抛出异常时，应返回错误信息")
        void shouldReturnErrorMessage_whenModelThrowsException() {
            // 准备
            String userQuery = "测试查询";
            when(mockModel.generate(anyList()))
                    .thenThrow(new RuntimeException("API调用失败"));

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertTrue(result.startsWith("【错误】: AI服务暂时不可用"));
            assertTrue(result.contains("API调用失败"));
        }

        @Test
        @DisplayName("当模型返回null时，应优雅处理")
        void shouldHandleNullIntent() {
            // 准备
            String userQuery = "测试查询";
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse(null));

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertNotNull(result);
            // 根据你的代码逻辑，可能会进入默认分支
        }
    }

    @Nested
    @DisplayName("集成测试（使用真实模型）")
    class IntegrationTests {

        // 这些测试会调用真实的 API，需要配置 API Key
        private SimpleRouterService realService;

        @BeforeEach
        void setUp() {
            realService = new SimpleRouterService();
            // 确保环境变量 OPENAI_API_KEY 已设置
        }

        @Test
        @DisplayName("实际调用API测试订单意图")
        void testWithRealApi_orderIntent() {
            // 跳过如果没有 API Key
            String apiKey = System.getenv("OPENAI_API_KEY");
            if (apiKey == null || apiKey.isEmpty()) {
                fail("请设置 OPENAI_API_KEY 环境变量来运行此测试");
            }

            String userQuery = "我想查询订单号123456的物流信息";
            String result = realService.routeAndExecute(userQuery);

            assertNotNull(result);
            System.out.println("实际API返回: " + result);
        }
    }

    @Nested
    @DisplayName("边界条件测试")
    class BoundaryTests {

        @Test
        @DisplayName("处理空字符串输入")
        void handleEmptyQuery() {
            // 准备
            String userQuery = "";
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse("CHAT"));
            when(mockModel.generate(""))
                    .thenReturn("请输入有效内容");

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertNotNull(result);
        }

        @Test
        @DisplayName("处理超长输入")
        void handleVeryLongQuery() {
            // 准备
            String userQuery = "a".repeat(10000); // 1万个字符
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse("CHAT"));
            when(mockModel.generate(eq(userQuery)))
                    .thenReturn("已处理超长输入");

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertNotNull(result);
        }

        @Test
        @DisplayName("处理特殊字符输入")
        void handleSpecialCharacters() {
            // 准备
            String userQuery = "!@#$%^&*()_+{}:\"<>?[];',./";
            when(mockModel.generate(anyList()))
                    .thenReturn(createMockResponse("CHAT"));
            when(mockModel.generate(eq(userQuery)))
                    .thenReturn("已处理特殊字符");

            // 执行
            String result = service.routeAndExecute(userQuery);

            // 验证
            assertNotNull(result);
        }
    }

    // ==================== 辅助方法 ====================

    private Response<AiMessage> createMockResponse(String text) {
        AiMessage aiMessage = new AiMessage(text);
        return Response.from(aiMessage);
    }

    /**
     * 不依赖 Mockito 的手动测试方法
     */
    @Test
    @DisplayName("手动测试：使用代理模型")
    void manualTestWithProxyModel() throws Exception {
        // 创建代理模型
        ChatLanguageModel proxyModel = createProxyModel();

        // 注入到服务
        SimpleRouterService testService = new SimpleRouterService();
        Field modelField = SimpleRouterService.class.getDeclaredField("model");
        modelField.setAccessible(true);
        modelField.set(testService, proxyModel);

        // 测试订单意图
        String orderResult = testService.routeAndExecute("查询订单");
        assertEquals("【路由至 Order Service】: 正在查询订单...", orderResult);

        // 测试地理意图
        String geoResult = testService.routeAndExecute("转换坐标");
        assertEquals("【路由至 Geo Service】: 正在处理坐标...", geoResult);

        // 测试闲聊意图
        String chatResult = testService.routeAndExecute("你好");
        assertTrue(chatResult.startsWith("【AI 回复】:"));
    }

    /**
     * 创建代理模型（用于不依赖 Mockito 的测试）
     */
    private ChatLanguageModel createProxyModel() {
        return (ChatLanguageModel) java.lang.reflect.Proxy.newProxyInstance(
                ChatLanguageModel.class.getClassLoader(),
                new Class[] { ChatLanguageModel.class },
                (proxy, method, args) -> {
                    String methodName = method.getName();

                    if ("generate".equals(methodName)) {
                        if (args != null && args.length > 0) {
                            Object arg = args[0];
                            String argStr = arg.toString();

                            // 模拟意图分类
                            if (argStr.contains("订单") || argStr.contains("order")) {
                                return createMockResponse("ORDER");
                            } else if (argStr.contains("坐标") || argStr.contains("geo")) {
                                return createMockResponse("GEO");
                            } else if (argStr instanceof String) {
                                // 模拟AI回复
                                return "模拟回复: " + argStr;
                            }
                        }
                        return createMockResponse("CHAT");
                    }

                    // 返回默认值
                    Class<?> returnType = method.getReturnType();
                    if (returnType.isPrimitive()) {
                        if (returnType == boolean.class)
                            return false;
                        if (returnType == int.class)
                            return 0;
                        if (returnType == long.class)
                            return 0L;
                    }
                    return null;
                });
    }
}