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
      name: 'index',
      component: Dashboard
    },
    {
      path: '/zentrale',
      name: 'zentrale',
      component: Zentrale
    }
  ]
})

router.afterEach((to, from) => {
  const componentNames = to.matched.map(r => r.components.default.name).reverse()
  const title = componentNames.length ? componentNames[0] : null
  if (title != null && title.length) {
    document.title = title + ' - Tramopoly'
  } else {
    document.title = 'Tramopoly'
  }
})

export default router
