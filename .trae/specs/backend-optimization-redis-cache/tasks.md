# Tasks

- [x] **Task 1: 修复点赞/收藏持久化（P0 紧急）**
  - [x] 1.1 创建 `Like.java` 和 `Favorite.java` 实体（对应 likes/favorites 表）
  - [x] 1.2 创建 `LikeMapper.java`、`FavoriteMapper.java`
  - [x] 1.3 创建 `LikeService.java` / `LikeServiceImpl.java`（插入、删除、查询、去重检查）
  - [x] 1.4 创建 `FavoriteService.java` / `FavoriteServiceImpl.java`
  - [x] 1.5 重写 `ArtworkController.java` 的 POST/DELETE `/like` 和 `/favorite` 端点：操作 likes/favorites 表 + 原子更新 artworks 表 count
  - [x] 1.6 作品列表接口返回 `is_liked` / `is_favorited` 字段（通过当前用户 ID JOIN 查询 likes/favorites 表）
  - [x] 1.7 验证：`mvn test` 确认点赞/收藏无重复、count 正确

- [x] **Task 2: Redis 缓存层**
  - [x] 2.1 创建 `RedisConfig.java`（Jackson2JsonRedisSerializer 序列化、TTL 配置）
  - [x] 2.2 `PicFlowApplication.java` 添加 `@EnableCaching` 和 `@EnableScheduling`
  - [x] 2.3 `ArtworkServiceImpl.getArtworksInternal()` 添加 `@Cacheable(value="artworks:list", key="{#page,#size,#sort,#tag}")` TTL=5min
  - [x] 2.4 `ArtworkServiceImpl.getArtworkDetail()` 添加 `@Cacheable(value="artwork", key="#id", unless="#result == null")`
  - [x] 2.5 写操作（publish）添加 `@CacheEvict` 清除相关缓存
  - [x] 2.6 添加 `@Scheduled(fixedRate=600000)` 定时任务：每 10 分钟刷新缓存
  - [x] 2.7 `application.yml` dev profile 添加 Redis 配置
  - [x] 2.8 验证：`mvn compile` 编译通过

- [x] **Task 3: 上传安全校验 + 缩略图生成**
  - [x] 3.1 `UploadController.java` 添加文件类型白名单校验（仅允许 image/jpeg, image/png, image/webp）
  - [x] 3.2 添加文件大小校验（读取 `picflow.upload.max-size` 配置，默认 10MB）
  - [x] 3.3 添加图片尺寸校验（宽高 ≤ 4096px）
  - [x] 3.4 使用 Thumbnailator 生成 300px 宽缩略图，保存到 `thumb_` 前缀文件
  - [x] 3.5 返回原图 URL + 缩略图 URL
  - [x] 3.6 `ArtworkServiceImpl.publishArtwork()` 已支持 `thumbnailUrl` 字段
  - [x] 3.7 验证：`mvn compile` 编译通过

- [x] **Task 4: 限流保护**
  - [x] 4.1 pom.xml 已添加 Bucket4j 依赖（已存在）
  - [x] 4.2 创建 `RateLimitInterceptor.java`（基于 IP 的令牌桶，每分钟 N 次）
  - [x] 4.3 创建 `@RateLimit` 注解（可配置 capacity/refillRate/refillMinutes）
  - [x] 4.4 对 `/upload/image` 限制 10次/分钟
  - [x] 4.5 对 `/auth/login` 限制 5次/分钟
  - [x] 4.6 对 `/artworks/*/like` 限制 30次/分钟
  - [x] 4.7 验证：`mvn compile` 编译通过

- [x] **Task 5: 通知系统**
  - [x] 5.1 创建 `NotificationService.java` / `NotificationServiceImpl.java`（分页查询、创建通知）
  - [x] 5.2 创建 `NotificationController.java`（GET `/notifications`）
  - [x] 5.3 `AdminController.java` 新增 `POST /admin/notifications` 端点
  - [x] 5.4 `SecurityConfig.java` 将 `/notifications/**` 加入 permitAll()
  - [x] 5.5 验证：`mvn compile` 编译通过

- [x] **Task 6: 用户管理 Admin API + 用户资料 API**
  - [x] 6.1 `AdminController.java` 新增 `GET /admin/users`（分页 + 按 status 筛选）
  - [x] 6.2 `AdminController.java` 新增 `PUT /admin/users/{id}/status`（封禁/解封）
  - [x] 6.3 `AdminController.java` 新增 `GET /admin/stats`（用户数、作品数、今日新增）
  - [x] 6.4 `AuthController.java` 新增 `GET /auth/profile`（返回当前用户信息）
  - [x] 6.5 `AuthController.java` 新增 `PUT /auth/profile`（修改 nickname/bio）
  - [x] 6.6 验证：`mvn compile` 编译通过

- [x] **Task 7: 缺陷修复（已有代码）**
  - [x] 7.1 `PageResult.java` 新增 `totalPages` 字段，`of()` 方法自动计算
  - [x] 7.2 `MybatisPlusConfig.java` 根据 datasource URL 动态设置 `DbType`（H2 vs POSTGRE_SQL）
  - [x] 7.3 `SecurityConfig.java` 将 `/uploads/**` 加入 `permitAll()`
  - [x] 7.4 `CommentServiceImpl.getComments()` 修复：子评论赋值到 Comment 对象返回
  - [x] 7.5 `ArtworkServiceImpl.java` 标签搜索改为 JOIN `artwork_tags` 表
  - [x] 7.6 发布作品时同步写入 `artwork_tags` 表
  - [x] 7.7 `schema-h2.sql` 种子用户密码修正为可用的 BCrypt 哈希
  - [x] 7.8 验证：`mvn compile` 编译通过

# Task Dependencies
- **Task 2** 依赖 Task 1 ✅（已完成）
- **Task 3** 依赖 Task 2 ✅（已完成）
- **Task 5** 可与 Task 4 并行 ✅（已完成）
- **Task 6** 可与 Task 5 并行 ✅（已完成）
- **Task 7** 可与 Task 1-3 并行 ✅（已完成）
