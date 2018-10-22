import Vue from 'vue'
import App from './App'
import router from './router'
import { store } from './store'
import Buefy from 'buefy'
import VueFire from 'vuefire'

Vue.use(Buefy)
Vue.use(VueFire)

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  render: h => h(App)
})
