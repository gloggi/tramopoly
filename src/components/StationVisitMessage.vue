<template>
  <div v-if="stationVisit.proofPhotoUrl">
    <a :href="stationVisit.proofPhotoUrl" target="_blank">
      <span
        class="station-visit-image"
        :style="{ backgroundImage: `url('${stationVisit.proofPhotoUrl}')` }"
      ></span
    ></a>
  </div>

  <span>
    TODO {{ stationVisit.group?.name }} isch bi
    {{ stationVisit.station?.name }} gsi
  </span>
  <div class="vac-text-timestamp">
    <span>{{ stationVisit.createdAt?.toLocaleString() }}</span>
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
