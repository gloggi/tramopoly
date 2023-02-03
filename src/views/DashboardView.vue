<template>
  <div
    class="column is-full is-one-third-widescreen is-offset-one-third-widescreen has-text-centered"
  >
    <global-message></global-message>
    <div class="card">
      <mr-t-should-call-notification
        v-if="groupIsCurrentlyMrT && mrTShouldCallOperator"
      ></mr-t-should-call-notification>
      <div
        class="card-content is-flex is-flex-direction-column is-flex-direction-row-widescreen is-justify-content-space-evenly"
        style="gap: 0.5rem"
      >
        <div>
          <o-button
            variant="primary"
            outlined
            @click="$router.push({ name: 'chat', query: { action: 'visit' } })"
            >🚉 Station chaufä</o-button
          >
        </div>
        <div v-if="operator">
          <call-operator-button v-if="user" :user="user"></call-operator-button>
          <div class="is-size-7" style="margin-top: 10px">
            {{ operatorPhoneInWords }}
          </div>
        </div>
        <div>
          <o-button
            variant="primary"
            outlined
            @click="$router.push({ name: 'chat', query: { action: 'visit' } })"
            >🃏 Jokär bsuächä</o-button
          >
        </div>
      </div>
    </div>
    <global-message></global-message>
    <group-detail v-if="user.groupId" :group-id="user.groupId" />
    <div>
      <global-message></global-message>
      <mr-t-should-call-notification
        v-if="groupIsCurrentlyMrT && mrTShouldCallOperator"
      ></mr-t-should-call-notification>
      <div class="card">
        <header class="card-header has-background-light">
          <h4 class="card-header-title title is-4">Wo isch dä Mr. T? 🕵️</h4>
        </header>
        <div v-if="!groupIsCurrentlyMrT" class="card-content">
          <p>Zum das usäfindä, muäsch i dä Zentralä alütä.</p>
          <call-operator-button v-if="user" :user="user"></call-operator-button>
          <p>{{ timeSinceLastActiveMrTChange }}</p>
        </div>
        <div v-else class="card-content">
          <p v-if="!mrTShouldCallOperator">
            Oii Gruppä isch aktuell Mr. T. Darum müändär spätistens alli 10
            Minutä i dä Zentralä alütä.
          </p>
          <call-operator-button v-if="user" :user="user"></call-operator-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useUserSession } from '@/stores/userSession'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import GroupDetail from '@/components/GroupDetail.vue'
import { useOperator } from '@/composables/useOperator'
import CallOperatorButton from '@/components/CallOperatorButton'
import { useCurrentMrT } from '@/composables/useCurrentMrT'
import { computed } from 'vue'
import MrTShouldCallNotification from '@/components/MrTShouldCallNotification'
import GlobalMessage from '@/components/GlobalMessage.vue'

const userSession = useUserSession()
const { user, isOperator } = storeToRefs(userSession)

if (isOperator.value) {
  const router = useRouter()
  router.replace({ name: 'zentrale' })
}

const { operator, operatorPhoneInWords } = useOperator(user.value.groupId)

const { isCurrentMrT, mrTShouldCallOperator, timeSinceLastActiveMrTChange } =
  useCurrentMrT()
const groupIsCurrentlyMrT = computed(() => isCurrentMrT(user.value.groupId))
</script>

<script>
export default {
  name: 'DashboardView',
}
</script>
