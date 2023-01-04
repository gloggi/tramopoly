import { supabase } from '@/client'
import { useProgrammatic } from '@oruga-ui/oruga-next'
import { useUserSessionStore } from '@/stores/userSession'

async function setUpAuth() {
  const userSession = useUserSessionStore()
  return Promise.all([
    supabase.auth.getSession().then(({ data }) => {
      userSession.session = data.session
    }),
    supabase.auth.onAuthStateChange((_, session) => {
      userSession.session = session
    }),
  ])
}

async function signInWithOAuth() {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'keycloak',
    options: {
      scopes: 'openid',
      redirectTo: location.protocol + '//' + location.host,
    },
  })
  if (error) {
    const { oruga } = useProgrammatic()
    oruga.notification.open({
      message: `Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.`,
    })
  }
}

async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) {
    const { oruga } = useProgrammatic()
    oruga.notification.open({
      message: `Öppis isch schiäf gangä. Probiär mal d Siitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.`,
    })
  }
}

export { setUpAuth, signInWithOAuth, signOut }
