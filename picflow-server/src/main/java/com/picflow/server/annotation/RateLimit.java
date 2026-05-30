package com.picflow.server.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 接口限流注解，配合 RateLimitInterceptor 使用
 *
 * 限流策略：令牌桶算法
 *
 * 示例配置：
 * <pre>{@code
 * // 登录接口：每分钟最多 5 次
 * @RateLimit(capacity = 5, refillTokens = 5, refillMinutes = 1)
 *
 * // 上传接口：每分钟最多 10 次
 * @RateLimit(capacity = 10, refillTokens = 10, refillMinutes = 1)
 *
 * // 敏感操作：每分钟最多 3 次
 * @RateLimit(capacity = 3, refillTokens = 3, refillMinutes = 1)
 * }</pre>
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RateLimit {

    /**
     * 桶容量（最大突发请求数）
     */
    int capacity() default 10;

    /**
     * 每个周期补充的令牌数（正常请求速率）
     */
    int refillTokens() default 10;

    /**
     * 补充周期（分钟）
     */
    int refillMinutes() default 1;
}