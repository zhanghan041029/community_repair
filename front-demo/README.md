# 社区维修系统管理平台 - 前端

基于 Vue 3 + Vite + Element Plus 构建的社区维修管理平台前端应用。

## 技术栈

- Vue 3 (Composition API, `<script setup>`)
- Vite 6
- Element Plus 2.x
- Vue Router 4
- Pinia (persisted state)
- Axios
- SCSS

## 项目结构

```
src/
├── api/            # 按模块封装 API (user, repair, worker, evaluation)
├── assets/         # 全局样式、图片
├── components/     # 公共组件 (Layout, StatusTag, StarRating, AvatarUpload)
├── router/         # 路由配置 + 权限守卫
├── store/          # Pinia store (user)
├── utils/          # Axios 实例封装
├── views/          # 页面视图
│   ├── admin/      # 管理员端
│   ├── common/     # 通用
│   ├── login/      # 登录
│   ├── register/   # 注册
│   ├── resident/   # 居民端
│   └── worker/     # 维修工端
├── App.vue
└── main.js
```

## 角色路由

| 角色 | 页面 |
|------|------|
| 居民 | 工单看板 / 提交报修 / 我的工单 / 个人资料 |
| 维修工 | 工单看板 / 历史工单 / 个人资料 |
| 管理员 | 数据概览 / 居民管理 / 维修工管理 / 工单管理 |

## 启动

```bash
npm install
npm run dev
```

开发服务器默认运行在 `http://localhost:5173`，API 请求代理到 `http://localhost:8080`。

## 环境变量

复制 `.env.development` 并调整后端地址：

```
VITE_API_BASE_URL=http://localhost:8080/api
```