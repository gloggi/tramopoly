import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('./components/Login')
    },
    {
      path: '/',
      name: 'index',
      component: () => import('./components/Dashboard')
    },
    {
      path: '/zentrale',
      name: 'zentrale',
      component: () => import('./components/Zentrale')
    },
    {
      path: '/zentrale/:group',
      name: 'action',
      component: () => import('./components/Action')
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('./components/Admin')
    },
    {
      path: '/admin/report',
      name: 'report',
      component: () => import('./components/Report')
    }
  ],
  scrollBehavior (to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else if (to.hash) {
      return { selector: to.hash }
    } else {
      return { x: 0, y: 0 }
    }
  }
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
