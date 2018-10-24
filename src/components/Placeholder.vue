<template>
    <div class="placeholder-line"></div>
</template>

<script>
export default {
  name: 'Placeholder'
}
</script>

<style scoped lang="scss">
  @keyframes placeholderAnimation {
    0% {
      transform: translate3d(-65%, 0, 0);
    }
    100% {
      transform: translate3d(65%, 0, 0);
    }
  }

  .placeholder-line {
    padding: 0;
    position: relative;
    overflow: hidden;
    height: 0.8em;
    width: 80%;
    min-width: 100px;
    background: #eee;
    display: inline-block;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100vw;
      max-width: 1000px;
      height: 100%;
      background: linear-gradient(to right, transparent 0%, darken(#eee, 5%) 15%, transparent 30%);
      animation-duration: 1.5s;
      animation-fill-mode: forwards;
      animation-iteration-count: infinite;
      animation-name: placeholderAnimation;
      animation-timing-function: linear;
    }
  }
</style>
