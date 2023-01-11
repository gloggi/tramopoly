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
          tag="a"
          target="_blank"
          :href="callLinkHref"
          @click="callOperator"
        >
          📞 Zentralä ({{ operatorName }})
        </o-button>
        <o-button
          v-else-if="loggedInUserIsActiveCaller"
          variant="danger"
          outlined
          @click="finishCall"
        >
          🚫 Färtig telefoniärt
        </o-button>
        <o-button
          v-else
          variant="danger"
          class="button is-link is-outlined"
          tag="a"
          target="_blank"
          :href="callLinkHref"
          @click="callOperator"
        >
          🚫 Zentralä ({{ operatorName }} bsetzt)
        </o-button>
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
import { useOperator } from '@/composables/useOperator'
import { useOperatorCall } from '@/composables/useOperatorCall'

const userSession = useUserSession()
const { user, isOperator } = storeToRefs(userSession)

if (isOperator.value) {
  const router = useRouter()
  router.replace({ name: 'zentrale' })
}

const { operator, operatorName, operatorBusy, operatorPhoneInWords } =
  useOperator(user.value.groupId)

const { callOperator, finishCall, loggedInUserIsActiveCaller, callLinkHref } =
  useOperatorCall(user, operator)

// TODO
const mrTLocation = ''
const groupIsCurrentlyMrT = false
const mrTShouldCallOperator = false
</script>

<script>
export default {
  name: 'DashboardView',
  watch: {
    'user.group.abteilung.operator': function () {},
  },
}
</script>
