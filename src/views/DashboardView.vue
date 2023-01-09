<template>
  <div
    class="column is-full is-one-third-desktop is-offset-one-third-desktop has-text-centered"
  >
    <slot v-if="operator" name="message"></slot>
    <div v-if="operator" class="card">
      <div class="card-content">
        <o-notification
          v-if="groupIsCurrentlyMrT && mrTShouldCallOperator"
          variant="danger"
          title="Mäldäd oi!"
          :closable="false"
          ><h3>Mäldäd oi!</h3>
          Oii Gruppä isch aktuell Mr. T. Darum müändär mindischtäns all 10
          Minutä bi dä Zentralä aalütä. Bitte mäldäd oi bi oinä
          Telefonischt*innä.</o-notification
        >
        <o-button
          v-if="!operatorBusy"
          variant="primary"
          outlined
          @click="callOperator"
        >
          📞 Zentralä ({{ operatorName }})
        </o-button>
        <button
          v-else-if="loggedInUserIsActiveCaller"
          class="button is-link is-outlined is-danger"
          @click="finishCall"
        >
          🚫 Färtig telefoniärt
        </button>
        <button v-else class="button is-link is-outlined" @click="callOperator">
          🚫 Zentralä ({{ operatorName }} bsetzt)
        </button>
        <div class="is-size-7" style="margin-top: 10px">
          {{ operatorPhoneInWords }}
        </div>
      </div>
    </div>
    <slot name="message2"></slot>
    <group-detail v-if="user.groupId" :group-id="user.groupId" />
    <div v-if="!groupIsCurrentlyMrT">
      <slot name="message3"></slot>
      <div class="card">
        <header class="card-header has-background-light">
          <h4 class="card-header-title title is-4">Wo isch dä Mr. T? 🕵️</h4>
        </header>
        <div class="card-content">
          <p>{{ mrTLocation }}</p>
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

const userSession = useUserSession()
const { user, isOperator } = storeToRefs(userSession)

if (isOperator.value) {
  const router = useRouter()
  router.replace({ name: 'zentrale' })
}

// TODO
const operator = {}
const mrTLocation = ''
const groupIsCurrentlyMrT = false
const mrTShouldCallOperator = false
const operatorBusy = false
const callOperator = () => {}
const operatorName = 'TODO'
const loggedInUserIsActiveCaller = false
const finishCall = () => {}
const operatorPhoneInWords = 'null sibä nüün'
</script>

<script>
export default {
  name: 'DashboardView',
  watch: {
    'user.group.abteilung.operator': function () {},
  },
}
</script>
