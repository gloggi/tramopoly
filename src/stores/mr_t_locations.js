import { useCollectionStore } from '@/stores/collectionStore'

export const useMrTLocations = (options = { select: 'name' }) =>
  useCollectionStore('mr_t_locations', (data) => data.name, options)()
