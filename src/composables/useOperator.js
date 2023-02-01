import { computed } from 'vue'
import { useGroup } from '@/stores/groups'
import { storeToRefs } from 'pinia'

export function useOperator(groupId) {
  const groupStore = useGroup(groupId)
  groupStore.subscribe()
  const { entry: group, loading } = storeToRefs(groupStore)

  const operator = computed(() => group.value?.abteilung.operator)

  const operatorName = computed(() =>
    loading.value ? '' : operator.value.scoutName
  )
  const operatorBusy = computed(() =>
    loading.value ? false : operator.value.activeCallerId != null
  )

  const operatorPhoneInWords = computed(() => {
    if (loading.value || !operator.value.phone) return ''
    const phoneFormat = operator.value.phone.replace(/^\+41/g, '0').split('')
    if (phoneFormat.length === 10) {
      phoneFormat.splice(3, 0, ',')
      phoneFormat.splice(7, 0, ',')
      phoneFormat.splice(10, 0, ',')
    }
    return phoneFormat
      .join('')
      .replace(/0/g, ' Null')
      .replace(/1/g, ' Äis')
      .replace(/2/g, ' Zwäi')
      .replace(/3/g, ' Drüü')
      .replace(/4/g, ' Viär')
      .replace(/5/g, ' Foif')
      .replace(/6/g, ' Sächs')
      .replace(/7/g, ' Sibä')
      .replace(/8/g, ' Acht')
      .replace(/9/g, ' Nüün')
      .trim()
  })

  return {
    operator,
    operatorName,
    operatorBusy,
    operatorPhoneInWords,
  }
}
