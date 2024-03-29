import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useMessages } from '@/stores/messages'
import { applyFilterToQuery } from '@/stores/collectionStore'
import { useStationVisits } from '@/stores/stationVisits'
import { useJokerVisits } from '@/stores/jokerVisits'
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
      messagesStores: [],
      stationVisitsStores: [],
      jokerVisitsStores: [],
      subscribed: false,
      fetching: false,
      fetchingMore: false,
      cursor: undefined,
    }),
    getters: {
      allStores: (state) =>
        state.messagesStores
          .concat(state.stationVisitsStores)
          .concat(state.jokerVisitsStores),
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
      allJokerVisits: (state) =>
        state.jokerVisitsStores.flatMap((store) => store.all || []),
    },
    actions: {
      subscribe() {
        if (this.subscribed) return
        this.subscribed = true

        // In order to reduce the number of subscriptions, we only subscribe once to each table
        // and then delegate the callback to all our paginaged slice stores
        this._subscribeAll('messages', 'messagesStores')
        this._subscribeAll('station_visits', 'stationVisitsStores')
        this._subscribeAll('joker_visits', 'jokerVisitsStores')

        return this.fetch()
      },
      _subscribeAll(table, storesGetter) {
        supabase
          .channel(`chatContent-${table}`)
          .on('postgres_changes', { event: '*', schema: 'public', table }, () =>
            this[storesGetter].forEach((store) => store.fetch(true))
          )
          .subscribe()
      },
      async fetch(forceReload = false) {
        if (this.fetching) return
        this.fetching = true
        await Promise.allSettled(
          this.allStores.map((store) => store.fetch(forceReload))
        )
        this.fetching = false
      },
      async fetchMore() {
        if (this.fetchingMore) return undefined
        this.fetchingMore = true

        const { data, error } = await applyFilterToQuery(
          supabase
            .from('chat_contents')
            .select('id,created_at')
            .overlaps('accessible_to', [groupId])
            .order('created_at', { ascending: false })
            .order('id', { ascending: false }),
          this._oldEnoughFilter()
        ).range(0, PAGE_SIZE - 1)
        if (error) {
          console.log(error)
          showAlert(
            'Öppis isch schiäf gangä bim Ladä vo de Chät-Nachrichtä. Probiär mal d Sitä neu z ladä.'
          )
          return
        }
        const newCursor = this._cursorFrom(data)

        const moreMessagesStore = useMessages({
          filter: { group_id: groupId, ...this._nextPageFilter(newCursor) },
          select:
            '*,message_files(*),sender:sender_id(*),reply_message:reply_message_id(*,message_files(*),sender:sender_id(*))',
        })
        this.messagesStores = [...this.messagesStores, moreMessagesStore]

        const moreStationVisitsStore = useStationVisits({
          filter: {
            overlaps: ['accessible_to', [groupId]],
            ...this._nextPageFilter(newCursor),
          },
          select:
            '*,is_purchase,is_duplicate,group:group_id(*),station:station_id(*)',
        })
        this.stationVisitsStores = [
          ...this.stationVisitsStores,
          moreStationVisitsStore,
        ]

        const moreJokerVisitsStore = useJokerVisits({
          filter: { group_id: groupId, ...this._nextPageFilter(newCursor) },
          select: '*,is_duplicate,group:group_id(*),joker:joker_id(*)',
        })
        this.jokerVisitsStores = [
          ...this.jokerVisitsStores,
          moreJokerVisitsStore,
        ]

        await Promise.all([
          moreMessagesStore.fetch(),
          moreStationVisitsStore.fetch(),
          moreJokerVisitsStore.fetch(),
        ])

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
