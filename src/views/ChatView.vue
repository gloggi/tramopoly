<template>
  <div ref="top" style="width: 100%; height: 0" />
  <div class="fullscreen-chat" :style="{ top: chatTop + 'px' }">
    <group-chat
      :initial-group-id="groupId"
      :loading-groups="loadingGroups"
      :groups="groups"
      init-message="Willkommä bim Tramopoly-Chät 💬 Da chasch mit de Zentralä kommuniziärä. Mit äm Tram-Chnopf chasch Stationä und Jokärs bsuächä ↴"
      @toggle-rooms-list="$router.push({ name: 'dashboard' })"
    ></group-chat>
  </div>
  <visit-modal
    v-if="groupId"
    v-model:active="modalOpen"
    :group-id="groupId"
  ></visit-modal>
</template>

<script>
import GroupChat from '@/components/GroupChat.vue'
import { useUserSession } from '@/stores/userSession'
import { useOperator } from '@/composables/useOperator'
import { useGroups } from '@/stores/groups'
import VisitModal from '@/components/VisitModal'

export default {
  name: 'ChatView',
  components: { VisitModal, GroupChat },
  props: {
    groupId: { type: Number, required: true },
  },
  data() {
    const userSessionStore = useUserSession()
    const groupsStore = useGroups({
      filter: { id: this.groupId },
      select: '*,abteilung:abteilungen(*,operator:operator_id(*))',
    })
    groupsStore.subscribe()

    return {
      modalOpen: false,
      chatTop: 0,
      operatorName: useOperator(this.groupId).operatorName,
      userId: userSessionStore.userId,
      userName: userSessionStore.user?.scoutName,
      groupsStore,
      allChatContentLoaded: false,
    }
  },
  computed: {
    loadingGroups() {
      return this.groupsStore.loading
    },
    groups() {
      return this.groupsStore.all
    },
  },
  async mounted() {
    if (this.$refs.top) {
      this.chatTop = Math.ceil(this.$refs.top.getBoundingClientRect().bottom)
    }
    if (this.$route.query.action === 'visit') {
      this.modalOpen = true
    }
  },
}
</script>
