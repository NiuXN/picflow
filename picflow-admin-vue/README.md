# PicFlow Admin — 管理后台

> Vue 3 + Element Plus + TypeScript + Vite

PicFlow 创作广场的后台管理 Web 面板，用于作品审核、用户管理、数据统计和通知发布。

## 技术栈

| 层 | 技术 |
|---|------|
| 框架 | Vue 3.5 + TypeScript |
| UI 库 | Element Plus 2.9 |
| 图标 | @element-plus/icons-vue |
| 状态管理 | Pinia 2.3 |
| 路由 | Vue Router 4.5 |
| HTTP | Axios 1.7（JWT 拦截器） |
| 图表 | ECharts 5 + vue-echarts 7 |
| 构建 | Vite 6 |

## 快速开始

### 前置条件

- Node.js 18+
- 后端服务运行中（见 `picflow-server/README.md`）

### 启动

```bash
cd picflow-admin
npm install
npm run dev
```

访问 `http://localhost:5173` → 自动跳转登录页。

Vite 已配置代理：`/v1/*` 请求转发至 `http://localhost:8080`。

### 构建

```bash
npm run build
```

产出在 `dist/` 目录，可部署到任意静态服务器（Nginx / CDN）。

## 项目结构

```
src/
├── main.ts                 # 入口：Pinia + Router + ElementPlus
├── App.vue                 # 根组件
├── api/                    # API 封装
│   ├── index.ts            # Axios 实例 + JWT 拦截器 + 401 处理
│   ├── auth.ts             # 登录/个人资料
│   ├── dashboard.ts        # 仪表盘统计
│   ├── artworks.ts         # 作品管理
│   ├── users.ts            # 用户管理
│   └── notifications.ts    # 通知管理
├── stores/
│   └── auth.ts             # 认证状态（Pinia + localStorage）
├── router/
│   └── index.ts            # 路由配置 + 登录守卫
├── layouts/
│   └── AdminLayout.vue     # 管理布局（侧边栏 + 顶栏 + 退出）
├── views/
│   ├── LoginView.vue       # 登录页
│   ├── DashboardView.vue   # 仪表盘（统计卡片 + 图表）
│   ├── artworks/
│   │   └── ArtworkList.vue # 作品管理（审核/精选/下架）
│   ├── users/
│   │   └── UserList.vue    # 用户管理（封禁/解封 + 分页）
│   └── notifications/
│       └── NoticeList.vue  # 通知管理（发布公告）
└── types/
    └── index.ts            # TypeScript 类型定义
```

## 页面说明

| 路由 | 页面 | 功能 |
|------|------|------|
| `/login` | 登录 | 管理员账号登录 |
| `/dashboard` | 仪表盘 | 用户数/作品数/今日新增统计 + 趋势图 |
| `/artworks` | 作品管理 | 作品列表、审核通过/下架、设置精选 |
| `/users` | 用户管理 | 用户列表、封禁/解封（含 Redis 黑名单） |
| `/notifications` | 通知管理 | 通知列表、发布公告 |

## 构建部署

```nginx
# Nginx 配置示例
server {
    listen 80;
    server_name admin.picflow.app;

    root /path/to/picflow-admin/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /v1/ {
        proxy_pass http://localhost:8080;
    }
}
```
