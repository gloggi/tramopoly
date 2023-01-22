import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useMessages } from '@/stores/messages'
import { applyFilterToQuery } from '@/stores/collectionStore'
import { useStationVisits } from '@/stores/stationVisits'
import { showAlert } from '@/utils'

export const useChatContents = (groupId) => {
  const PAGE_SIZE = 10

  function allEntriesFrom(stores) {
    const result = stores
      .flatMap((store) => store.all || [])
      .map((entry) => entry.toChatFormat())
    result.sort((a, b) => a.createdAt - b.createdAt)
    return result
  }

  return defineStore(`chatContents-${groupId}`, {
    state: () => ({
      // TODO add joker stores
      messagesStores: [],
      stationVisitsStores: [],
      subscribed: false,
      fetching: false,
      fetchingMore: false,
      cursor: undefined,
    }),
    getters: {
      allStores: (state) =>
        state.messagesStores.concat(state.stationVisitsStores),
      loading() {
        return this.allStores.some((store) => store.loading)
      },
      /**
       * @returns {array}
       */
      all() {
        return allEntriesFrom(this.allStores)
      },
      allMessages: (state) =>
        state.messagesStores.flatMap((store) => store.all || []),
      allStationVisits: (state) =>
        state.stationVisitsStores.flatMap((store) => store.all || []),
    },
    actions: {
      subscribe() {
        this.subscribed = true
        this.allStores.forEach((store) => store.subscribe())
        return this.fetch()
      },
      async fetch(forceReload = false) {
        if (this.fetching && !forceReload) return
        this.fetching = true
        await Promise.all(
          this.allStores.map((store) => store.fetch(forceReload))
        )
        this.fetching = false
      },
      async fetchMore() {
        if (this.fetchingMore) return true
        this.fetchingMore = true

        const { data, error } = await applyFilterToQuery(
          supabase
            .from('chat_contents')
            .select('id,created_at')
            .eq('group_id', groupId)
            .order('created_at', { ascending: false })
            .order('id', { ascending: false }),
          this._oldEnoughFilter()
        ).range(0, PAGE_SIZE - 1)
        if (error) {
          console.log(error)
          showAlert(
            'Öppis isch schiäf gangä bim Ladä vo de Chät-Nachrichtä. Probiär mal d Siitä neu z ladä.'
          )
          return
        }
        const newCursor = this._cursorFrom(data)

        const moreMessagesStore = useMessages({
          filter: { group_id: groupId, ...this._nextPageFilter(newCursor) },
          select:
            '*,message_files(*),sender:sender_id(*),reply_message:reply_message_id(*,message_files(*),sender:sender_id(*))',
        })
        const messagesLoaded = this.subscribed
          ? moreMessagesStore.subscribe()
          : moreMessagesStore.fetch()
        this.messagesStores = [...this.messagesStores, moreMessagesStore]

        const moreStationVisitsStore = useStationVisits({
          filter: { group_id: groupId, ...this._nextPageFilter(newCursor) },
          select: '*,group:group_id(*),station:station_id(*)',
        })
        const stationVisitsLoaded = this.subscribed
          ? moreStationVisitsStore.subscribe()
          : moreStationVisitsStore.fetch()
        this.stationVisitsStores = [
          ...this.stationVisitsStores,
          moreStationVisitsStore,
        ]

        // TODO add joker store

        await Promise.all([messagesLoaded, stationVisitsLoaded])

        this.cursor = newCursor
        this.fetchingMore = false

        // Return value indicates whether there might be more messages to fetch
        return data.length === PAGE_SIZE
      },
      _cursorFrom(data) {
        if (data.length !== PAGE_SIZE) return null
        return {
          ...data[data.length - 1],
          createdAt: new Date(data[data.length - 1].created_at),
        }
      },
      _oldEnoughFilter() {
        if (!this.cursor) return null
        const createdAt = this.cursor.createdAt.toISOString()
        return this._or(
          this._filter('created_at', 'lt', createdAt),
          this._and(
            this._filter('created_at', 'eq', createdAt),
            this._filter('id', 'lt', this.cursor.id)
          )
        )
      },
      _newEnoughFilter(newCursor) {
        if (!newCursor) return null
        const createdAt = newCursor.createdAt.toISOString()
        return this._or(
          this._filter('created_at', 'gt', createdAt),
          this._and(
            this._filter('created_at', 'eq', createdAt),
            this._filter('id', 'gte', newCursor.id)
          )
        )
      },
      _nextPageFilter(newCursor) {
        return this._or(
          '',
          this._and(this._oldEnoughFilter(), this._newEnoughFilter(newCursor))
        )
      },
      _filter(column, operator, value) {
        return `${column}.${operator}.${value}`
      },
      _and(a, b) {
        if (!a && !b) return null
        if (!a) return b
        if (!b) return a
        return `and(${a},${b})`
      },
      _or(a, b) {
        if (!a && !b) return {}
        const normalizedA = a ? a : 'id.is.null'
        const normalizedB = b ? b : 'id.is.null'
        const result = {
          or: [`${normalizedA},${normalizedB}`],
        }
        function toString() {
          return `or(${normalizedA},${normalizedB})`
        }
        result.toString = toString.bind(result)
        return result
      },
    },
  })()
}
