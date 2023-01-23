import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'

export class Joker {
  constructor(data, subscribe) {
    this.id = data.id
    this.name = data.name
    this.value = data.value
    this.challenge = data.challenge
    this.bonusCallValue = data.bonus_call_value
    this._subscribed = subscribe
  }
}

export const useJokers = (options = { select: '*' }) =>
  useCollectionStore(
    'jokers',
    (data, subscribe) => new Joker(data, subscribe),
    options,
    (entry) => useJoker(entry.id, { ...options, initialData: entry })
  )()

export const useJoker = (id, options = { select: '*' }) =>
  useEntryStore(
    'jokers',
    (data, subscribe) => new Joker(data, subscribe),
    options
  )(id)
