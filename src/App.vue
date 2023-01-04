<template>
  <div class="level">
    <div class="level-left">
      <span
        v-if="userSession.isLoggedIn && userSession.user.scoutName"
        class="level-item"
      >
        Willkommä, {{ userSession.user.scoutName }}.
      </span>
      <span v-else-if="userSession.isLoggedIn" class="level-item">
        Willkommä bim Tramopoly.
      </span>
      <a v-if="userSession.isLoggedIn" class="level-item" @click="signOut">
        Uusloggä
      </a>
      <a class="level-item" @click="support">Hilfe</a>
    </div>
  </div>
  <main class="columns is-multiline">
    <tram-header :content="title" :loading="userSession.loading"></tram-header>
    <template v-if="!userSession.loading">
      <login-view v-if="!userSession.isLoggedIn"></login-view>
      <register-view
        v-else-if="userSession.isLoggedIn && !userSession.user.phone"
      ></register-view>
      <router-view v-else>
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

<script>
import { RouterView } from 'vue-router'
import { useProgrammatic } from '@oruga-ui/oruga-next'
import { useUserSessionStore } from './stores/userSession'
import TramHeader from '@/components/TramHeader.vue'
import LoginView from '@/views/LoginView.vue'
import RegisterView from '@/views/RegisterView.vue'
import { setUpAuth, signOut } from '@/auth'

export default {
  name: 'App',
  components: { RegisterView, LoginView, TramHeader, RouterView },
  data: () => {
    const { oruga } = useProgrammatic()
    const userSession = useUserSessionStore()

    return {
      loading: true,
      title: 'Tramopoly',
      oruga,
      userSession,
    }
  },
  mounted() {
    setUpAuth()
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
      this.oruga.notification.open({
        message:
          'Wänn öppis nöd aazäigt wird, tuän mal d Siitä noi ladä 🔄<br/>Wänns dänn immär nonig gaht, lüüt am Cosinus aa:<br/>Null Sibä Nüün, Drüü Acht Sächs, Sächs Sibä, Null Sächs',
        position: 'top',
        indefinite: true,
        closable: true,
      })
    },
  },
}
</script>

<style scoped></style>
