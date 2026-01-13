<template>
  <div class="level">
    <div class="level-left">
      <div class="level-item is-gap-3">
        <span v-if="isRegistered"> Willkommä, {{ user.scoutName }}. </span>
        <span v-else-if="isLoggedIn"> Willkommä bim Tramopoly. </span>
        <a v-if="isLoggedIn" @click="signOut"> Usloggä </a>
        <a @click="support">Hilfe</a>
      </div>
      <div class="level-item is-gap-3" v-if="isLoggedIn && !isOperator">
        <router-link :to="{ name: 'dashboard' }">Mini Gruppä</router-link>
        <router-link :to="{ name: 'chat' }">
          Chat
          <span
            v-if="unseenCount > 0"
            class="tag is-danger is-small is-rounded is-valign-text-top has-text-weight-bold"
            >{{ unseenCount }}</span
          >
        </router-link>
        <router-link v-if="mapUrl" :to="{ name: 'map' }">
          Übärsichts-Chartä
        </router-link>
      </div>
      <div class="level-item is-gap-3" v-if="isLoggedIn && !isPlayer">
        <router-link :to="{ name: 'zentrale' }">Zentralä</router-link>
        <router-link v-if="mapUrl" :to="{ name: 'overview' }">Chartä</router-link>
      </div>
      <div class="level-item is-gap-3" v-if="isLoggedIn && isAdmin">
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
      <router-view
        v-else-if="user.groupId"
        :group-id="user.groupId"
      ></router-view>
    </template>
  </main>
</template>

<script setup>
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'
import useUnseenChatActivity from '@/composables/useUnseenChatActivity'
import { computed } from 'vue'
import useMapUrl from '@/composables/useMapUrl.js'

const userSession = useUserSession()
const {
  loading,
  isLoggedIn,
  isRegistered,
  user,
  isPlayer,
  isOperator,
  isAdmin,
} = storeToRefs(userSession)
userSession.subscribeAuth()
userSession.fetchAuth()

const { activityCounts } = useUnseenChatActivity()
const unseenCount = computed(() => {
  if (
    !user.value?.groupId ||
    !activityCounts.value ||
    !(user.value?.groupId in activityCounts.value)
  ) {
    return 0
  }
  return activityCounts.value[user.value?.groupId] || 0
})

const { mapUrl } = useMapUrl()
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
