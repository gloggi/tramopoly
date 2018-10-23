import Vue from 'vue'
import App from './App'
import router from './router.js'
import Buefy from 'buefy'
import VueFire from 'vuefire'

Vue.use(Buefy)
Vue.use(VueFire)

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
