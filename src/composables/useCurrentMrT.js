import { computed } from 'vue'
import { defineStore, storeToRefs } from 'pinia'
import { supabase } from '@/client'
import { useGroup } from '@/stores/groups'
import { usePassedTime } from '@/composables/usePassedTime'

export class MrTChange {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = new Date(data.created_at)
    this.vehicle = data.vehicle
    this.direction = data.direction
    this.lastKnownStop = data.last_known_stop
    this.description = data.description
    this.lastChangeAt = new Date(data.last_change_at)
    this.lastReportAt = new Date(data.last_report_at)
    this.deactivated = data.deactivated
    this.shouldCallOperator = data.should_call_operator
    this.groupId = data.group_id || data.group?.id
    this._groupData = data.group
    this._subscribed = subscribe
  }

  get group() {
    if (!this.groupId) return null
    const groupStore = useGroup(this.groupId, {
      initialData: this._groupData,
    })
    if (this._subscribed) groupStore.subscribe()
    else groupStore.fetch()
    return groupStore.entry
  }
}

export function useCurrentMrT() {
  const currentMrTStore = defineStore(`currentMrT`, {
    state: () => ({ data: undefined, subscribed: false, fetching: false }),
    getters: {
      loading: (state) => state.data === undefined,
      entry: (state) =>
        state.data ? new MrTChange(state.data, state.subscribed) : null,
      lastChangeAt() {
        return this.entry?.lastChangeAt
      },
      lastReportAt() {
        return this.entry?.lastReportAt
      },
    },
    actions: {
      subscribe() {
        this.subscribed = true
        supabase
          .channel(`public:mr_t_changes`)
          .on(
            'postgres_changes',
            { event: '*', schema: 'public', table: 'mr_t_changes' },
            () => this.fetch(true)
          )
          .subscribe()
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if ((this.fetching || this.data) && !forceReload) return
        this.fetching = true
        const { data } = await supabase
          .from('mr_t_changes')
          .select('*,last_change_at,last_report_at,group:group_id(*)')
          .order('created_at', { ascending: false })
          .range(0, 0)
          .single()
        this.data = data
        this.fetching = false
      },
    },
  })()

  currentMrTStore.subscribe()
  const { loading, entry, lastChangeAt, lastReportAt } =
    storeToRefs(currentMrTStore)

  function isCurrentMrT(groupId) {
    return !loading.value && entry.value.group.id === groupId
  }

  const mrTShouldCallOperator = computed(() => entry.value?.shouldCallOperator)

  const currentMrTActive = computed(() => !entry.value?.deactivated)

  const timeSinceLastActiveMrTChange = usePassedTime(
    lastChangeAt,
    'timeSinceLastActiveMrTChange',
    (minutesText) =>
      entry.value?.deactivated
        ? '⛔ Dä Mr. T isch momentan nöd aktiv.'
        : minutesText
        ? `🕑 Dä Mr. T isch sit ${minutesText} Minutä bi dä gliichä Gruppä.`
        : '🔭️ Bishär hät no niämärt de Mr. T gfundä...'
  ).text

  const timeSinceLastMrTReport = usePassedTime(
    lastReportAt,
    'timeSinceLastMrTReport',
    (minutesText) =>
      minutesText
        ? `Dä Mr. T hät sich zletscht vor ${minutesText} Minutä gmäldät.`
        : 'Dä aktivi Mr. T hät sich no niä gmäldät...'
  ).text

  async function promptMrT() {
    if (!entry.value) return
    await supabase.from('mr_t_changes').insert({
      ...currentMrTStore.data,
      id: undefined,
      created_at: undefined,
      group: undefined,
      last_change_at: undefined,
      last_report_at: undefined,
      should_call_operator: true,
      deactivated: false,
    })
  }
  async function confiscateMrT() {
    if (!entry.value) return
    await supabase.from('mr_t_changes').insert({
      ...currentMrTStore.data,
      id: undefined,
      created_at: undefined,
      group: undefined,
      last_change_at: undefined,
      last_report_at: undefined,
      should_call_operator: false,
      deactivated: true,
    })
  }
  async function releaseMrT() {
    if (!entry.value) return
    await supabase.from('mr_t_changes').insert({
      ...currentMrTStore.data,
      id: undefined,
      created_at: undefined,
      group: undefined,
      last_change_at: undefined,
      last_report_at: undefined,
      should_call_operator: false,
      deactivated: false,
    })
  }

  return {
    currentMrT: entry,
    isCurrentMrT,
    mrTShouldCallOperator,
    currentMrTActive,
    timeSinceLastActiveMrTChange,
    timeSinceLastMrTReport,
    promptMrT,
    confiscateMrT,
    releaseMrT,
  }
}
