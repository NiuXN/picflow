# PicFlow 功能清单

> 灵感相框 · 治愈系排版工具 — 面向小红书用户的图片编辑 + 创作社区

---

## 📱 Flutter App

### 首页
- [x] 灵感相框入口卡片
- [x] 最近作品（本地 JSON 持久化）
- [x] 快捷工具（拼图/修图/视频）
- [x] Pro 徽章
- [x] 启动时版本自动检查（延迟 800ms）

### 编辑工作台
- [x] 图片选择（相册/相机，含 EXIF 读取）
- [x] 画布实时预览
- [x] 5 种相框：极简留白 / EXIF 参数 / 拍立得风 / 专业底片(徕卡红点) / 圆形取景
- [x] 3 种比例：3:4（小红书精选）/ 1:1（方形）/ 9:16（壁纸）
- [x] 九宫格辅助线
- [x] 5 色背景取色器（纯白/米色/暖灰/橄榄/粉）
- [x] 7 种滤镜：原图 / 奶油 / 胶片 / 黑白 / 暖阳 / 冷调 / 复古
- [x] 水印：文字输入、3 种字体（无衬线/手写体/打字机）、3 种位置（左下/中/右下）

### 导出分享
- [x] 画布截图（RepaintBoundary.toImage, 3x pixelRatio）
- [x] 保存到系统相册
- [x] 系统分享
- [x] 导出成功后底部弹窗（保存到相册 / 分享 / 发布到广场）

### 登录/注册
- [x] 密码登录
- [x] 用户名注册
- [x] 手机号验证码登录（60s 倒计时，开发环境自动返回验证码）
- [x] JWT Token 持久化（flutter_secure_storage）
- [x] 路由守卫（/publish、/profile 未登录自动跳转 /auth）

### 创作广场
- [x] 作品瀑布流（MasonryGridView 双列）
- [x] 标签筛选（8 个预设：胶片/治愈/简约/复古/风景/人物/美食/黑白）
- [x] 排序切换（最新 / 热门 / 精选）
- [x] 上拉加载更多 + 下拉刷新
- [x] 骨架屏加载占位

### 作品详情
- [x] 大图展示（85% 屏幕宽度）
- [x] 作者头像/昵称/时间
- [x] 创作参数展示（相框/比例/滤镜/背景色/水印）
- [x] 标签展示
- [x] 点赞/收藏/评论互动
- [x] 评论列表 + 底部输入发表评论
- [x] 错误状态 + 重试按钮

### 发布
- [x] 标题输入（30 字限制）
- [x] 描述输入（3 行，200 字限制）
- [x] 预设标签选择（最多 5 个）
- [x] 编辑参数自动带入（相框/比例/滤镜/背景/水印）
- [x] 图片上传 → API 提交
- [x] 发布 loading 状态 + 成功/失败 SnackBar

### 个人中心
- [x] 用户头像/昵称/简介
- [x] 统计栏（作品/获赞/收藏/关注）
- [x] 我的作品网格（3 列）
- [x] 设置面板底部弹窗（编辑资料/通知设置/设计偏好/关于）

### 通知
- [x] 通知列表（标题/内容/时间）
- [x] SSE 实时推送接收
- [x] 连接断开自动重连（5s）

### 设计系统
- [x] 奶油/侘寂风色板（6 主色 + 5 辅助色）
- [x] Varela Round + Nunito Sans 字体层级
- [x] 4 级弥散阴影系统
- [x] 8px 基准间距系统
- [x] 完整 ThemeData 配置
- [x] 统一 SnackBar 工具类（success/error/info）

---

## 🖥️ Spring Boot 后端

### 认证
- [x] `POST /auth/register` — 用户注册
- [x] `POST /auth/login` — 密码登录
- [x] `POST /auth/send-code` — 发送短信验证码
- [x] `POST /auth/phone-login` — 手机号验证码登录/注册
- [x] `GET /auth/profile` — 获取个人信息
- [x] `PUT /auth/profile` — 修改昵称/简介

### 作品
- [x] `GET /artworks` — 作品列表（分页 + 排序 + 标签筛选）
- [x] `GET /artworks/{id}` — 作品详情
- [x] `POST /artworks` — 发布作品
- [x] `DELETE /artworks/{id}` — 删除作品

### 互动
- [x] `POST /artworks/{id}/like` — 点赞
- [x] `DELETE /artworks/{id}/like` — 取消点赞
- [x] `POST /artworks/{id}/favorite` — 收藏
- [x] `DELETE /artworks/{id}/favorite` — 取消收藏
- [x] `GET /artworks/{id}/comments` — 评论列表（分页）
- [x] `POST /artworks/{id}/comments` — 发表评论（支持嵌套回复）

### 文件
- [x] `POST /upload/image` — 上传图片（类型白名单、大小≤10MB、尺寸≤4096px）
- [x] 自动生成 300px 宽缩略图（Thumbnailator）

### 通知
- [x] `GET /notifications` — 通知列表（分页）
- [x] `POST /admin/notifications` — 发布通知

### App 版本
- [x] `GET /app/version` — 获取最新版本（支持渠道/灰度/版本区间判断）

### SSE 实时推送
- [x] `GET /sse/subscribe` — SSE 订阅，新通知实时推送

### 管理后台接口
- [x] `GET /admin/dashboard` — 仪表盘统计
- [x] `GET /admin/artworks` — 作品管理列表（分页）
- [x] `PUT /admin/artworks/{id}/review` — 审核作品
- [x] `PUT /admin/artworks/{id}/featured` — 设置精选
- [x] `DELETE /admin/artworks/{id}` — 下架作品
- [x] `GET /admin/users` — 用户列表（分页 + 状态筛选）
- [x] `PUT /admin/users/{id}/status` — 封禁/解封
- [x] `GET /admin/versions` — 版本列表
- [x] `POST /admin/versions` — 发布新版本
- [x] `PUT /admin/versions/{id}` — 编辑版本
- [x] `DELETE /admin/versions/{id}` — 删除版本

### 基础设施
- [x] JWT 认证 + Spring Security（`ROLE_ADMIN` 权限）
- [x] Redis 缓存（Spring Cache：作品列表/详情/热门）
- [x] Bucket4j 限流（上传 10次/分钟、登录 5次/分钟）
- [x] 全局异常处理（RuntimeException / Validation / Exception）
- [x] MyBatis-Plus 雪花算法主键（ASSIGN_ID）
- [x] Jackson snake_case 全局命名
- [x] 逻辑删除（deleted 字段）
- [x] Knife4j Swagger 文档
- [x] CORS 跨域配置
- [x] 定时任务（每 10 分钟刷新热门缓存）

---

## 👨‍💼 Vue3 管理面板

### 登录
- [x] 管理员账号登录
- [x] 双栏品牌布局（左侧品牌展示 + 右侧登录表单）
- [x] 表单验证 + 错误提示

### 仪表盘
- [x] 统计卡片（用户总数/作品总数/今日新增）
- [x] ECharts 趋势图
- [x] 骨架屏加载态
- [x] 快捷入口卡片（作品管理/用户管理/发布通知/版本管理）

### 作品管理
- [x] 作品表格（ID/标题/作者/点赞/评论/状态/精选）
- [x] 审核通过 / 下架
- [x] 设置/取消精选

### 用户管理
- [x] 用户表格（ID/用户名/手机号/昵称/角色/状态/注册时间）
- [x] 状态筛选（全部/正常/封禁）
- [x] 分页
- [x] 封禁/解封

### 通知管理
- [x] 通知表格（ID/标题/内容/发布时间）
- [x] 发布通知弹窗（标题 + 内容）

### 版本管理
- [x] 版本表格（版本号/版本码/渠道/灰度/区间/类型/状态）
- [x] 发布/编辑/删除版本
- [x] 渠道选择（stable 稳定版 / beta 测试版 / alpha 内部版）
- [x] 灰度比例滑块（0-100%）
- [x] 版本区间设置（下限/上限）
- [x] 强制/可选更新切换
- [x] 热更新链接（Shorebird）
- [x] 发布日志（Markdown）
- [x] 启用/下架版本

### 布局
- [x] 可折叠侧边栏（220px ↔ 64px）
- [x] 菜单分组（内容管理 / 系统管理）
- [x] 面包屑导航
- [x] 用户头像（Element Avatar）下拉菜单
- [x] 页面淡入淡出过渡动画

---

## 📦 数据库 (MySQL 8.0+)

| 表 | 记录 | 说明 |
|----|------|------|
| `users` | 用户 | id, username, phone, password_hash, nickname, avatar_url, bio, role, status, deleted |
| `artworks` | 作品 | id, user_id, title, description, image_url, tags(JSON), frame_type, filter, likes/favorites/comments/views_count, status, is_featured, deleted |
| `artwork_tags` | 作品标签关联 | id, artwork_id, tag (UNIQUE) |
| `likes` | 点赞记录 | id, user_id, artwork_id (UNIQUE) |
| `favorites` | 收藏记录 | id, user_id, artwork_id (UNIQUE) |
| `comments` | 评论 | id, user_id, artwork_id, content, parent_id(回复), status |
| `notifications` | 通知/公告 | id, title, content, target, created_at |
| `app_versions` | App 版本管理 | id, version_name, version_code, channel, gray_percent, min/max_version_code, force_update, description, release_notes, download_url, hotfix_url, platform, enabled |

> 全部使用雪花算法主键（`BIGINT PRIMARY KEY`），InnoDB 引擎，`utf8mb4` 字符集。
