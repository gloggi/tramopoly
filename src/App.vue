<template>
  <div class="level">
    <div class="level-left">
      <span v-if="signedInUser && userScoutName" class="level-item"
        >Willkommä, {{ userScoutName }}.</span
      >
      <span v-else-if="signedInUser" class="level-item">Willkommä.</span>
      <a v-if="signedInUser" class="level-item" @click="signOut"> Uusloggä </a>
      <a v-else @click="signInWithKeycloak" class="level-item"> Iiloggä </a>
      <a class="level-item" @click="support">Hilfe</a>
    </div>
  </div>
  <tram-header :content="title" :loading="loading"></tram-header>
  <router-view @title="(newTitle) => (title = newTitle)">
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

<script>
import { RouterView } from 'vue-router'
import { supabase } from '@/client'
import { useProgrammatic } from '@oruga-ui/oruga-next'
import TramHeader from '@/components/TramHeader.vue'

export default {
  name: 'App',
  components: { TramHeader, RouterView },
  data: () => {
    const { oruga } = useProgrammatic()
    return {
      signedInUser: null,
      oruga,
      loading: true,
      title: 'Tramopoly',
    }
  },
  computed: {
    userScoutName() {
      if (!this.signedInUser) return null
      return this.signedInUser.user_metadata.full_name
    },
  },
  mounted() {
    supabase.auth.getUser().then(({ data: { user } }) => {
      this.signedInUser = user
      this.loading = false
    })
  },
  methods: {
    async signInWithKeycloak() {
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'keycloak',
        options: {
          scopes: 'openid',
          redirectTo: location.protocol + '//' + location.host,
        },
      })
      console.log(data, error)
    },
    async signOut() {
      const { error } = await supabase.auth.signOut()
      console.log(error)
      this.signedInUser = null
    },
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
