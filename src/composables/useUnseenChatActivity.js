import { useUserSession } from '@/stores/userSession.js'
import { supabase } from '@/client.js'
import { defineStore, storeToRefs } from 'pinia'
import { computed } from 'vue'

export default function useUnseenChatActivity() {
  const { userId } = storeToRefs(useUserSession())

  const subscribeToTable = (table, callback) => {
    supabase
      .channel(`unseenActivityCount-${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe()
  }

  const unseenChatActivityStore = defineStore('unseenActivityCount', {
    state: () => ({
      data: undefined,
      subscribed: false,
      fetching: false,
    }),
    getters: {
      loading: (state) => state.data === undefined,
      counts() {
        if (this.loading) return {}
        return Object.fromEntries(
          this.data.map(
            ({
              group_id,
              unrated_station_visits,
              unrated_joker_visits,
              unseen_chat_activity,
            }) => [
              group_id,
              unrated_station_visits +
                unrated_joker_visits +
                unseen_chat_activity,
            ]
          )
        )
      },
      activityCounts() {
        if (this.loading) return {}
        return Object.fromEntries(
          this.data.map(({ group_id, unseen_chat_activity }) => [
            group_id,
            unseen_chat_activity,
          ])
        )
      },
    },
    actions: {
      subscribe() {
        if (this.subscribed) return
        this.subscribed = true
        subscribeToTable('joker_visits', () => this.fetch(true))
        subscribeToTable('station_visits', () => this.fetch(true))
        subscribeToTable('unseen_chat_activity', () => this.fetch(true))
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.fetching || (this.data && !forceReload)) return
        this.fetching = true
        const { data } = await supabase.rpc('unseen_activity_count')
        this.data = data
        this.fetching = false
      },
    },
  })()

  const counts = computed(() => {
    unseenChatActivityStore.subscribe()
    return unseenChatActivityStore.counts
  })

  const activityCounts = computed(() => {
    unseenChatActivityStore.subscribe()
    return unseenChatActivityStore.activityCounts
  })

  async function markRoomAsSeen(groupId) {
    await supabase.from('unseen_chat_activity').upsert(
      {
        profile_id: userId.value,
        group_id: groupId.value,
        unseen_activity_count: 0,
      },
      { onConflict: 'profile_id,group_id' }
    )
  }

  async function incrementUnseenCounter(groupId) {
    await supabase.rpc('increment_unseen_counter', {
      chat_id: groupId,
      author_id: userId,
    })
  }

  return { markRoomAsSeen, incrementUnseenCounter, counts, activityCounts }
}
