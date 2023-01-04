<template>
  <main>
    <input name="title" v-model="title" />
    <input name="content" v-model="content" />
    <button @click="createPost">Save</button>

    <div v-for="(post, index) in posts" :key="index">
      <h3 class="title is-3">{{ post.title }}</h3>
      <article>{{ post.content }}</article>
    </div>
  </main>
</template>

<script>
import { supabase } from '@/client'

export default {
  name: 'HomeView',
  data: () => ({
    posts: [],
    title: '',
    content: '',
  }),
  mounted() {
    this.fetchPosts()
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
  },
}
</script>
