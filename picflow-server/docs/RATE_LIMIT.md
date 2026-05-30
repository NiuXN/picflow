# PicFlow 接口限流说明

## 限流策略：令牌桶算法（Bucket4j）

## 已限流的接口

| 接口 | 限流配置 | 说明 |
|------|---------|------|
| `/auth/login` | `@RateLimit(capacity=5, refillTokens=5) | 每分钟最多 5 次 |
| `/auth/register` | `@RateLimit(capacity=5, refillTokens=5) | 每分钟最多 5 次 |
| `/auth/send-code` | `@RateLimit(capacity=3, refillTokens=3) | 每分钟最多 3 次 |
| `/auth/phone-login` | `@RateLimit(capacity=5, refillTokens=5) | 每分钟最多 5 次 |
| `/upload/image` | `@RateLimit(capacity=10, refillTokens=10) | 每分钟最多 10 次 |
| `/artworks` POST | `@RateLimit(capacity=10, refillTokens=10) | 每分钟最多 10 次 |

## 限流响应

当触发限流时，返回 HTTP 429 状态码：

```json
{
  "code": 429,
  "message": "请求过于频繁，请稍后再试"
}
```

响应头包含：
```
Retry-After: 60
```

表示需要等待 60 秒后重试。

## 限流规则

- **capacity**: 桶容量（最大突发请求数）
- **refillTokens**: 每个周期补充的令牌数
- **refillMinutes**: 令牌补充周期（分钟）
- **refillTokens**: 每个补充周期（refillMinutes）补充的令牌数

## 默认配置

如果接口未标记 `@RateLimit` 注解，则不进行限流。
