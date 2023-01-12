<template>
  <div class="level">
    <div class="level-left">
      <span v-if="isRegistered" class="level-item">
        Willkommä, {{ user.scoutName }}.
      </span>
      <span v-else-if="isLoggedIn" class="level-item">
        Willkommä bim Tramopoly.
      </span>
      <a v-if="isLoggedIn" class="level-item" @click="signOut"> Uusloggä </a>
      <a class="level-item" @click="support">Hilfe</a>
    </div>
  </div>
  <main class="columns is-multiline">
    <tram-header :content="title" :loading="loading"></tram-header>
    <template v-if="!loading">
      <template v-if="loading"></template>
      <login-view v-else-if="!isLoggedIn"></login-view>
      <register-view v-else-if="!isRegistered"></register-view>
      <router-view v-else-if="user.groupId">
        <template #message="{ message, type, title }">
          <o-notification
            v-if="message"
            :variant="type"
            :closable="false"
            aria-close-label="Close notification"
          >
            <h5 class="title is-5">{{ title }}</h5>
            <p>{{ message }}&#xa;....... Piiiiiiiiiiiiiip.....</p>
          </o-notification>
        </template>
        <template #message2="{ message, type, title }">
          <o-notification
            v-if="message"
            :variant="type"
            :closable="false"
            aria-close-label="Close notification"
          >
            <h5 class="title is-5">{{ title }}</h5>
            <p>{{ message }}&#xa;....... Piiiiiiiiiiiiiip.....</p>
          </o-notification>
        </template>
        <template #message3="{ message, type, title }">
          <o-notification
            v-if="message"
            :variant="type"
            :closable="false"
            aria-close-label="Close notification"
          >
            <h5 class="title is-5">{{ title }}</h5>
            <p>{{ message }}&#xa;....... Piiiiiiiiiiiiiip.....</p>
          </o-notification>
        </template>
      </router-view>
    </template>
  </main>
</template>

<script setup>
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'

const userSession = useUserSession()
const { loading, isLoggedIn, isRegistered, user } = storeToRefs(userSession)
userSession.subscribeAuth()
userSession.fetchAuth()
</script>

<script>
import { RouterView } from 'vue-router'
import TramHeader from '@/components/TramHeader.vue'
import LoginView from '@/views/LoginView.vue'
import RegisterView from '@/views/RegisterView.vue'
import { signOut } from '@/auth'
import { showAlert } from '@/utils'

export default {
  name: 'App',
  components: { RegisterView, LoginView, TramHeader, RouterView },
  data: () => {
    return {
      title: 'Tramopoly',
    }
  },
  watch: {
    $route() {
      this.title = this.$route.meta.title || 'Tramopoly'
    },
    title() {
      document.title =
        this.title + (this.title !== 'Tramopoly' ? ' - Tramopoly' : '')
    },
  },
  methods: {
    signOut,
    support() {
      showAlert(
        'Wänn öppis nöd aazäigt wird, tuän mal d Siitä noi ladä 🔄<br/>Wänns dänn immär nonig gaht, lüüt am Cosinus aa:<br/>Null Sibä Nüün, Drüü Acht Sächs, Sächs Sibä, Null Sächs'
      )
    },
  },
}
</script>

<style scoped></style>
