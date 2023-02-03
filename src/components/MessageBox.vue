<template>
  <article class="message" :class="`is-${type}`">
    <div v-if="header" class="message-header">
      <p>header</p>
    </div>
    <div class="message-body pb-1 px-1">
      <slot></slot>
    </div>
  </article>
</template>

<script>
export default {
  name: 'MessageBox',
  props: {
    header: { type: String, required: false },
    type: { type: String, default: 'info' },
  },
}
</script>

<style scoped></style>
