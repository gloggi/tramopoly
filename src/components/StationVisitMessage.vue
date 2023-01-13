<template>
  <div class="vac-message-container">
    <div class="vac-message-card vac-message-current">
      <div class="vac-format-message-wrapper">
        <div class="">
          <div class="vac-format-container">
            <span class=""
              ><span
                >TODO render station visit {{ stationVisit.id }}</span
              ></span
            >
          </div>
        </div>
      </div>
      <div class="vac-text-timestamp">
        <span>{{ stationVisit.created_at }}</span>
      </div>
    </div>
    <span></span>
  </div>
</template>

<script>
export default {
  name: 'StationVisitMessage',
  props: {
    stationVisit: { type: Object, required: true },
  },
}
</script>

<style scoped></style>
