<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      is-operator
      :loading-groups="loadingGroups"
      :groups="groups"
      :initial-group-id="groupId"
      @room-info="openRoomInfo($event.detail[0])"
    >
      <template
        v-for="group in groups"
        #[`room-list-options_${group.id}`]
        :key="group.id"
      >
        <div class="is-flex is-align-items-center">
          <o-icon
            v-if="group.abteilung?.operatorId === user.id"
            icon="eye"
          ></o-icon>
          <span
            v-if="activeCaller && activeCaller.groupId === group.id"
            class="tag is-warning is-small mr-1 is-valign-middle has-text-weight-bold"
          >
            📞 {{ activeCaller.scoutName }}
          </span>
          <span
            v-if="isCurrentMrT(group.id)"
            class="tag is-info is-small is-valign-middle has-text-weight-bold"
            title="🕵️"
          >
            Mr. T
          </span>
        </div>
      </template>
    </group-chat>
    <o-modal v-model:active="roomInfoModalOpen">
      <div class="card modal-card">
        <div class="card-content">
          <div class="card">
            <div class="card-content">
              <div
                class="is-flex is-align-items-baseline is-gap-2"
                v-if="activeCallerId && loggedInUserIsActiveCaller"
              >
                <button
                  @click="finishCall"
                  class="button is-success is-outlined"
                >
                  ☎️ Mich als frei azäigä
                </button>
                Aktuell wird ich als bsetzt azäigt.
              </div>
              <div
                class="is-flex is-align-items-baseline is-gap-2"
                v-else-if="activeCallerId"
              >
                <button @click="finishCall" class="button is-danger">
                  Aktivä Aruäf beändä
                </button>
                Aktivä Aruäf: {{ activeCaller.scoutName }} ({{
                  activeCaller.group?.name
                }})
              </div>
              <div class="is-flex is-align-items-baseline is-gap-2" v-else>
                <button
                  @click="setActiveCallToBusy"
                  class="button is-info is-outlined"
                >
                  📞 Mich als bsetzt azäigä
                </button>
              </div>
              <div>
                <h3 class="title is-size-3 has-text-weight-semibold mt-5">
                  Gruppämitgliedär
                </h3>
                <ul>
                  <li v-for="member in groupMembers" :key="member.id">
                    <strong>{{ member.scoutName }}</strong>
                    {{ member.phone.replace(/^\+?41/, '0') }}
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <mr-t-change-form :group-id="openRoomId"></mr-t-change-form>
          <group-detail :group-id="openRoomId"></group-detail>
          <o-button @click="roomInfoModalOpen = false" icon-left="xmark">
            Tschäsee!
          </o-button>
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
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import { useGroupMembers } from '@/composables/useGroupMembers.js'

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

const { groupMembers } = useGroupMembers(openRoomId)

const { isCurrentMrT } = useCurrentMrT()
</script>

<script>
export default {
  name: 'OperatorView',
  props: {
    groupId: { type: Number, required: false },
  },
}
</script>
