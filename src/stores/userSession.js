import { defineStore } from 'pinia'
import { supabase } from '@/client'

class Profile {
  constructor(supabaseProfile, supabaseUser) {
    this.id = supabaseProfile.id
    this.scoutName = supabaseProfile.scout_name
    this.phone = supabaseUser.phone
    this.groupId = supabaseProfile.group_id
    this.preferredCallMethod = supabaseProfile.preferred_call_method
    this.role = supabaseProfile.role
  }
}

export const useUserSession = defineStore('userSession', {
  state: () => ({ session: undefined, userProfile: undefined }),
  getters: {
    loading: (state) =>
      state.session === undefined ||
      (state.session !== null && !state.userProfile),
    isLoggedIn: (state) => !!state.session?.user.id,
    isRegistered(state) {
      return (
        this.isLoggedIn &&
        state.session.user.phone &&
        state.userProfile?.group_id
      )
    },
    user: (state) =>
      state.session && state.userProfile
        ? new Profile(state.userProfile, state.session.user)
        : null,
    userId: (state) => state.session?.user.id,
  },
  actions: {
    async fetchProfile() {
      if (!this.session?.user.id) return

      const { data } = await supabase
        .from('profiles')
        .select()
        .eq('id', this.session.user.id)
        .single()
      this.userProfile = data
    },
    async subscribeAuth() {
      supabase.auth.onAuthStateChange((_, session) => {
        this.session = session
        this.fetchProfile()
      })
    },
    async fetchAuth() {
      const { data } = await supabase.auth.getSession()
      this.session = data.session
      await this.fetchProfile()
    },
  },
})
