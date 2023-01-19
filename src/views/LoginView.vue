<template>
  <div
    class="column is-full is-one-third-widescreen is-offset-one-third-widescreen mt-5 is-flex is-justify-content-center"
  >
    <o-button class="midata-button" @click="signInWithOAuth"
      >Mit MiData iigloggä</o-button
    >
  </div>
</template>

<script>
import { signInWithOAuth } from '@/auth'

export default {
  name: 'LoginView',
  methods: {
    signInWithOAuth,
  },
}
</script>

<style lang="scss">
.midata-button {
  background-color: #f5f2f4;
  background-image: url(/midata.svg);
  background-position: left 0.75rem center;
  background-repeat: no-repeat;
  background-size: 1.5rem 1.5rem;
  border-color: #521d3a !important;
  color: #000;
  overflow: hidden;
  padding-left: 4rem !important;
  position: relative;

  &:hover {
    color: #000;
    background-color: #ece6ea;
    border-color: #521d3a;

    &::before {
      border-left-color: #521d3a;
    }
  }

  &::before {
    content: '';
    position: absolute;
    top: 0;
    bottom: 0;
    left: 3rem;
    border-left: 1px solid #521d3a;
    transition: border-left-color 0.15s ease-in-out;
  }
}
</style>
