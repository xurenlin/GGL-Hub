package com.ggl.common.constant;

/**
 * 公共常量类
 *
 * @author GGL-Hub
 */
public class CommonConstants {

    /**
     * 请求头常量
     */
    public static class Headers {
        public static final String TRACE_ID = "X-Trace-Id";
        public static final String USER_ID = "X-User-Id";
        public static final String USER_NAME = "X-User-Name";
        public static final String AUTHORIZATION = "Authorization";
        public static final String LANGUAGE = "Accept-Language";
        public static final String TIMEZONE = "X-Timezone";
    }

    /**
     * 日期时间格式
     */
    public static class DateFormat {
        public static final String DATE_TIME = "yyyy-MM-dd HH:mm:ss";
        public static final String DATE = "yyyy-MM-dd";
        public static final String TIME = "HH:mm:ss";
        public static final String ISO_DATE_TIME = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    }

    /**
     * 字符集
     */
    public static class Charset {
        public static final String UTF8 = "UTF-8";
        public static final String GBK = "GBK";
    }

    /**
     * 分隔符
     */
    public static class Separator {
        public static final String COMMA = ",";
        public static final String SEMICOLON = ";";
        public static final String COLON = ":";
        public static final String SLASH = "/";
        public static final String BACKSLASH = "\\";
        public static final String UNDERSCORE = "_";
        public static final String DASH = "-";
        public static final String DOT = ".";
        public static final String PIPE = "|";
    }

    /**
     * 正则表达式
     */
    public static class Regex {
        public static final String EMAIL = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        public static final String PHONE = "^1[3-9]\\d{9}$";
        public static final String IP = "^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\\.){3}(25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$";
        public static final String URL = "^(https?|ftp)://[^\\s/$.?#].[^\\s]*$";
    }

    /**
     * 系统常量
     */
    public static class System {
        public static final String DEFAULT_LANGUAGE = "zh-CN";
        public static final String DEFAULT_TIMEZONE = "Asia/Shanghai";
        public static final String DEFAULT_ENCODING = "UTF-8";
        public static final String APPLICATION_NAME = "GGL-Hub";
    }

    /**
     * 缓存键前缀
     */
    public static class CacheKey {
        public static final String USER = "user:";
        public static final String ORDER = "order:";
        public static final String GEO = "geo:";
        public static final String I18N = "i18n:";
        public static final String AI = "ai:";
        public static final String RATE_LIMIT = "rate_limit:";
    }

    /**
     * 状态常量
     */
    public static class Status {
        public static final Integer ENABLED = 1;
        public static final Integer DISABLED = 0;
        public static final Integer DELETED = -1;
    }

    /**
     * 排序常量
     */
    public static class Sort {
        public static final String ASC = "ASC";
        public static final String DESC = "DESC";
    }
}
