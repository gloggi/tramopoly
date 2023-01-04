import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import Oruga from '@oruga-ui/oruga-next'
import { bulmaConfig } from '@oruga-ui/theme-bulma'

import '@/assets/main.scss'

import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { createPinia } from 'pinia'

const pinia = createPinia()

library.add(fas)

const app = createApp(App)

app.use(router)
app.use(pinia)
app.use(Oruga, {
  ...bulmaConfig,
  iconPack: 'fas',
  iconComponent: 'vue-fontawesome',
})
app.component('vue-fontawesome', FontAwesomeIcon)
app.mount('#app')
