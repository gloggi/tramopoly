<template>
  <o-button
    variant="primary"
    outlined
    icon-left="comments-dollar"
    @click="modalOpen = true"
  >
    <slot></slot>
  </o-button>
  <o-modal v-model:active="modalOpen">
    <div class="card modal-card">
      <div class="card-content">
        <form @submit.prevent="submit">
          <o-field :label="`Bonuspünkt (läär oder zwüschät 0 und ${max})`">
            <o-input type="number" v-model="localValue" expanded></o-input>
          </o-field>
          <o-button variant="primary" native-type="submit" outlined>
            Gönnäd oi
          </o-button>
        </form>
      </div>
    </div>
  </o-modal>
</template>

<script>
import { supabase } from '@/client'

export default {
  name: 'BonusPointsModal',
  props: {
    max: { type: Number, required: true },
    id: { type: String, required: true },
    value: { type: Number, required: false },
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
      await supabase.rpc('grant_joker_bonus', {
        joker_visit_id: this.id,
        earned_bonus_value: this.localValue === '' ? null : this.localValue,
      })
      this.modalOpen = false
    },
  },
}
</script>
