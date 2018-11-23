<template>
  <div class="columns is-multiline">
    <header class="title has-text-centered column is-full">Zentrale</header>
  </div>
</template>

<script>
import { requireOperator } from '@/firebaseConfig'

export default {
  name: 'Zentrale',
  beforeRouteEnter (to, from, next) {
    requireOperator(to, from, next)
  }
}
</script>
