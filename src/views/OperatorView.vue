<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      is-operator
      :loading-groups="loadingGroups"
      :groups="groups"
      :initial-group-id="groupId"
      @room-info="openRoomInfo"
    ></group-chat>
    <o-modal v-model:active="roomInfoModalOpen">
      <div class="card modal-card">
        <div class="card-content">
          <div v-if="activeCallerId" class="card">
            <div
              v-if="loggedInUserIsActiveCaller"
              class="card-content is-flex is-align-items-baseline is-gap-2"
            >
              <button @click="finishCall" class="button is-success is-outlined">
                ☎️ Mich als frei azäigä
              </button>
              Aktuell wird ich als bsetzt azäigt.
            </div>
            <div
              v-else
              class="card-content is-flex is-align-items-baseline is-gap-2"
            >
              <button @click="finishCall" class="button is-danger">
                Aktivä Aruäf beändä
              </button>
              Aktivä Aruäf: {{ activeCaller.scoutName }} ({{
                activeCaller.group?.name
              }})
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
          <mr-t-change-form :group-id="openRoomId"></mr-t-change-form>
          <group-detail :group-id="openRoomId"></group-detail>
        </div>
      </div>
    </o-modal>
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
import GroupDetail from '@/components/GroupDetail'
import MrTChangeForm from '@/components/MrTChangeForm'

const top = ref(null)
const chatTop = ref(0)
const roomInfoModalOpen = ref(false)
const openRoomId = ref(0)

const userSession = useUserSession()
const { isPlayer, user } = storeToRefs(userSession)

const {
  activeCallerId,
  loggedInUserIsActiveCaller,
  activeCaller,
  finishCall,
  callOperator: setActiveCallToBusy,
} = useOperatorCall(user, user)

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

function openRoomInfo(room) {
  openRoomId.value = parseInt(room.roomId)
  roomInfoModalOpen.value = true
}
</script>

<script>
export default {
  name: 'OperatorView',
  props: {
    groupId: { type: Number, required: false },
  },
}
</script>
