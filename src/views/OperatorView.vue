<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      is-operator
      :loading-groups="loadingGroups"
      :groups="groups"
      :initial-group-id="groupId"
    >
      <div v-if="activeCallerId" class="card">
        <div v-if="loggedInUserIsActiveCaller" class="card-content">
          <header class="card-header-title is-centered">
            Aktivä Aruäf: {{ loggedInOperator.activeCall.scoutName }}
          </header>
          <button @click="clearActiveCall" class="button is-danger">
            Aktivä Aruäf beändä
          </button>
        </div>
        <div v-else class="card-content">
          <header class="card-header-title is-centered">
            Aktuell wird ich als bsetzt azäigt.
          </header>
          <button
            @click="clearActiveCall"
            class="button is-success is-outlined"
          >
            ☎️ Mich als frei azäigä
          </button>
        </div>
      </div>
      <div v-else class="card">
        <div class="card-content">
          <button
            @click="setActiveCallToBusy"
            class="button is-info is-outlined"
          >
            📞 Mich als bsetzt azäigä
          </button>
        </div>
      </div>
    </group-chat>
  </div>
</template>

<script setup>
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import { useOperatorCall } from '@/composables/useOperatorCall'
import GroupChat from '@/components/GroupChat.vue'
import { onMounted, ref } from 'vue'
import { useGroups } from '@/stores/groups'

const top = ref(null)
const chatTop = ref(0)

const userSession = useUserSession()
const { isPlayer, user } = storeToRefs(userSession)

const { activeCallerId, loggedInUserIsActiveCaller } = useOperatorCall(
  user,
  user
)

if (isPlayer.value) {
  const router = useRouter()
  router.replace({ name: 'dashboard' })
}

onMounted(() => {
  if (top.value) {
    chatTop.value = Math.ceil(top.value.getBoundingClientRect().bottom)
  }
})

const groupsStore = useGroups()
groupsStore.subscribe()
const { loading: loadingGroups, all: groups } = storeToRefs(groupsStore)

// TODO
const loggedInOperator = { activeCall: {} }
const clearActiveCall = () => {}
const setActiveCallToBusy = () => {}
</script>

<script>
export default {
  name: 'OperatorView',
  props: {
    groupId: { type: Number, required: false },
  },
}
</script>
