<template>
  <div v-if="activeCallerId" class="card">
    <div class="card-content">
      <header class="card-header-title is-centered">
        Aktivä Aruäf: {{ activeCallerName }}
      </header>
      <button @click="finishCall" class="button is-danger">
        Aktivä Aruäf beändä
      </button>
    </div>
  </div>
</template>

<script setup>
import { useOperatorCall } from '@/composables/useOperatorCall'
import { useUserSession } from '@/stores/userSession'
import { useProfile } from '@/stores/profiles'
import { computed } from 'vue'
import { storeToRefs } from 'pinia'

const { user } = storeToRefs(useUserSession())
const { activeCallerId, finishCall } = useOperatorCall(user, user)
const activeCallerName = computed(() => {
  if (!activeCallerId.value) return ''
  const activeCallerStore = useProfile(activeCallerId.value)
  activeCallerStore.subscribe()
  return activeCallerStore.entry?.scoutName
})
</script>

<script>
export default {
  name: 'ActiveOperatorCallCard',
}
</script>
