# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

Community Repair System Management Platform (社区维修系统管理平台) — a multi-role web app with three user roles: residents (居民), workers (维修工), and admins (管理员).

## Project Layout

- **`back-demo/`** — Spring Boot 3.5 backend (Java 17, MyBatis, MySQL, JWT auth)
- **`front-demo/`** — Vue 3 frontend (Vite, Element Plus, Pinia, ECharts)
- **`api_doc.txt`** — Complete API reference (Chinese)

## Common Commands

### Backend

```bash
cd back-demo

# Start dev server (port 8080, context-path /api)
./mvnw spring-boot:run

# Run tests
./mvnw test

# Run a single test class
./mvnw test -Dtest=BackDemoApplicationTests
```

### Frontend

```bash
cd front-demo

# Install dependencies
npm install

# Start dev server (port 3000, proxies /api → localhost:8080)
npm run dev

# Build for production
npm run build
```

### Database

MySQL on `localhost:3306`, database name `community_repair`. Credentials in `back-demo/src/main/resources/application.yml`.

## Architecture

### Backend (layered architecture)

```
controller → service → mapper (interface + XML)
```

- **Packages**: `controller`, `service`, `mapper`, `entity`, `dto`, `vo`, `common`, `config`, `context`, `exception`, `interceptor`, `util`
- **Auth**: JWT interceptor on all paths except `/login`, `/users/register`, `/workers/register`, `/uploads/**`. Token passed as `Authorization: Bearer <token>`, contains `userId` and `role` claims.
- **User context**: `UserContext` is a `ThreadLocal` holder set by `JwtInterceptor.preHandle` and cleared in `afterCompletion`. Controllers read current user via `UserContext.getUserId()` / `UserContext.getRole()` — never from request parameters.
- **Role-based access**: Controllers enforce roles via `userService.checkRole(role, expectedRole)`. Services also check ownership (e.g., repair orders, evaluations).
- **API response**: `Result<T>` with `code` (1=success, 0=failure), `msg`, `data`. `GlobalExceptionHandler` catches `BusinessException` and validation errors.
- **Password encoding**: BCrypt via `PasswordConfig` (uses `spring-security-crypto` without full Spring Security).
- **MyBatis**: XML mappers in `resources/mapper/*.xml`, `map-underscore-to-camel-case: true`.

### Frontend

- **`src/api/`** — API functions per module (`user.js`, `repair.js`, `worker.js`, `evaluation.js`, `notification-api.js`)
- **`src/utils/request.js`** — Axios instance with interceptor that attaches Bearer token and handles `code:0` as error
- **`src/store/user.js`** — Pinia store with `persistedstate` plugin (localStorage). Provides `token`, `userId`, `role`, `userInfo`. Also does client-side JWT expiry check.
- **`src/router/index.js`** — Route guard checks `isLoggedIn` and `meta.roles` for role-based access. Pages with `meta: { noAuth: true }` skip auth.
- **`src/views/`** — Split by role: `admin/`, `resident/`, `worker/`, `common/`, `login/`, `register/`
- **Components**: `Layout.vue` (sidebar + top bar), `StatusTag.vue`, `StarRating.vue`, `AvatarUpload.vue`

### Key domain: Repair Order status flow

```
pending → assigned → processing → completed
                ↓ (any point)
             cancelled (only from pending)
```

- `Constants.java` defines all status and role strings.
- Only admins can assign (`POST /repairs/assign`) — must target an active worker.
- Only the assigned worker can update status (`PUT /repairs/status`).
- Only the resident who owns the order can cancel or modify it (while pending).
- Evaluations can only be created on completed orders, by the order's resident.

### Worker account lifecycle

- Self-register → `status: pending` → admin reviews (`PUT /workers/review`) → `active` or `rejected`
- Admin direct add (`POST /workers`) → `status: active` immediately
- Login checks: workers with `pending` or `rejected` status get `code: 0` with appropriate message

### Upload/avatar handling

- Avatar uploads stored in `D:\springboot-project\community_repair\back-demo\uploads\avatar\` (hardcoded absolute path in `UserService` and `UploadController`).
- Served via `UploadController` at `/uploads/avatar/{dateDir}/{filename}`.
- Note: frontend Vite proxy rewrites `/uploads` → `/api/uploads` for dev, but `UploadController` path is `/uploads/avatar/...` (no `/api` prefix needed since Spring's context-path is `/api`).

## Database

- `sys_user` — unified user table; role discriminator column (`resident`/`worker`/`admin`), status (`active`/`pending`/`rejected`)
- `repair_order` — repair tickets with FK to `sys_user` for both `user_id` and `worker_id`
- `evaluation` — one evaluation per completed repair
- `notification` — per-user notifications (`is_read` flag, `type` for categorization)
