import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useGroup } from '@/stores/groups'
import { useStation } from '@/stores/stations'
import { useImage, useImages } from '@/stores/images'
import { useUserSession } from '@/stores/userSession'

export class StationVisit {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = new Date(data.created_at)
    this._proofPhotoPath = data.proof_photo_path
    this.groupId = data.group_id || data.group?.id
    this._groupData = data.group
    this.stationId = data.station_id || data.station?.id
    this._stationData = data.station
    this.acceptedAt = new Date(data.accepted_at)
    this.rejectedAt = new Date(data.rejected_at)
    this.needsVerification = data.needs_verification
    this.verifiedAt = new Date(data.verified_at)
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

  get station() {
    if (!this.stationId) return null
    const stationStore = useStation(this.stationId, {
      initialData: this._stationData,
    })
    if (this._subscribed) stationStore.subscribe()
    else stationStore.fetch()
    return stationStore.entry
  }

  get proofPhotoUrl() {
    if (!this._proofPhotoPath) return null
    const imageStore = useImage('proofPhotos', this._proofPhotoPath)
    imageStore.fetch()
    return imageStore.url
  }

  toMessage() {
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

export const useStationVisits = (
  options = { select: '*,group:group_id(*),station:station_id(*)' }
) => {
  const store = useCollectionStore(
    'station_visits',
    (data, subscribe) => new StationVisit(data, subscribe),
    options,
    (entry) => useStationVisit(entry.id, { ...options, initialData: entry })
  )()
  store.$subscribe((mutation, state) => {
    if (!state.data) return
    useImages(
      'proofPhotos',
      state.data
        .filter((stationVisit) => stationVisit.proof_photo_path)
        .map((stationVisit) => stationVisit.proof_photo_path)
    ).fetch()
  })
  return store
}

export const useStationVisit = (
  id,
  options = { select: '*,operator:operator_id(*)' }
) =>
  useEntryStore(
    'station_visits',
    (data, subscribe) => new StationVisit(data, subscribe),
    options
  )(id)
