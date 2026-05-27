# Verification Checklist

## 点赞/收藏持久化
- [x] Like 实体字段与 likes 表 DDL 一致（id, user_id, artwork_id, created_at）
- [x] Favorite 实体字段与 favorites 表 DDL 一致
- [x] POST `/artworks/{id}/like` 插入 likes 记录 + 原子更新 likes_count
- [x] 重复点赞返回 409 Conflict
- [x] DELETE `/artworks/{id}/like` 删除记录 + 原子更新 likes_count - 1（不会减到负数）
- [x] 作品列表返回 `is_liked` / `is_favorited` 字段（基于当前用户）
- [x] `mvn compile` 无编译错误

## Redis 缓存
- [x] `@EnableCaching` 已在启动类启用
- [x] RedisConfig 使用 Jackson2Json 序列化
- [x] 作品列表接口使用 `@Cacheable` 注解配置
- [x] 作品详情缓存 key 为 `artwork`（Spring Cache 管理）
- [x] 发布/删除作品后相关缓存被清除（@CacheEvict 配置）
- [x] 定时刷新缓存任务 `@Scheduled` 正常配置

## 上传安全校验
- [x] 仅允许 image/jpeg, image/png, image/webp
- [x] 文件扩展名同时校验 content-type 和扩展名
- [x] 上传超过 `picflow.upload.max-size（默认 10MB）文件被拒绝
- [x] 上传超过 4096px 图片被拒绝
- [x] 上传成功生成 300px 宽缩略图（Thumbnailator）
- [x] 返回 `url` 和 `thumbnailUrl` 两个字段

## 限流保护
- [x] `/upload/image` 超过 10次/分钟返回 429
- [x] `/auth/login` 超过 5次/分钟返回 429
- [x] `@RateLimit` 注解已创建
- [x] RateLimitInterceptor 令牌桶算法实现

## 通知系统
- [x] GET `/notifications` 返回分页通知列表
- [x] POST `/admin/notifications` 管理员可发布通知
- [x] 通知按时间倒序排列

## 用户管理 & 资料 API
- [x] GET `/admin/users` 支持分页和按 status 筛选
- [x] PUT `/admin/users/{id}/status` 可修改用户状态
- [x] GET `/admin/stats` 返回用户数、作品数、今日新增
- [x] GET `/auth/profile` 返回当前用户完整信息
- [x] PUT `/auth/profile` 可修改 nickname 和 bio

## 缺陷修复
- [x] PageResult 包含 totalPages 字段且值正确
- [x] MybatisPlusConfig DbType 根据 datasource URL 自动切换
- [x] `/uploads/**` 可公开访问无需认证
- [x] 评论查询返回子评论列表
- [x] `artwork_tags` 表在发布时同步写入
- [x] 种子用户密码可用于登录
