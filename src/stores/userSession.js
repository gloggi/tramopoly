import { defineStore } from 'pinia'
import { supabase } from '@/client'
import { useProfile } from '@/stores/profiles'

export const useUserSession = defineStore('userSession', {
  state: () => ({ session: undefined }),
  getters: {
    profileStore: (state) => {
      if (!state.session?.user.id) return null
      const profileStore = useProfile(state.session?.user.id, {
        select: '*,active_caller:active_caller_id(*,group:group_id(*))',
      })
      profileStore.subscribe()
      return profileStore
    },
    payload: (state) => {
      if (!state.session) return null
      const base64Url = state.session.provider_token.split('.')[1]
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
      const jsonPayload = decodeURIComponent(
        window
          .atob(base64)
          .split('')
          .map(function (c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
          })
          .join('')
      )
      return JSON.parse(jsonPayload)
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
    isPlayer() {
      return this.isRegistered && this.user?.role === 'player'
    },
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
