import { computed } from 'vue'
import { useMrTLocations } from '@/stores/mr_t_locations'
import { storeToRefs } from 'pinia'

export default function useFilteredMrTLocations(lastKnownLocation, direction) {
  function searchArrayFor(array, searchTerm) {
    let result = array.filter((elem) =>
      elem
        .toString()
        .toLocaleLowerCase()
        .startsWith(searchTerm.toLocaleLowerCase().trim())
    )
    result = result.concat(
      array.filter(
        (elem) =>
          result.indexOf(elem) < 0 &&
          elem
            .toString()
            .toLocaleLowerCase()
            .includes(' ' + searchTerm.toLocaleLowerCase().trim())
      )
    )
    result = result.concat(
      array.filter(
        (elem) =>
          result.indexOf(elem) < 0 &&
          elem
            .toString()
            .toLocaleLowerCase()
            .includes(searchTerm.toLocaleLowerCase().trim())
      )
    )
    return result
  }

  const locationsStore = useMrTLocations()
  locationsStore.fetch()
  const { all: allLocations } = storeToRefs(locationsStore)

  const locationsFilteredByLastKnownLocation = computed(() => {
    return searchArrayFor(allLocations.value, lastKnownLocation.value)
  })
  const locationsFilteredByDirection = computed(() => {
    return searchArrayFor(allLocations.value, direction.value)
  })

  return { locationsFilteredByLastKnownLocation, locationsFilteredByDirection }
}
