import { defineStore } from 'pinia'

class User {
  constructor(supabaseUser) {
    this.id = supabaseUser.id
    this.scoutName = supabaseUser.user_metadata.scout_name
    this.phone = supabaseUser.phone
    this.groupId = supabaseUser.user_metadata.group_id
    this.preferredCallMethod = supabaseUser.user_metadata.preferred_call_method
  }
  get registered() {
    return this.phone && this.groupId
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
