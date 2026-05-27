# PicFlow 项目规划

> 灵感相框 · 治愈系排版工具 — 面向小红书用户的图片编辑 + 创作社区

---

## 一、项目定位

| 维度 | 内容 |
|------|------|
| **目标用户** | 小红书用户，追求「纯白/米色，清新治愈感」视觉风格 |
| **核心价值** | 极简相框 + 排版 + 水印 + 滤镜，快速出片 |
| **产品形态** | Flutter App (iOS/Android/Web) + Spring Boot 后端 + Vue3 管理面板 |

---

## 二、技术栈

### 前端 — Flutter App

| 层 | 技术 |
|---|------|
| 语言/框架 | Dart 3.9+ / Flutter 3.19+ |
| 状态管理 | Riverpod 2.5+ (StateNotifier) |
| 路由 | GoRouter 14.2+ (ShellRoute 底部导航 + MaterialPage) |
| 设计系统 | 自建 (AppColors/Typography/Shadows/Spacing/Theme) |
| HTTP | Dio 5.4+ (AuthInterceptor JWT 注入) |
| 图片处理 | image_picker, exif (EXIF 读取), image_gallery_saver |
| 分享 | share_plus |
| 骨架屏 | shimmer 3.0+ |
| 存储 | flutter_secure_storage (JWT), path_provider |

### 后端 — Spring Boot

| 层 | 技术 |
|---|------|
| 语言/框架 | Java 21 / Spring Boot 3.4.1 |
| ORM | MyBatis-Plus 3.5.5 (雪花算法主键) |
| 数据库 | MySQL 8.0+ (dev/prod 统一) |
| 缓存 | Redis 7+ (Spring Cache + Jackson2Json) |
| 认证 | JWT (jjwt 0.12.6) + Spring Security |
| 文件存储 | 本地文件系统 (可扩展 MinIO/OSS) |
| 文档 | Knife4j (Swagger) |
| 限流 | Bucket4j (令牌桶) |
| 工具 | Hutool, Thumbnailator (缩略图) |

### 管理面板 — Vue3

| 层 | 技术 |
|---|------|
| 框架 | Vue 3.5 + TypeScript |
| UI | Element Plus 2.9 |
| 状态管理 | Pinia 2.3 |
| HTTP | Axios (JWT 拦截器 + 401 自动跳登录) |
| 图表 | ECharts 5 + vue-echarts 7 |

---

## 三、功能模块

### ✅ 已完成

| 模块 | 功能详情 |
|------|---------|
| **设计系统** | 奶油/侘寂风色板、Varela Round + Nunito Sans 字体、圆角/阴影/间距规范、完整 ThemeData |
| **首页** | 灵感相框入口、最近作品（本地 JSON 持久化）、快捷工具、图片选择器、启动版本检查 |
| **编辑工作台** | 5 种相框（极简/EXIF/拍立得/徕卡/圆形）、3 种比例（3:4/1:1/9:16）、7 种滤镜（奶油/胶片/黑白/暖阳/冷调/复古）、水印（3 字体 + 3 位置）、九宫格辅助线、5 色背景 |
| **导出分享** | 画布截图 (RepaintBoundary) → 保存相册 / 系统分享 / 跳转发布 |
| **EXIF 读取** | 选图后自动读取相机型号/ISO/光圈/快门/焦距/拍摄日期 |
| **登录/注册** | 密码登录、手机号验证码登录（开发环境自动返回验证码）、60s 倒计时 |
| **创作广场** | 作品瀑布流 (MasonryGridView)、标签筛选、排序（最新/热门/精选）、上拉加载/下拉刷新、骨架屏加载 |
| **作品详情** | 大图展示、作者信息、创作参数（相框/比例/滤镜/背景/水印）、点赞/收藏/评论 |
| **发布** | 标题/描述/标签输入、编辑参数自动带入、图片上传 → API 提交 |
| **个人中心** | 用户资料、统计栏、作品列表、设置面板（编辑资料/通知/设计偏好） |
| **通知** | 通知列表页，对接后端 GET /notifications |
| **App 版本管理** | 渠道管理（stable/beta/alpha）、灰度发布、版本区间、强制/可选更新、Shorebird 热更新预留 |
| **后端 API** | 用户注册/登录(JWT)、手机号验证码、作品 CRUD、点赞/收藏持久化、评论、图片上传+缩略图、通知 CRUD、管理员 API、限流保护、Redis 缓存 |
| **管理面板** | 登录、仪表盘（统计卡片+ECharts）、作品管理（审核/精选/下架）、用户管理（封禁/解封+分页）、通知发布、版本管理（渠道/灰度/区间/热更新） |

### 🔜 待开发

| 模块 | 优先级 | 说明 |
|------|--------|------|
| 他人主页 | 低 | `/user/:userId` 浏览他人作品 |
| 广场搜索 | 低 | 作品/用户搜索 |

---

## 四、项目结构

```
picflow-app/                            ← Flutter 前端
├── lib/
│   ├── main.dart                       # 入口
│   ├── config/api_config.dart          # API 地址配置
│   ├── models/                         # 数据模型（10个）
│   ├── providers/                      # Riverpod 状态（8个）
│   ├── screens/                        # 页面（9个）
│   ├── services/                       # 网络/业务服务（9个）
│   ├── theme/                          # 设计系统（5个）
│   ├── utils/                          # 工具类（2个）
│   └── widgets/                        # 可复用组件（20+）
├── pubspec.yaml
└── test/

picflow-server/                         ← Spring Boot 后端
├── src/main/java/com/picflow/server/
│   ├── controller/                     # API 控制器（6个）
│   ├── service/                        # 业务逻辑（8个接口+实现）
│   ├── mapper/                         # MyBatis-Plus Mapper（8个）
│   ├── entity/                         # 数据实体（8个）
│   ├── dto/                            # 请求/响应 DTO（4个）
│   ├── config/                         # 配置类（安全/缓存/CORS/异常）
│   ├── security/                       # JWT 认证
│   ├── common/                         # 公共响应/分页
│   └── interceptor/                    # 限流拦截器
├── src/main/resources/
│   ├── application.yml                 # 公共配置
│   ├── application-dev.yml             # 开发环境（MySQL）
│   ├── application-prod.yml            # 生产环境（MySQL）
│   └── db/schema-mysql.sql             # 建表脚本
├── pom.xml
└── README.md

picflow-admin-vue/                      ← Vue3 管理面板
├── src/
│   ├── api/                            # API 封装（6个模块）
│   ├── views/                          # 页面（6个）
│   ├── layouts/                        # 管理布局
│   ├── router/                         # 路由+守卫
│   ├── stores/                         # Pinia 状态
│   └── types/                          # TypeScript 类型
├── package.json
└── README.md
```

### 路由结构

| 路由 | 页面 | 导航方式 |
|------|------|---------|
| `/` | 首页 | ShellRoute 底部导航 |
| `/square` | 创作广场 | ShellRoute 底部导航 |
| `/profile` | 个人中心 | ShellRoute 底部导航 |
| `/editor` | 编辑工作台 | MaterialPage（iOS 右滑返回） |
| `/artwork/:id` | 作品详情 | MaterialPage（iOS 右滑返回） |
| `/publish` | 发布作品 | SlideTransition 底部滑入 |
| `/auth` | 登录/注册 | MaterialPage（密码+手机号） |
| `/notifications` | 通知列表 | MaterialPage（iOS 右滑返回） |

---

## 五、系统架构

```
┌─────────────────────────────────────────────────────┐
│                 客户端 (Flutter)                      │
│  iOS / Android / Web                                │
│  Riverpod → GoRouter + Dio                          │
│  设计系统: AppColors/Typography/Shadows/Spacing      │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP REST (JSON, snake_case)
                       │ JWT Bearer Token
┌──────────────────────▼──────────────────────────────┐
│                 后端 (Spring Boot)                   │
│                                                      │
│   ┌───────────┐ ┌───────────┐ ┌───────────────┐    │
│   │ 认证服务   │ │ 作品服务   │ │  互动服务      │    │
│   │ 登录/注册  │ │ CRUD/搜索 │ │ 点赞/收藏/评论 │    │
│   │ 手机号验证码│ │ 缩略图生成│ │               │    │
│   └───────────┘ └───────────┘ └───────────────┘    │
│   ┌───────────┐ ┌───────────┐ ┌───────────────┐    │
│   │ 管理服务   │ │ 版本管理   │ │  文件服务      │    │
│   │ 审核/统计  │ │ 渠道/灰度 │ │ 图片上传/校验  │    │
│   └───────────┘ └───────────┘ └───────────────┘    │
│                                                      │
│  Jackson SNAKE_CASE  │  Spring Cache + Redis         │
│  MyBatis-Plus ASSIGN_ID (雪花)  │  Bucket4j 限流     │
└──────────┬───────────────────────┬──────────────────┘
           │                       │
    ┌──────▼──────┐         ┌─────▼─────┐
    │   MySQL 8.0 │         │   Redis   │
    │  主数据库    │         │ 缓存/黑名单│
    └─────────────┘         └───────────┘
```

---

## 六、API 参考

所有 API 路径前缀 `/v1`，JSON 命名策略为 **snake_case**。无需认证的接口可直接调用，需认证的接口需在 Header 中添加 `Authorization: Bearer <token>`。

### 认证 `/auth`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/auth/register` | 注册 `{username, password, nickname}` → `{token, user}` | 否 |
| POST | `/auth/login` | 密码登录 `{username, password}` → `{token, user}` | 否 |
| POST | `/auth/send-code` | 发送短信验证码 `{phone}` → 开发环境直接返回 code | 否 |
| POST | `/auth/phone-login` | 手机号登录 `{phone, code}` → 自动注册/登录 | 否 |
| GET | `/auth/profile` | 获取当前用户信息 | 是 |
| PUT | `/auth/profile` | 修改资料 `{nickname, bio}` | 是 |

### 作品 `/artworks`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/artworks` | 列表 `?page=1&size=20&sort=latest&tag=` | 否 |
| GET | `/artworks/{id}` | 详情 | 否 |
| POST | `/artworks` | 发布 `{title, image_url, tags, frame_type, ...}` | 是 |
| DELETE | `/artworks/{id}` | 删除 | 是 |
| POST | `/artworks/{id}/like` | 点赞 | 是 |
| DELETE | `/artworks/{id}/like` | 取消点赞 | 是 |
| POST | `/artworks/{id}/favorite` | 收藏 | 是 |
| DELETE | `/artworks/{id}/favorite` | 取消收藏 | 是 |
| GET | `/artworks/{id}/comments` | 评论列表（分页） | 否 |
| POST | `/artworks/{id}/comments` | 发表评论 `{content}` | 是 |

### 文件 `/upload`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/upload/image` | 上传图片 (multipart) → `{url, thumbnailUrl}` | 是 |

### App 版本 `/app`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/app/version` | 获取最新版本 `?platform=all&channel=stable&userId=&currentVersionCode=` | 否 |

### 通知 `/notifications`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/notifications` | 通知列表（分页） | 是 |

### 管理后台 `/admin`（需 `ROLE_ADMIN`）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/admin/dashboard` | 仪表盘统计 |
| GET | `/admin/artworks` | 作品列表（分页） |
| PUT | `/admin/artworks/{id}/review` | 审核作品 |
| PUT | `/admin/artworks/{id}/featured` | 设置精选 |
| DELETE | `/admin/artworks/{id}` | 下架作品 |
| GET | `/admin/users` | 用户列表（分页+状态筛选） |
| PUT | `/admin/users/{id}/status` | 封禁/解封 |
| GET | `/admin/versions` | 版本列表 |
| POST | `/admin/versions` | 发布新版本 |
| PUT | `/admin/versions/{id}` | 编辑版本 |
| DELETE | `/admin/versions/{id}` | 删除版本 |
| POST | `/admin/notifications` | 发布通知 |

---

## 七、核心数据流

```
                    ┌──────────────┐
                    │  首页/启动    │
                    │ 版本检查/登录 │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  编辑工作台   │
                    │ ┌─ 相框(5种) │
                    │ ├─ 排版(比例 │
                    │ │  网格/背景)│
                    │ ├─ 水印     │
                    │ └─ 滤镜(7种)│
                    └──────┬───────┘
                           │ 导出
                    ┌──────▼───────┐
                    │  导出/分享    │
                    │ 截图→保存相册 │
                    │ 截图→系统分享 │
                    │ 截图→发布到广场│
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  发布作品     │
                    │ 上传图片+提交 │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
       ┌──────▼──────┐          ┌──────▼──────┐
       │  创作广场    │          │  作品详情    │
       │ 瀑布流/标签  │          │ 点赞/收藏/评论│
       │ 排序/分页    │          └─────────────┘
       └─────────────┘
```

---

## 八、开发环境

| 项 | 值 |
|----|-----|
| Flutter SDK | `^3.19.0`（当前 3.35.3） |
| Dart SDK | `^3.9.2` |
| Java | `21` |
| MySQL | `localhost:3306/picflow` |
| Redis | `localhost:6379` |
| 后端地址 | `http://localhost:8080/v1` |
| 管理面板 | `http://localhost:5173` |
| JSON 命名 | snake_case（全局配置） |
| 主键策略 | 雪花算法 (MyBatis-Plus ASSIGN_ID) |

### 启动命令

```bash
# 1. 启动 MySQL + Redis

# 2. 启动后端（默认 dev profile）
cd picflow-server && mvn spring-boot:run

# 3. 启动管理面板
cd picflow-admin-vue && npm run dev

# 4. 启动 Flutter App（模拟器）
cd picflow-app && flutter run -d "iPhone 17 Pro"
```

### 初始账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | `admin` | `password123` | 管理后台登录 |
| 演示用户 | `demo` | `password123` | App 端测试 |

---

## 九、设计资源

设计系统规范详见 [`PicFlow_Design_System.md`](PicFlow_Design_System.md)，包含：

- 完整色板（6 主色 + 5 辅助色）
- 字体层级（Varela Round + Nunito Sans）
- 阴影系统（4 级弥散阴影）
- 间距系统（8px 基准）
- 组件规范（按钮/卡片/输入框）
- 动画规范（150ms/300ms/500ms）
