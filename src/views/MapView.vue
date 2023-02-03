<template>
  <div class="column is-full has-text-centered">
    <slot name="message"></slot>
    <img v-if="mapUrl" :src="mapUrl" alt="Chartä mit dä Jokärs" />
    <slot name="message2"></slot>
  </div>
</template>

<script setup>
import useMapUrl from '@/composables/useMapUrl.js'

const { mapUrl } = useMapUrl()
</script>

<script>
export default {
  name: 'MapView',
}
</script>
