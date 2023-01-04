<template>
  <div class="column is-full has-text-centered">
    <header class="tram title">
      <slot></slot>
    </header>
  </div>
</template>

<script>
export default {
  name: 'TramHeader',
}
</script>

<style scoped>
.tram {
  color: #fff;
  display: inline;
  border-image-source: url(/border-tram.min.svg);
  border-image-slice: 0% 49% fill;
  -webkit-border-image-slice: 0% 49% fill;
  border-image-width: 0 2.8em;
  border-image-outset: 0 2.8em;
  padding: 0.5em 0.3em 0.3em;
  line-height: 220%;
}
</style>
