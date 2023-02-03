<template>
  <div class="column is-full has-text-centered">
    <global-message></global-message>
    <img v-if="mapUrl" :src="mapUrl" alt="Chartä mit dä Jokärs" />
    <global-message></global-message>
  </div>
</template>

<script setup>
import useMapUrl from '@/composables/useMapUrl.js'
import GlobalMessage from '@/components/GlobalMessage.vue'

const { mapUrl } = useMapUrl()
</script>

<script>
export default {
  name: 'MapView',
}
</script>
