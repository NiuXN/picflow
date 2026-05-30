package com.picflow.server.interceptor;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.picflow.server.annotation.RateLimit;
import com.picflow.server.common.ErrorCode;
import com.picflow.server.common.Result;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 限流拦截器，基于 Bucket4j 令牌桶算法
 *
 * 限流规则说明：
 * - capacity：桶容量（最大突发请求数）
 * - refillTokens：每分钟补充的令牌数
 * - refillMinutes：补充时间周期（分钟）
 *
 * 使用示例：
 * <pre>{@code
 * @RateLimit(capacity = 10, refillTokens = 10, refillMinutes = 1)
 * }</pre>
 * 表示：每分钟最多 10 次请求，突发最多 10 次
 */
@Component
public class RateLimitInterceptor implements HandlerInterceptor {

    private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {
        if (!(handler instanceof HandlerMethod handlerMethod)) {
            return true;
        }

        RateLimit rateLimit = handlerMethod.getMethodAnnotation(RateLimit.class);
        if (rateLimit == null) {
            return true;
        }

        String ip = request.getRemoteAddr();
        String methodPath = request.getRequestURI();
        String key = ip + ":" + methodPath;

        Bucket bucket = buckets.computeIfAbsent(key, k -> Bucket.builder()
                .addLimit(Bandwidth.classic(rateLimit.capacity(),
                        Refill.greedy(rateLimit.refillTokens(),
                                Duration.ofMinutes(rateLimit.refillMinutes()))))
                .build());

        if (bucket.tryConsume(1)) {
            return true;
        }

        response.setStatus(429);
        response.setHeader("Retry-After", String.valueOf(rateLimit.refillMinutes() * 60));
        response.setContentType("application/json;charset=UTF-8");

        Result<Void> result = Result.error(ErrorCode.TOO_MANY_REQUESTS);
        response.getWriter().write(objectMapper.writeValueAsString(result));
        return false;
    }
}