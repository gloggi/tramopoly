<template>
  <div class="column is-full has-text-centered">
    <o-loading :active="loading" :full-page="false" />
    <div class="rails">
      <header class="tram title" :style="{ color }">
        {{ displayedContent }}
      </header>
    </div>
  </div>
</template>

<script>
import { gsap } from 'gsap'

export default {
  name: 'TramHeader',
  props: {
    content: { type: String, default: '' },
    loading: { type: Boolean, default: false },
  },
  data() {
    return {
      displayedContent: this.content,
      duration: 0.5,
    }
  },
  computed: {
    color() {
      return this.loading ? '#ffffff00' : '#fff'
    },
  },
  watch: {
    content(newValue) {
      const timeline = gsap.timeline()
      const screenWidth = window.innerWidth
      timeline.to('.rails', {
        duration: this.duration,
        x: screenWidth,
        ease: 'back.in(0.75)',
        onComplete: () => {
          this.displayedContent = newValue
        },
      })
      timeline.set('.rails', { x: -screenWidth })
      timeline.to('.rails', {
        duration: this.duration,
        x: 0,
        ease: 'back(0.75)',
      })
    },
  },
}
</script>

<style scoped>
.column {
  position: relative;
}
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
