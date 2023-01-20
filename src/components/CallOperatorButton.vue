<template>
  <template v-if="operator">
    <o-button
      v-if="!operatorBusy"
      variant="primary"
      outlined
      tag="a"
      target="_blank"
      :href="callLinkHref"
      @click="callOperator"
    >
      <o-icon
        v-if="user.preferredCallMethod === 'whatsapp'"
        icon="whatsapp"
        size="small"
        pack="fab"
        style="vertical-align: text-bottom; margin-right: calc(-0.25em - 1px)"
      ></o-icon>
      <span v-else>📞</span> Zentralä ({{ operatorName }})
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
  </template>
</template>

<script setup>
import { useOperator } from '@/composables/useOperator'
import { useOperatorCall } from '@/composables/useOperatorCall'
import { toRefs } from 'vue'

const props = defineProps({
  user: { type: Object, required: true },
})
const { user } = toRefs(props)

const { operator, operatorName, operatorBusy } = useOperator(user.value.groupId)

const { callOperator, finishCall, loggedInUserIsActiveCaller, callLinkHref } =
  useOperatorCall(user, operator)
</script>

<script>
export default {
  name: 'CallOperatorButton',
}
</script>
