import { useProgrammatic } from '@oruga-ui/oruga-next'

function showAlert(message) {
  const { oruga } = useProgrammatic()
  oruga.notification.open({
    message,
    position: 'top',
    indefinite: true,
    closable: true,
  })
}

export { showAlert }
