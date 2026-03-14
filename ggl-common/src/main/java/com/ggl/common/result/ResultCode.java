package com.ggl.common.result;

import lombok.Getter;
import lombok.AllArgsConstructor;

/**
 * 响应状态码枚举
 *
 * @author GGL-Hub
 */
@Getter
@AllArgsConstructor
public enum ResultCode {

    // ========== 成功 ==========
    SUCCESS(200, "操作成功"),

    // ========== 客户端错误 4xx ==========
    FAIL(400, "操作失败"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权，请先登录"),
    FORBIDDEN(403, "没有权限访问"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方法不允许"),
    REQUEST_TIMEOUT(408, "请求超时"),
    CONFLICT(409, "资源冲突"),
    TOO_MANY_REQUESTS(429, "请求过于频繁，请稍后再试"),

    // ========== 服务端错误 5xx ==========
    INTERNAL_ERROR(500, "服务器内部错误"),
    SERVICE_UNAVAILABLE(503, "服务暂不可用"),
    GATEWAY_TIMEOUT(504, "网关超时"),

    // ========== 业务错误 1xxx ==========
    PARAM_VALIDATION_ERROR(1001, "参数校验失败"),
    DATA_NOT_FOUND(1002, "数据不存在"),
    DATA_ALREADY_EXISTS(1003, "数据已存在"),
    DATA_OPERATION_FAILED(1004, "数据操作失败"),

    // ========== 用户相关 2xxx ==========
    USER_NOT_FOUND(2001, "用户不存在"),
    USER_PASSWORD_ERROR(2002, "密码错误"),
    USER_DISABLED(2003, "用户已禁用"),
    USER_TOKEN_EXPIRED(2004, "登录已过期，请重新登录"),
    USER_TOKEN_INVALID(2005, "无效的Token"),

    // ========== 订单相关 3xxx ==========
    ORDER_NOT_FOUND(3001, "订单不存在"),
    ORDER_STATUS_ERROR(3002, "订单状态异常"),
    ORDER_CREATE_FAILED(3003, "订单创建失败"),
    ORDER_CANCEL_FAILED(3004, "订单取消失败"),

    // ========== 地理信息相关 4xxx ==========
    GEO_COORDINATE_INVALID(4001, "坐标无效"),
    GEO_ADDRESS_NOT_FOUND(4002, "地址解析失败"),
    GEO_ROUTE_FAILED(4003, "路径规划失败"),

    // ========== 国际化相关 5xxx ==========
    I18N_LOCALE_NOT_SUPPORTED(5001, "不支持的语言"),
    I18N_TRANSLATION_FAILED(5002, "翻译失败"),

    // ========== AI相关 6xxx ==========
    AI_SERVICE_ERROR(6001, "AI服务异常"),
    AI_CONTENT_BLOCKED(6002, "内容被安全策略拦截"),
    AI_RATE_LIMITED(6003, "AI请求频率超限"),
    AI_MODEL_NOT_AVAILABLE(6004, "AI模型暂不可用"),

    // ========== 外部服务错误 9xxx ==========
    EXTERNAL_SERVICE_ERROR(9001, "外部服务调用失败"),
    EXTERNAL_SERVICE_TIMEOUT(9002, "外部服务调用超时");

    /**
     * 状态码
     */
    private final Integer code;

    /**
     * 消息
     */
    private final String message;
}
