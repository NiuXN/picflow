# PicFlow 🎨

> 灵感相框 · 治愈系排版工具 — 面向小红书用户的图片编辑 + 创作社区

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行（需先启动后端）
flutter run -d "iPhone 17 Pro"
```

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Flutter 3.19+ / Dart 3.9+ |
| 状态管理 | Riverpod 2.5+ (StateNotifier) |
| 路由 | GoRouter 14.2+ (ShellRoute 底部导航) |
| 设计系统 | 自建 (AppColors/Typography/Shadows/Spacing/Theme) |
| HTTP | Dio 5.4+ |
| 图片处理 | image_picker, exif, image_gallery_saver |

## 功能一览

| 模块 | 功能 |
|------|------|
| **首页** | 灵感相框入口、最近作品（本地持久化）、版本自动检查 |
| **编辑工作台** | 5 种相框、3 种比例、7 种滤镜、水印、九宫格辅助线 |
| **导出** | 画布截图 → 保存相册 / 分享 / 跳转发布 |
| **创作广场** | 作品瀑布流、标签筛选、点赞/收藏/评论 |
| **发布** | 标题/描述/标签、编辑参数自动带入、图片上传 |
| **个人中心** | 用户资料、作品列表、设置面板 |
| **登录/注册** | 密码登录 / 手机号验证码登录 |
| **EXIF 读取** | 选图后自动读取相机参数并展示 |

## 项目文档

| 文档 | 说明 |
|------|------|
| [`PLAN.md`](../PLAN.md) | 项目整体规划、技术架构、API 参考 |
| [`PicFlow_Design_System.md`](../PicFlow_Design_System.md) | 设计系统规范（色板/字体/阴影/组件） |
