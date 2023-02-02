import { supabase } from '@/client'
import { showAlert } from '@/utils'
import { computed } from 'vue'

export function useOperatorCall(user, operator) {
  const callOperator = async () => {
    try {
      await setActiveCall(operator.value.id, user.value.id)
    } catch (error) {
      // Expected error in case the operator is already busy.
      // In this case, we don't have the permission to write to the operator's active_caller_id column.
    }
  }

  const finishCall = async () => {
    try {
      return setActiveCall(operator.value.id, null)
    } catch (error) {
      console.log(error)
      showAlert(
        'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä. D Zentralä tuät notfalls de Aruäf selber beendä.'
      )
    }
  }

  const loggedInUserIsActiveCaller = computed(
    () => operator.value.activeCallerId === user.value.id
  )

  const callLinkHref = computed(() =>
    user.value.preferredCallMethod === 'whatsapp'
      ? `whatsapp://send/?phone=${operator.value.phone}&text&type=phone_number&app_absent=0`
      : `tel:${operator.value.phone?.replace(/^\+?41/, '+41')}`
  )

  const activeCallerId = computed(() => operator.value?.activeCallerId)

  const activeCaller = computed(() => operator.value?.activeCaller)

  return {
    callOperator,
    finishCall,
    loggedInUserIsActiveCaller,
    callLinkHref,
    activeCallerId,
    activeCaller,
  }
}

async function setActiveCall(operatorId, callerId) {
  return supabase
    .from('operator_callers')
    .update({ active_caller_id: callerId })
    .eq('id', operatorId)
    .throwOnError()
}
