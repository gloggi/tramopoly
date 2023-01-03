<template>
  <header>
    <div v-if="!signedInUser">Hello world!</div>
    <div v-else>Hello {{ signedInUser.user_metadata.full_name }}</div>
    <input name="title" v-model="title" />
    <input name="content" v-model="content" />
    <button @click="createPost">Save</button>

    <div>
      <button v-if="!signedInUser" @click="signInWithKeycloak">Sign in</button>
      <button v-else @click="signOut">Sign out</button>
    </div>

    <div v-for="(post, index) in posts" :key="index">
      <h3>{{ post.title }}</h3>
      <article>{{ post.content }}</article>
    </div>
  </header>

  <RouterView />
</template>

<script>
import { RouterView } from 'vue-router'
import { supabase } from '@/client'

export default {
  name: 'App',
  components: { RouterView },
  data: () => ({
    posts: [],
    title: '',
    content: '',
    signedInUser: null,
  }),
  mounted() {
    this.fetchPosts()
    supabase.auth.getUser().then(({ data: { user } }) => {
      this.signedInUser = user
      console.log(user)
    })
  },
  methods: {
    async fetchPosts() {
      const { data } = await supabase.from('posts').select()
      this.posts = data
    },
    async createPost() {
      await supabase
        .from('posts')
        .insert([
          {
            title: this.title,
            content: this.content,
          },
        ])
        .single()
      this.title = ''
      this.content = ''
      this.fetchPosts()
    },
    async signInWithKeycloak() {
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'keycloak',
        options: {
          scopes: 'openid',
        },
      })
      console.log(data, error)
    },
    async signOut() {
      const { error } = await supabase.auth.signOut()
      console.log(error)
      this.signedInUser = null
    },
  },
}
</script>

<style scoped></style>
