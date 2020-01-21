<template>
  <div class="columns is-multiline">
    <tram-header>Joker-Übärsicht</tram-header>
    <div class="column is-full has-text-centered">
      <slot v-if="operator" name="message"></slot>
      <img src="/jokers.svg">
      <slot name="message2"></slot>
    </div>
  </div>
</template>

<script>
import TramHeader from '../components/TramHeader'

export default {
  components: { TramHeader },
  data () {
    return {
      loggedInUser: null
    }
  }
}
</script>
