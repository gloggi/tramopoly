<template>
  <div class="level">
    <div class="level-left">
      <div class="level-item is-gap-2">
        <span v-if="isRegistered"> Willkommä, {{ user.scoutName }}. </span>
        <span v-else-if="isLoggedIn"> Willkommä bim Tramopoly. </span>
        <a v-if="isLoggedIn" @click="signOut"> Usloggä </a>
        <a @click="support">Hilfe</a>
      </div>
      <div class="level-item is-gap-2" v-if="isLoggedIn && !isOperator">
        <router-link :to="{ name: 'dashboard' }">Dashboard</router-link>
        <router-link :to="{ name: 'chat' }">Chat</router-link>
      </div>
      <div class="level-item is-gap-2" v-if="isLoggedIn && isAdmin">
        <router-link :to="{ name: 'admin' }">Admin</router-link>
      </div>
    </div>
  </div>
  <main class="columns is-multiline">
    <tram-header :content="title" :loading="loading"></tram-header>
    <template v-if="!loading">
      <template v-if="loading"></template>
      <login-view v-else-if="!isLoggedIn"></login-view>
      <register-view v-else-if="!isRegistered"></register-view>
      <router-view v-else-if="user.groupId" :group-id="user.groupId">
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
const { loading, isLoggedIn, isRegistered, user, isOperator, isAdmin } =
  storeToRefs(userSession)
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
        'Wänn öppis nöd azäigt wird, tuän mal d Sitä noi ladä 🔄<br/>Wänns dänn immär nonig gaht, lüüt am Cosinus a:<br/>Null Sibä Nüün, Drüü Acht Sächs, Sächs Sibä, Null Sächs'
      )
    },
  },
}
</script>

<style scoped></style>
