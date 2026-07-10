import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/store/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/Login.vue'),
    meta: { noAuth: true }
  },
  {
    path: '/register/resident',
    name: 'ResidentRegister',
    component: () => import('@/views/register/ResidentRegister.vue'),
    meta: { noAuth: true }
  },
  {
    path: '/register/worker',
    name: 'WorkerRegister',
    component: () => import('@/views/register/WorkerRegister.vue'),
    meta: { noAuth: true }
  },
  {
    path: '/',
    component: () => import('@/components/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/common/Dashboard.vue')
      },
      {
        path: 'repair/create',
        name: 'RepairCreate',
        component: () => import('@/views/resident/RepairCreate.vue'),
        meta: { roles: ['resident'] }
      },
      {
        path: 'repair/list',
        name: 'RepairList',
        component: () => import('@/views/resident/RepairList.vue'),
        meta: { roles: ['resident'] }
      },
      {
        path: 'repair/stats',
        name: 'ResidentStats',
        component: () => import('@/views/resident/ResidentStats.vue'),
        meta: { roles: ['resident'] }
      },
      {
        path: 'evaluations/my',
        name: 'MyEvaluations',
        component: () => import('@/views/resident/MyEvaluations.vue'),
        meta: { roles: ['resident'] }
      },
      {
        path: 'workers/list',
        name: 'WorkerList',
        component: () => import('@/views/resident/WorkerList.vue'),
        meta: { roles: ['resident'] }
      },
      {
        path: 'repair/history',
        name: 'RepairHistory',
        component: () => import('@/views/worker/RepairHistory.vue'),
        meta: { roles: ['worker'] }
      },
      {
        path: 'repair/manage',
        name: 'RepairManage',
        component: () => import('@/views/admin/RepairManage.vue'),
        meta: { roles: ['admin'] }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/common/Profile.vue')
      },
      {
        path: 'announcements',
        name: 'AnnouncementList',
        component: () => import('@/views/common/AnnouncementList.vue')
      },
      {
        path: 'workers',
        name: 'Workers',
        component: () => import('@/views/admin/WorkerManage.vue'),
        meta: { roles: ['admin'] }
      },
      {
        path: 'residents',
        name: 'Residents',
        component: () => import('@/views/admin/ResidentManage.vue'),
        meta: { roles: ['admin'] }
      },
      {
        path: 'admin/dashboard',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/AdminDashboard.vue'),
        meta: { roles: ['admin'] }
      },
      {
        path: 'admin/announcement',
        name: 'AnnouncementManage',
        component: () => import('@/views/admin/AnnouncementManage.vue'),
        meta: { roles: ['admin'] }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  if (to.meta.noAuth) {
    if (userStore.isLoggedIn && to.name === 'Login') {
      return next('/')
    }
    return next()
  }
  if (!userStore.isLoggedIn) {
    return next('/login')
  }
  if (to.meta.roles && !to.meta.roles.includes(userStore.role)) {
    return next('/')
  }
  next()
})

export default router