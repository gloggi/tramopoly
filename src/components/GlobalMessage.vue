<template>
  <o-notification v-if="messageText" :variant="messageType" :closable="false">
    <h5 class="title is-4">{{ messageTitle }}</h5>
    <p class="is-size-5">{{ messageText }}&#xa;....... Piiiiiiiiiiiiiip.....</p>
  </o-notification>
</template>

<script setup>
import useGlobalMessage from '@/composables/useGlobalMessage.js'

const { messageTitle, messageText, messageType } = useGlobalMessage()
</script>
<script>
export default {
  name: 'GlobalMessage',
}
</script>

<style scoped></style>
