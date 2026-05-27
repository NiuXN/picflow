# PicFlow Server — 后端 API 服务

> Spring Boot 3.4 + JDK 21 + MySQL + Redis

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Spring Boot 3.4.1 |
| 语言 | Java 21 |
| ORM | MyBatis-Plus 3.5.5 |
| 数据库 | MySQL 8.0+ (dev/prod 统一) |
| 缓存 | Redis 7+（Spring Cache + Jackson2Json） |
| 认证 | JWT (jjwt 0.12.6) |
| 文件存储 | MinIO / 阿里云 OSS |
| 限流 | Bucket4j（令牌桶） |
| 文档 | Knife4j (Swagger) |
| 工具 | Hutool、Thumbnailator、Lombok |

## 快速开始

### 前置条件

- JDK 21+
- Maven 3.8+
- Redis 7+（可选，dev 模式无 Redis 仍可运行部分功能）

### 启动

```bash
cd picflow-server

# 开发环境（H2 内嵌数据库，无需安装 PostgreSQL）
mvn spring-boot:run -Dspring.profiles.active=dev

# 生产环境（需 PostgreSQL + Redis）
mvn spring-boot:run -Dspring.profiles.active=prod
```

### 访问

| 地址 | 说明 |
|------|------|
| `http://localhost:8080/v1` | API 基础路径 |
| `http://localhost:8080/swagger-ui.html` | Swagger 文档（dev 模式） |
| `http://localhost:8080/h2-console` | H2 数据库控制台（dev 模式） |

## 项目结构

```
src/main/java/com/picflow/server/
├── annotation/          # 自定义注解（@RateLimit）
├── common/              # 公共响应（Result, PageResult）
├── config/              # 配置类（安全/缓存/CORS/异常）
├── controller/          # API 控制器
│   ├── AuthController     # 注册/登录/个人资料
│   ├── ArtworkController  # 作品 CRUD/搜索/互动
│   ├── AdminController    # 管理后台
│   ├── NotificationController  # 通知
│   └── UploadController      # 图片上传
├── dto/                 # 请求/响应 DTO
├── entity/              # 数据实体
├── interceptor/         # 拦截器（限流）
├── mapper/              # MyBatis-Plus Mapper
├── security/            # JWT 认证过滤器 + 工具
├── service/             # 业务逻辑
│   └── impl/             # 实现类
└── PicFlowApplication.java  # 启动类
```

## API 概览

### 认证 (`/auth`)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/auth/register` | 注册 | 否 |
| POST | `/auth/login` | 登录（返回 JWT） | 否 |
| GET | `/auth/profile` | 获取个人信息 | 是 |
| PUT | `/auth/profile` | 修改昵称/简介 | 是 |

### 作品 (`/artworks`)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/artworks` | 作品列表（分页/排序/标签筛选） | 否 |
| GET | `/artworks/{id}` | 作品详情 | 否 |
| POST | `/artworks` | 发布作品 | 是 |
| PUT | `/artworks/{id}` | 编辑作品 | 是 |
| DELETE | `/artworks/{id}` | 删除作品 | 是 |
| POST | `/artworks/{id}/like` | 点赞 | 是 |
| DELETE | `/artworks/{id}/like` | 取消点赞 | 是 |
| POST | `/artworks/{id}/favorite` | 收藏 | 是 |
| DELETE | `/artworks/{id}/favorite` | 取消收藏 | 是 |
| GET | `/artworks/{id}/comments` | 评论列表 | 否 |
| POST | `/artworks/{id}/comments` | 发表评论 | 是 |

### 文件 (`/upload`)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/upload/image` | 上传图片（限 10MB） | 是 |

### 通知 (`/notifications`)

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/notifications` | 通知列表 | 是 |

### 管理后台 (`/admin`，需 `ROLE_ADMIN`)

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/admin/dashboard` | 数据仪表盘 |
| GET | `/admin/artworks` | 作品管理列表 |
| PUT | `/admin/artworks/{id}/review` | 审核作品 |
| PUT | `/admin/artworks/{id}/featured` | 设置精选 |
| DELETE | `/admin/artworks/{id}` | 下架作品 |
| GET | `/admin/users` | 用户管理列表 |
| PUT | `/admin/users/{id}/status` | 封禁/解封 |

## 配置说明

配置文件：`src/main/resources/application.yml`

### 开发环境（默认）

- 数据库：H2 内嵌（`./data/picflow`），兼容 PostgreSQL 模式
- Redis：需要 `localhost:6379`
- JWT 密钥：内置默认值（仅开发用）

### 生产环境

```bash
# 通过环境变量配置
export DB_HOST=localhost
export DB_USER=picflow
export DB_PASSWORD=picflow
export REDIS_HOST=localhost
export JWT_SECRET=your-256-bit-secret
export UPLOAD_TYPE=minio  # 或 oss
export MINIO_ENDPOINT=http://localhost:9000
```
