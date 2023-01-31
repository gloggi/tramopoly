import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useGroup } from '@/stores/groups'
import { useJoker } from '@/stores/jokers'
import { useImage, useImages } from '@/stores/images'
import { useUserSession } from '@/stores/userSession'

export class JokerVisit {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = data.created_at ? new Date(data.created_at) : null
    this._proofPhotoPath = data.proof_photo_path
    this.groupId = data.group_id || data.group?.id
    this._groupData = data.group
    this.jokerId = data.joker_id || data.joker?.id
    this._jokerData = data.joker
    this.acceptedAt = data.accepted_at ? new Date(data.accepted_at) : null
    this.rejectedAt = data.rejected_at ? new Date(data.rejected_at) : null
    this.operatorComment = data.operator_comment
    this.earnedBonusValue = data.earned_bonus_value
    this.isDuplicate = data.is_duplicate
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

  get joker() {
    if (!this.jokerId) return null
    const jokerStore = useJoker(this.jokerId, {
      initialData: this._jokerData,
    })
    if (this._subscribed) jokerStore.subscribe()
    else jokerStore.fetch()
    return jokerStore.entry
  }

  get proofPhotoUrl() {
    if (!this._proofPhotoPath) return null
    const imageStore = useImage('proofPhotos', this._proofPhotoPath)
    imageStore.fetch()
    return imageStore.url
  }

  get proofPhotoPreviewUrl() {
    if (!this._proofPhotoPath) return null
    const imageStore = useImage(
      'proofPhotos',
      this._proofPhotoPath,
      undefined,
      {
        width: 300,
        height: 200,
      }
    )
    imageStore.fetch()
    return imageStore.url
  }

  toChatFormat() {
    return {
      _id: this.id,
      senderId: useUserSession().userId,
      system: true,
      content: '',
      createdAt: this.createdAt,
      timestamp: this.createdAt.toString().substring(16, 21),
      date: this.createdAt.toDateString(),
    }
  }
}

export const useJokerVisits = (
  options = { select: '*,group:group_id(*),joker:joker_id(*)' }
) => {
  const store = useCollectionStore(
    'joker_visits',
    (data, subscribe) => new JokerVisit(data, subscribe),
    options,
    (entry) => useJokerVisit(entry.id, { ...options, initialData: entry })
  )()
  store.$subscribe((mutation, state) => {
    if (!state.data) return
    useImages(
      'proofPhotos',
      state.data
        .filter((jokerVisit) => jokerVisit.proof_photo_path)
        .map((jokerVisit) => jokerVisit.proof_photo_path)
    ).fetch()
  })
  return store
}

export const useJokerVisit = (
  id,
  options = { select: '*,group:group_id(*),joker:joker_id(*)' }
) =>
  useEntryStore(
    'joker_visits',
    (data, subscribe) => new JokerVisit(data, subscribe),
    options
  )(id)
