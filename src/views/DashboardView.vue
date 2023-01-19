<template>
  <div
    class="column is-full is-one-third-widescreen is-offset-one-third-widescreen has-text-centered"
  >
    <slot v-if="operator" name="message"></slot>
    <div class="card">
      <div
        class="card-content is-flex is-flex-direction-column is-flex-direction-row-widescreen is-justify-content-space-evenly"
        style="gap: 0.5rem"
      >
        <div>
          <o-button
            variant="primary"
            outlined
            @click="
              $router.push({ name: 'chat', query: { action: 'visitStation' } })
            "
            >🚉 Station chaufä</o-button
          >
        </div>
        <div v-if="operator">
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
          <call-operator-button v-if="user" :user="user"></call-operator-button>
          <div class="is-size-7" style="margin-top: 10px">
            {{ operatorPhoneInWords }}
          </div>
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
          <p>Zum das usäfindä, muäsch i dä Zentralä aalütä.</p>
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

const userSession = useUserSession()
const { user, isOperator } = storeToRefs(userSession)

if (isOperator.value) {
  const router = useRouter()
  router.replace({ name: 'zentrale' })
}

const { operator, operatorPhoneInWords } = useOperator(user.value.groupId)

// TODO
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
