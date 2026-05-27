package com.picflow.server.interceptor;

import com.picflow.server.annotation.RateLimit;
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

@Component
public class RateLimitInterceptor implements HandlerInterceptor {

    private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();

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
        response.getWriter().write("{\"code\": 429, \"message\": \"请求过于频繁，请稍后再试\"}");
        return false;
    }
}