import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'
import Login from '@/components/Login'
import { auth } from '@/firebaseConfig'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard,
      meta: {
        requiresAuth: true
      }
    }
  ]
})

function routeRequiresAuth (route) {
  return route.matched.some(x => x.meta.requiresAuth)
}

router.beforeEach((to, from, next) => {
  if (routeRequiresAuth(to)) {
    auth.onAuthStateChanged(user => {
      if (!user) {
        next('/login')
      } else {
        next()
      }
    })
  } else {
    next()
  }
})

export default router
