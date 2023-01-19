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

function debounce(func, timeout = 300) {
  let timer
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => {
      func.apply(this, args)
    }, timeout)
  }
}

export { showAlert, debounce }
