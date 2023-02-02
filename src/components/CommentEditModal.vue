<template>
  <o-button
    variant="primary"
    outlined
    icon-left="comment"
    @click="modalOpen = true"
  >
    <slot></slot>
  </o-button>
  <o-modal v-model:active="modalOpen">
    <div class="card modal-card">
      <div class="card-content">
        <form @submit.prevent="submit">
          <o-field label="Kommentar">
            <o-input type="textarea" v-model="localValue" expanded></o-input>
          </o-field>
          <o-button variant="primary" native-type="submit" outlined>
            Ademässi
          </o-button>
        </form>
      </div>
    </div>
  </o-modal>
</template>

<script>
import { supabase } from '@/client'

export default {
  name: 'CommentEditModal',
  props: {
    table: { type: String, required: true },
    id: { type: String, required: true },
    groupId: { type: Number, required: true },
    value: { type: String, required: false },
  },
  data() {
    return {
      modalOpen: false,
      localValue: this.value,
    }
  },
  watch: {
    value(newValue, oldValue) {
      if (this.localValue === oldValue) {
        this.localValue = newValue
      }
    },
  },
  methods: {
    async submit() {
      await supabase
        .from(this.table)
        .update({ operator_comment: this.localValue })
        .eq('id', this.id)
      await supabase.rpc('increment_unseen_counter', {
        chat_id: this.groupId,
        increment: 1,
      })
      this.modalOpen = false
    },
  },
}
</script>
