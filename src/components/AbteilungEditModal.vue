<template>
  <o-button
    class="m-3"
    size="small"
    variant="primary"
    @click="modalOpen = true"
  >
    <slot></slot>
  </o-button>
  <o-modal v-model:active="modalOpen">
    <div class="card modal-card">
      <div class="card-content">
        <form @submit.prevent="submit">
          <o-field label="Namä">
            <o-input
              v-model="name"
              class="has-text-weight-semibold"
              expanded
              required
            ></o-input>
          </o-field>
          <o-field label="Telefonischt">
            <o-select v-model="operatorId" expanded>
              <option value=""></option>
              <option
                v-for="option in operators"
                :value="option.id"
                :key="option.id"
              >
                {{ option.scoutName }}
              </option>
            </o-select>
          </o-field>
          <o-field label="Logo">
            <o-upload v-model="logo" capture accept="image/*">
              <o-button tag="a" variant="secondary">
                <o-icon icon="camera"></o-icon>
                <span>Neus Logo ufäladä</span>
              </o-button>
            </o-upload>
          </o-field>
          <o-button variant="primary" native-type="submit" outlined>
            Let's go!
          </o-button>
        </form>
      </div>
    </div>
  </o-modal>
</template>

<script>
import { useProfiles } from '@/stores/profiles'
import slugify from 'slugify'
import { supabase } from '@/client'
import { showAlert } from '@/utils'

export default {
  name: 'AbteilungEditModal',
  props: {
    abteilung: { type: Object, required: false },
  },
  data() {
    return {
      modalOpen: false,
      name: this.abteilung?.name,
      operatorId: this.abteilung?.operatorId,
      logo: null,
    }
  },
  computed: {
    operators() {
      const operatorsStore = useProfiles({
        filter: { in: ['role', ['operator', 'admin']] },
      })
      operatorsStore.subscribe()
      return operatorsStore.all
    },
  },
  methods: {
    async submit() {
      const logoUrl = this.logo
        ? await this.uploadLogo()
        : this.abteilung?.logoUrl
      const payload = {
        name: this.name,
        operator_id: this.operatorId,
        logo_url: logoUrl,
      }
      let result
      if (this.abteilung) {
        result = await supabase
          .from('abteilungen')
          .update(payload)
          .eq('id', this.abteilung.id)
      } else {
        result = await supabase.from('abteilungen').insert(payload)
      }
      if (result.error) {
        console.log(result.error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und dä Stationsbsuäch nomal z erfassä.'
        )
      }
      this.station = null
      this.photo = null
      this.modalOpen = false
    },
    async uploadLogo() {
      const extension = this.logo.name.split('.').pop()
      const filename = slugify(crypto.randomUUID() + '-' + this.name).substring(
        0,
        62 - extension.length
      )
      const { data, error } = await supabase.storage
        .from('abteilungLogos')
        .upload(`${filename}.${extension}`, this.logo)
      if (error) {
        console.log(error)
        showAlert(
          'Öppis isch schiäf gangä. Probiär mal d Sitä neu z ladä und d Abteilig nomal z erfassä.'
        )
        return null
      }
      const {
        data: { publicUrl },
      } = supabase.storage.from('abteilungLogos').getPublicUrl(data.path)
      return publicUrl
    },
  },
}
</script>
