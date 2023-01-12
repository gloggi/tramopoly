import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useProfile } from '@/stores/profiles'

export const useUserSession = defineStore('userSession', {
  state: () => ({ session: undefined }),
  getters: {
    profileStore: (state) => {
      if (!state.session?.user.id) return null
      const profileStore = useProfile(state.session?.user.id)
      profileStore.subscribe()
      return profileStore
    },
    loading() {
      return this.session === undefined || this.profileStore?.loading
    },
    isLoggedIn: (state) => !!state.session?.user.id,
    isRegistered: (state) =>
      !!(state.session?.user.phone && state.user?.groupId),
    user() {
      return this.profileStore.entry
    },
    userId: (state) => state.session?.user.id,
    isOperator() {
      return this.isRegistered && this.user?.role === 'operator'
    },
    isAdmin() {
      return this.isRegistered && this.user?.role === 'admin'
    },
  },
  actions: {
    async subscribeAuth() {
      supabase.auth.onAuthStateChange((_, session) => {
        this.session = session
        this.profileStore?.fetch(true)
      })
    },
    async fetchAuth() {
      const { data } = await supabase.auth.getSession()
      this.session = data.session
      this.profileStore?.fetch(true)
    },
  },
})
