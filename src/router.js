import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'
import Login from '@/components/Login'
import Zentrale from '@/components/Zentrale'

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
      name: 'groupinfo',
      component: Dashboard
    },
    {
      path: '/zentrale',
      name: 'zentrale',
      component: Zentrale
    }
  ]
})

export default router
