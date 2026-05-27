# PicFlow 后端优化与 Redis 缓存 Spec

## Why
当前后端在以下关键方面存在缺失或实现缺陷：点赞/收藏无持久化记录、无 Redis 缓存层导致高频接口直连数据库、文件上传无安全校验、图片无缩略图生成、通知系统和用户管理 API 完全缺失。这些问题在用户量增长后将直接影响系统稳定性和安全性。

## What Changes
- 新增 Redis 缓存层，加速作品列表/详情/热门作品查询
- **BREAKING** 修复点赞/收藏实现：从直接修改 count 字段改为操作 likes/favorites 表
- 新增图片上传安全校验（类型/大小/尺寸）
- 新增图片缩略图自动生成
- 新增通知系统（Service + Controller）
- 新增用户管理 Admin API（封禁/解封/统计）
- 新增限流保护（Bucket4j + Redis）
- 修复 PageResult 缺少 totalPages、MybatisPlusConfig 硬编码 H2、CommentServiceImpl 回复未返回等缺陷

## Impact
- Affected specs: 无（首次优化）
- Affected code: 
  - 修改：ArtworkController.java（点赞/收藏逻辑重写）、ArtworkServiceImpl.java（tag 搜索优化）、UploadController.java（安全校验+缩略图）、AdminController.java（扩充功能）、MybatisPlusConfig.java、SecurityConfig.java、PicFlowApplication.java、PageResult.java、CommentServiceImpl.java
  - 新增：Like/Favorite 实体+Mapper+Service、NotificationService+Controller、RedisConfig、FileStorageService、限流配置

---

## ADDED Requirements

### Requirement: Redis 缓存层
系统 SHALL 通过 Redis 对高频读取接口进行缓存，减少数据库压力。

#### Scenario: 作品列表缓存命中
- **WHEN** 客户端请求 `/artworks?page=1&size=20&sort=latest`
- **THEN** 系统优先从 Redis 读取缓存的 JSON 数据，TTL 为 5 分钟
- **AND** 缓存未命中时查询数据库并写入 Redis

#### Scenario: 作品详情缓存
- **WHEN** 客户端请求 `/artworks/{id}`
- **THEN** 系统从 Redis key `artwork:{id}` 读取缓存
- **AND** 当作品状态变更（审核/删除）时主动清除缓存

#### Scenario: 热门作品缓存
- **WHEN** 客户端请求 `/artworks/trending`
- **THEN** 系统从 Redis ZSet `artwork:trending` 按分数降序返回
- **AND** 定时任务每 10 分钟根据 likes_count 刷新热门排行

### Requirement: 点赞记录持久化
系统 SHALL 在 likes 表中记录每次点赞行为，支持去重和撤销。

#### Scenario: 用户首次点赞
- **WHEN** POST `/artworks/{id}/like` 且 likes 表中无此 (user_id, artwork_id) 记录
- **THEN** 插入一条 likes 记录
- **AND** 原子更新 artworks 表的 likes_count + 1
- **AND** 返回 `{"is_liked": true, "likes_count": N}`

#### Scenario: 用户重复点赞
- **WHEN** 用户再次 POST `/artworks/{id}/like`
- **THEN** 返回 409 Conflict "已经点过赞了"

#### Scenario: 取消点赞
- **WHEN** DELETE `/artworks/{id}/like` 且记录存在
- **THEN** 删除 likes 记录
- **AND** 原子更新 artworks 表的 likes_count - 1

### Requirement: 收藏记录持久化
系统 SHALL 在 favorites 表中记录每次收藏行为，规则与点赞一致。

### Requirement: 上传安全校验
系统 SHALL 在文件上传时进行安全校验。

#### Scenario: 上传合法图片
- **WHEN** 用户上传 content-type 为 `image/jpeg`、大小 ≤ 10MB、尺寸 ≤ 4096×4096 的图片
- **THEN** 接受上传，返回 CDN URL

#### Scenario: 上传非法文件
- **WHEN** 用户上传 content-type 为 `text/html` 的文件
- **THEN** 返回 400 "不支持的文件类型，仅允许 jpg/png/webp"

### Requirement: 缩略图自动生成
系统 SHALL 在上传图片时自动生成 300px 宽的缩略图。

#### Scenario: 上传后生成缩略图
- **WHEN** 图片上传成功
- **THEN** 使用 Thumbnailator 生成 300px 等宽缩略图
- **AND** 缩略图与原图一起存储，`thumbnail_url` 存入 artworks 表

### Requirement: 通知系统
系统 SHALL 支持管理员发布公告通知，用户可查看通知列表。

#### Scenario: 管理员发布通知
- **WHEN** POST `/admin/notifications` 携带 `{title, content}`
- **THEN** 插入 notifications 表，target 默认为 "all"

#### Scenario: 用户获取通知列表
- **WHEN** GET `/notifications?page=1`
- **THEN** 返回分页通知列表，按时间倒序

### Requirement: 用户管理 Admin API
系统 SHALL 提供管理员对用户的管理功能。

#### Scenario: 查看用户列表
- **WHEN** GET `/admin/users?page=1&status=banned`
- **THEN** 返回分页用户列表（含封禁状态）

#### Scenario: 封禁用户
- **WHEN** PUT `/admin/users/{id}/status` body `{"status": "banned"}`
- **THEN** 用户 status 更新为 "banned"，该用户的 JWT 立即失效

### Requirement: 限流保护
系统 SHALL 对关键接口实施请求频率限制。

#### Scenario: 上传接口限流
- **WHEN** 同一 IP 在 1 分钟内上传超过 10 次
- **THEN** 返回 429 "请求过于频繁，请稍后再试"

#### Scenario: 登录接口限流
- **WHEN** 同一 IP 在 1 分钟内请求登录超过 5 次
- **THEN** 返回 429 "登录过于频繁，请 1 分钟后重试"

### Requirement: 用户资料 API
系统 SHALL 提供当前用户个人资料的查询和修改。

#### Scenario: 查询个人资料
- **WHEN** GET `/auth/profile` 携带有效 JWT
- **THEN** 返回当前用户的 id、username、nickname、avatar_url、bio、role、created_at

#### Scenario: 修改个人资料
- **WHEN** PUT `/auth/profile` 携带 `{nickname, bio}`
- **THEN** 更新当前用户的 nickname 和 bio

---

## MODIFIED Requirements

### Requirement: 作品列表标签搜索
系统 SHALL 使用 `artwork_tags` 表进行标签搜索，替代 JSON 文本 LIKE 查询。

#### Scenario: 按标签搜索
- **WHEN** GET `/artworks?tag=胶片`
- **THEN** 通过 artwork_tags 表 JOIN artworks 查询
- **AND** `artwork_tags` 表在发布作品时同步写入

### Requirement: PageResult 分页
系统 SHALL 在 `PageResult` 中新增 `totalPages` 字段。

### Requirement: MybatisPlus 分页配置
系统 SHALL 根据 active profile 动态选择 `DbType`（dev=H2, prod=POSTGRE_SQL）。

### Requirement: Upload 路径公开访问
系统 SHALL 将 `/uploads/**` 加入 SecurityConfig 的白名单，允许未认证访问。

### Requirement: CommentServiceImpl 回复列表
系统 SHALL 将子评论列表正确赋值到 Comment 对象的 `replies` 字段并返回。

### Requirement: 启动类开启缓存
系统 SHALL 在 `PicFlowApplication` 类上添加 `@EnableCaching` 注解。