import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import Oruga from '@oruga-ui/oruga-next'
import { bulmaConfig } from '@oruga-ui/theme-bulma'

import '@/assets/main.scss'
import '@/assets/bulma.scss'

const app = createApp(App)

app.use(router)

app.use(Oruga, bulmaConfig)

app.mount('#app')
