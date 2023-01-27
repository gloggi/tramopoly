import { defineStore } from 'pinia'
import { computed } from 'vue'

export function usePassedTime(
  since,
  storeId,
  textCallback,
  refreshIntervalMs = 4000
) {
  const store = defineStore(storeId, {
    state: () => ({ since: new Date(), milliseconds: 0, timeout: null }),
    actions: {
      setSince(newSince) {
        this.since = newSince
        this._update()
      },
      _update() {
        if (this.timeout) clearTimeout(this.timeout)
        this.milliseconds = Date.now() - this.since.valueOf()
        this.timeout = setTimeout(this._update, refreshIntervalMs)
      },
    },
  })()

  function renderDurationInMinutes(milliseconds) {
    if (!milliseconds) return ''
    const halfMinutes = Math.round(milliseconds / 1000.0 / 30.0)
    if (halfMinutes < 2) {
      return 'wenigär als 1'
    } else if (halfMinutes % 2 === 0) {
      return '' + halfMinutes / 2
    } else {
      return '' + (halfMinutes - 1) / 2 + 'ähalb'
    }
  }

  const text = computed(() => {
    if (!since.value) return textCallback(null)
    store.setSince(since.value)
    return textCallback(renderDurationInMinutes(store.milliseconds))
  })

  return { text }
}
