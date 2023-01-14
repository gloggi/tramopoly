import { useCollectionStore } from '@/stores/collectionStore'
import { useEntryStore } from '@/stores/entryStore'
import { useGroup } from '@/stores/groups'
import { useStation } from '@/stores/stations'

export class StationVisit {
  constructor(data, subscribe) {
    this.id = data.id
    this.createdAt = new Date(data.created_at)
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
}

export const useStationVisits = (
  options = { select: '*,group:group_id(*),station:station_id(*)' }
) =>
  useCollectionStore(
    'station_visits',
    (data, subscribe) => new StationVisit(data, subscribe),
    options,
    (entry) => useStationVisit(entry.id, { ...options, initialData: entry })
  )()

export const useStationVisit = (
  id,
  options = { select: '*,operator:operator_id(*)' }
) =>
  useEntryStore(
    'station_visits',
    (data, subscribe) => new StationVisit(data, subscribe),
    options
  )(id)
