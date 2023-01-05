import { defineStore } from 'pinia'
import { supabase } from '@/client'

class Profile {
  constructor(supabaseProfile, supabaseUser) {
    this.id = supabaseProfile.id
    this.scoutName = supabaseProfile.scout_name
    this.phone = supabaseUser.phone
    this.groupId = supabaseProfile.group_id
    this.preferredCallMethod = supabaseProfile.preferred_call_method
  }
}

export const useUserSessionStore = defineStore('userSession', {
  id: 'userSession',
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
      state.userProfile
        ? new Profile(state.userProfile, state.session.user)
        : null,
  },
  actions: {
    async fetchProfile() {
      this.userProfile = null
      if (!this.session?.user.id) return

      const { data } = await supabase
        .from('profiles')
        .select()
        .eq('id', this.session.user.id)
        .single()
      this.userProfile = data
    },
  },
})
