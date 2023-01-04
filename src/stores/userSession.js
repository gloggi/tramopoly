import { defineStore } from 'pinia'

class User {
  constructor(supabaseUser) {
    console.log({
      ...supabaseUser,
      user_metadata: { ...supabaseUser.user_metadata },
    })
    this.scoutName = supabaseUser.user_metadata.scout_name
  }
}

export const useUserSessionStore = defineStore('userSession', {
  id: 'userSession',
  state: () => ({ session: undefined }),
  getters: {
    loading: (state) => state.session === undefined,
    isLoggedIn: (state) => !!state.session?.user.id,
    user: (state) =>
      state.session?.user ? new User(state.session.user) : null,
  },
})
