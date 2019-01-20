import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'
import Login from '@/components/Login'
import Zentrale from '@/components/Zentrale'
import Action from '@/components/Action'

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
    },
    {
      path: '/zentrale/:group/aktion',
      name: 'action',
      component: Action
    }
  ]
})

router.afterEach((to, from) => {
  const componentNames = to.matched.map(r => r.components.default.name).reverse()
  setPageTitle(componentNames.length ? componentNames[0] : null)
})

export default router

export function setPageTitle (title) {
  if (title && title.length) {
    document.title = title + ' - Tramopoly'
  } else {
    document.title = 'Tramopoly'
  }
}
