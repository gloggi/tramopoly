import { supabase } from '@/client'
import { useProgrammatic } from '@oruga-ui/oruga-next'

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
      message: `Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.`,
    })
  }
}

async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) {
    const { oruga } = useProgrammatic()
    oruga.notification.open({
      message: `Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä oder s Tramopoly imnä anonymä Browsertab ufzmachä.`,
    })
  }
  supabase.getChannels().forEach((channel) => channel.unsubscribe())
}

export { signInWithOAuth, signOut }
