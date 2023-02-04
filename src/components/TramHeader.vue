<template>
  <div class="column is-full has-text-centered">
    <o-loading :active="loading" :full-page="false" />
    <div class="rails">
      <span class="tram" @click="drive">
        <header class="title" :style="{ color }">
          {{ displayedContent }}
        </header>
      </span>
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
    content() {
      this.drive()
    },
  },
  methods: {
    drive() {
      const timeline = gsap.timeline()
      const screenWidth = window.innerWidth
      if (Math.random() > 0.1) {
        timeline.to('.rails', {
          duration: this.duration,
          x: screenWidth,
          ease: 'back.in(1.5)',
          onComplete: () => {
            this.displayedContent = this.content
          },
        })
        timeline.set('.rails', { x: -screenWidth })
        timeline.to('.rails', {
          duration: this.duration,
          x: 0,
          ease: 'back(1.5)',
        })
      } else {
        timeline.to(
          '.rails',
          {
            duration: this.duration * 1.5,
            rotation: -360,
            ease: 'back.inOut(1.5)',
            onComplete: () => {
              this.displayedContent = this.content
            },
          },
          0.01
        )
        timeline.to(
          '.rails',
          {
            duration: this.duration * 0.9,
            repeat: 1,
            yoyo: true,
            y: -250,
            ease: 'back.in(1.5)',
            onComplete: () => {
              this.displayedContent = this.content
            },
          },
          0
        )
        timeline.set('.rails', { rotation: 0 })
      }
    },
  },
}
</script>

<style scoped>
.column {
  position: relative;
}
.rails {
  display: flex;
  justify-content: center;
}
.tram {
  user-select: none;
}
.title {
  color: #fff;
  display: inline;
  border-image-source: url(/border-tram.min.svg);
  border-image-slice: 0% 49% fill;
  -webkit-border-image-slice: 0% 49% fill;
  border-image-width: 0 2.8em;
  border-image-outset: 0 2.8em;
  padding: 0.5em 0.3em 0.3em;
  line-height: 220%;
  margin: 0.2rem 5.5rem;
  white-space: nowrap;
}
</style>
