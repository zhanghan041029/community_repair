<script setup>
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { getUnreadCount, getNotificationList, markRead, markAllRead } from '@/api/notification-api'
import { listRepairs } from '@/api/repair'
import {
  User, HomeFilled, Setting, DataBoard, Plus, List, Histogram,
  Tickets, Monitor, UserFilled, Briefcase, ArrowDown, DataAnalysis, Star,
  Fold, Expand, Service, Bell, Document, Clock, Loading, CircleCheck, ChatLineSquare
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const isCollapse = ref(false)
const helpVisible = ref(false)

// 通知
const notifyVisible = ref(false)
const notifyList = ref([])
const unreadCount = ref(0)
let notifyTimer = null

// 维修工工单数量
const workerStats = ref({ all: 0, pending: 0, processing: 0, completed: 0 })

async function fetchWorkerStats() {
  if (userStore.role !== 'worker') return
  try {
    const res = await listRepairs({ pageSize: 100 })
    const rows = res.data.rows || []
    workerStats.value = {
      all: rows.length,
      pending: rows.filter(r => r.status === 'assigned').length,
      processing: rows.filter(r => r.status === 'processing').length,
      completed: rows.filter(r => r.status === 'completed').length
    }
  } catch {}
}

// 管理员工单总数
const adminRepairCount = ref(0)

async function fetchAdminStats() {
  if (userStore.role !== 'admin') return
  try {
    const res = await listRepairs({ pageSize: 1 })
    adminRepairCount.value = res.data.total || 0
  } catch {}
}

async function fetchUnreadCount() {
  try {
    const res = await getUnreadCount()
    unreadCount.value = res.data || 0
  } catch {}
}

async function fetchNotifyList() {
  try {
    const res = await getNotificationList(15)
    notifyList.value = res.data || []
  } catch {}
}

async function handleNotifyClick() {
  notifyVisible.value = true
  await fetchNotifyList()
  await fetchUnreadCount()
}

async function handleMarkRead(item) {
  if (item.isRead === 0) {
    await markRead(item.id)
    item.isRead = 1
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  }
}

async function handleMarkAllRead() {
  await markAllRead()
  notifyList.value.forEach(n => n.isRead = 1)
  unreadCount.value = 0
}

onMounted(() => {
  fetchUnreadCount()
  fetchWorkerStats()
  fetchAdminStats()
  notifyTimer = setInterval(fetchUnreadCount, 30000)
})

onUnmounted(() => {
  if (notifyTimer) clearInterval(notifyTimer)
})

const roleMenus = computed(() => {
  const base = []
  if (userStore.role === 'resident') {
    return [
      { path: '/dashboard', title: '工单看板', icon: HomeFilled },
      { path: '/repair/create', title: '提交报修', icon: Plus },
      { path: '/repair/list', title: '我的工单', icon: Tickets },
      { path: '/repair/stats', title: '工单统计', icon: DataAnalysis },
      { path: '/workers/list', title: '维修工信息', icon: Service },
      { path: '/evaluations/my', title: '我的评价', icon: Star },
      { path: '/announcements', title: '社区公告', icon: ChatLineSquare },
      { path: '/profile', title: '个人资料', icon: User }
    ]
  }
  if (userStore.role === 'worker') {
    return [
      { path: '/dashboard', title: '工单看板', icon: HomeFilled },
      { path: '/repair/history', title: '历史工单', icon: Histogram },
      { path: '/announcements', title: '社区公告', icon: ChatLineSquare },
      { path: '/profile', title: '个人资料', icon: User }
    ]
  }
  if (userStore.role === 'admin') {
    return [
      { path: '/admin/dashboard', title: '数据概览', icon: DataBoard },
      { path: '/residents', title: '居民管理', icon: UserFilled },
      { path: '/workers', title: '维修工管理', icon: Briefcase },
      { path: '/repair/manage', title: '工单管理', icon: Tickets },
      { path: '/admin/announcement', title: '公告管理', icon: ChatLineSquare },
      { path: '/profile', title: '个人资料', icon: User }
    ]
  }
  return base
})

function handleCommand(cmd) {
  if (cmd === 'profile') {
    router.push('/profile')
  } else if (cmd === 'logout') {
    userStore.logout()
    router.push('/login')
  }
}

const activeMenu = computed(() => route.path)
</script>

<template>
  <el-container class="layout-container">
    <el-aside :width="isCollapse ? '64px' : '220px'" class="layout-aside">
      <div class="logo">
        <el-icon :size="24"><Monitor /></el-icon>
        <span v-show="!isCollapse" class="logo-text">社区维修平台</span>
      </div>
      <!-- 维修工自定义菜单 -->
      <template v-if="userStore.role === 'worker' && !isCollapse">
        <div class="custom-menu">
          <div class="menu-group-title">工单管理</div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/dashboard' }"
            @click="router.push('/dashboard')"
          >
            <div class="menu-item-left">
              <div class="menu-icon blue"><el-icon><Document /></el-icon></div>
              <span>全部工单</span>
            </div>
            <span class="menu-badge">{{ workerStats.all }}</span>
          </div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/repair/pending' }"
            @click="router.push('/repair/pending')"
          >
            <div class="menu-item-left">
              <div class="menu-icon orange"><el-icon><Clock /></el-icon></div>
              <span>待处理</span>
            </div>
            <span class="menu-badge orange">{{ workerStats.pending }}</span>
          </div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/repair/processing' }"
            @click="router.push('/repair/processing')"
          >
            <div class="menu-item-left">
              <div class="menu-icon purple"><el-icon><Loading /></el-icon></div>
              <span>进行中</span>
            </div>
            <span class="menu-badge purple">{{ workerStats.processing }}</span>
          </div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/repair/completed' }"
            @click="router.push('/repair/completed')"
          >
            <div class="menu-item-left">
              <div class="menu-icon green"><el-icon><CircleCheck /></el-icon></div>
              <span>已完成</span>
            </div>
            <span class="menu-badge green">{{ workerStats.completed }}</span>
          </div>

          <div class="menu-divider"></div>

          <div class="menu-group-title">其他</div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/announcements' }"
            @click="router.push('/announcements')"
          >
            <div class="menu-item-left">
              <div class="menu-icon gray"><el-icon><ChatLineSquare /></el-icon></div>
              <span>社区公告</span>
            </div>
          </div>

          <div class="menu-divider"></div>

          <div class="menu-group-title">个人中心</div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/profile' }"
            @click="router.push('/profile')"
          >
            <div class="menu-item-left">
              <div class="menu-icon gray"><el-icon><User /></el-icon></div>
              <span>个人资料</span>
            </div>
          </div>
          <div
            class="menu-item"
            :class="{ active: activeMenu === '/repair/history' }"
            @click="router.push('/repair/history')"
          >
            <div class="menu-item-left">
              <div class="menu-icon gray"><el-icon><Histogram /></el-icon></div>
              <span>历史工单</span>
            </div>
          </div>
        </div>
      </template>

      <!-- 默认 el-menu（居民/管理员/维修工折叠状态） -->
      <el-menu
        v-else
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        background-color="#0F172A"
        text-color="#94A3B8"
        active-text-color="#3B82F6"
        router
      >
        <el-menu-item v-for="item in roleMenus" :key="item.path" :index="item.path">
          <el-icon><component :is="item.icon" /></el-icon>
          <template #title>
            <span style="flex:1">{{ item.title }}</span>
            <span
              v-if="item.path === '/repair/manage' && adminRepairCount > 0"
              class="menu-count-badge"
            >{{ adminRepairCount }}</span>
          </template>
        </el-menu-item>
      </el-menu>
      <!-- 底部帮助区域 -->
      <div class="help-section" @click="helpVisible = true">
        <div class="help-icon">
          <el-icon :size="20"><Service /></el-icon>
        </div>
        <div v-show="!isCollapse" class="help-text">
          <div class="help-title">需要帮助？</div>
          <div class="help-desc">联系物业服务中心</div>
        </div>
      </div>
    </el-aside>
    <el-container>
      <el-header class="layout-header">
        <div class="header-left">
          <el-icon
            class="collapse-btn"
            :size="20"
            @click="isCollapse = !isCollapse"
          >
            <Fold v-if="!isCollapse" /><Expand v-else />
          </el-icon>
        </div>
        <div class="header-right">
          <!-- 消息图标 -->
          <div class="notify-icon" @click="handleNotifyClick">
            <el-badge :value="unreadCount" :max="99" :hidden="unreadCount === 0" class="notify-badge">
              <el-icon :size="22"><Bell /></el-icon>
            </el-badge>
          </div>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userStore.userInfo?.avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <span class="user-name">{{ userStore.userInfo?.name || '用户' }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人资料</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="layout-main">
        <router-view />
      </el-main>
    </el-container>

    <!-- 通知弹窗 -->
    <el-dialog v-model="notifyVisible" title="消息通知" width="420px" :close-on-click-modal="true">
      <div class="notify-header-bar">
        <span style="font-size:12px;color:#94A3B8">未读 {{ unreadCount }} 条</span>
        <el-button link size="small" type="primary" @click="handleMarkAllRead">全部已读</el-button>
      </div>
      <div class="notify-list">
        <div
          v-for="item in notifyList"
          :key="item.id"
          class="notify-item"
          :class="{ unread: item.isRead === 0 }"
          @click="handleMarkRead(item)"
        >
          <div class="notify-dot" v-if="item.isRead === 0"></div>
          <div class="notify-content">
            <div class="notify-title">{{ item.title }}</div>
            <div class="notify-desc">{{ item.content }}</div>
            <div class="notify-time">{{ item.createTime }}</div>
          </div>
        </div>
        <el-empty v-if="notifyList.length === 0" description="暂无消息" :image-size="60" />
      </div>
    </el-dialog>

    <!-- 帮助弹窗 -->
    <el-dialog v-model="helpVisible" title="需要帮助？" width="400px">
      <div class="help-dialog-content">
        <p>如有任何问题，请联系物业服务中心：</p>
        <div class="help-info">
          <p><strong>服务热线：</strong>400-123-4567</p>
          <p><strong>服务时间：</strong>周一至周五 8:00-18:00</p>
          <p><strong>邮箱：</strong>service@community.com</p>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="helpVisible = false">我知道了</el-button>
      </template>
    </el-dialog>
  </el-container>
</template>

<style scoped lang="scss">
.layout-container {
  height: 100vh;
}
.layout-aside {
  background-color: #0F172A;
  overflow: hidden;
  transition: width 0.3s;
  display: flex;
  flex-direction: column;
}
.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #3B82F6;
  border-bottom: 1px solid #1E293B;
}
.logo-text {
  font-size: 16px;
  font-weight: 700;
  white-space: nowrap;
}
.layout-header {
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  border-bottom: 1px solid #E2E8F0;
  height: 60px;
}
.collapse-btn {
  cursor: pointer;
  color: #64748B;
  &:hover { color: #3B82F6; }
}
.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.user-name { font-size: 14px; color: #334155; }

/* 通知图标 */
.notify-icon {
  cursor: pointer;
  padding: 6px;
  border-radius: 50%;
  transition: background-color 0.2s;
  color: #64748B;
  display: flex;
  align-items: center;
  justify-content: center;
  &:hover {
    background-color: #F1F5F9;
    color: #3B82F6;
  }
}
.notify-badge :deep(.el-badge__content) {
  border: none;
  font-size: 11px;
  padding: 0 5px;
  height: 16px;
  line-height: 16px;
}

/* 通知列表 */
.notify-header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding: 0 4px;
}
.notify-list {
  max-height: 400px;
  overflow-y: auto;
}
.notify-item {
  display: flex;
  gap: 10px;
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.2s;
  margin-bottom: 4px;
  &.unread {
    background-color: #EFF6FF;
  }
  &:hover {
    background-color: #F1F5F9;
  }
}
.notify-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #EF4444;
  flex-shrink: 0;
  margin-top: 6px;
}
.notify-content {
  flex: 1;
  min-width: 0;
}
.notify-title {
  font-size: 14px;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 4px;
}
.notify-desc {
  font-size: 13px;
  color: #64748B;
  line-height: 1.5;
  margin-bottom: 4px;
  word-break: break-all;
}
.notify-time {
  font-size: 12px;
  color: #94A3B8;
}
.layout-main {
  background: #F1F5F9;
  min-height: calc(100vh - 60px);
  padding: 20px;
}

/* 底部帮助区域 */
.help-section {
  margin-top: auto;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  border-top: 1px solid #1E293B;
  transition: background-color 0.2s;
  &:hover {
    background-color: #1E293B;
  }
}
.help-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background-color: #334155;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #94A3B8;
  flex-shrink: 0;
}
.help-text {
  flex: 1;
  overflow: hidden;
}
.help-title {
  font-size: 13px;
  font-weight: 600;
  color: #E2E8F0;
  white-space: nowrap;
}
.help-desc {
  font-size: 12px;
  color: #64748B;
  white-space: nowrap;
  margin-top: 2px;
}

/* 帮助弹窗 */
.help-dialog-content {
  p {
    margin: 8px 0;
    color: #475569;
  }
}
.help-info {
  background-color: #F8FAFC;
  padding: 16px;
  border-radius: 8px;
  margin-top: 16px;
  p {
    margin: 8px 0;
    strong {
      color: #1E293B;
    }
  }
}

/* 维修工自定义菜单 */
.custom-menu {
  padding: 8px 12px;
  flex: 1;
  overflow-y: auto;
}
.menu-group-title {
  font-size: 12px;
  color: #64748B;
  padding: 12px 8px 8px;
  letter-spacing: 1px;
}
.menu-divider {
  height: 1px;
  background: #1E293B;
  margin: 8px 0;
}
.menu-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  color: #CBD5E1;
  font-size: 14px;
  transition: all 0.2s;
  margin-bottom: 2px;
  &:hover {
    background: #1E293B;
    color: #E2E8F0;
  }
  &.active {
    background: #1E3A5F;
    color: #60A5FA;
  }
}
.menu-item-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.menu-icon {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  &.blue { background: #1E3A5F; color: #60A5FA; }
  &.orange { background: #451A03; color: #F97316; }
  &.purple { background: #2E1065; color: #A78BFA; }
  &.green { background: #064E3B; color: #34D399; }
  &.gray { background: #334155; color: #94A3B8; }
}
.menu-badge {
  min-width: 22px;
  height: 22px;
  border-radius: 6px;
  background: #1E3A5F;
  color: #60A5FA;
  font-size: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 6px;
  &.orange { background: #451A03; color: #F97316; }
  &.purple { background: #2E1065; color: #A78BFA; }
  &.green { background: #064E3B; color: #34D399; }
}

/* el-menu 中的角标 */
.menu-count-badge {
  min-width: 20px;
  height: 20px;
  border-radius: 10px;
  background: #F59E0B;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0 6px;
  margin-left: 8px;
}
:deep(.el-menu-item .el-menu-tooltip__trigger),
:deep(.el-menu-item) {
  display: flex;
  align-items: center;
}
:deep(.el-menu-item .el-menu-tooltip__trigger .el-icon) {
  margin-right: 8px;
}
</style>