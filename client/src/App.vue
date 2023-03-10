<script setup lang="ts">
import { ref } from 'vue'

// Types
const panelTypes = ['photovoltaic', 'hybrid'] as const;
type panelType = typeof panelTypes[number];
type panel = { code: number | undefined, type: panelType }

// Reactive state
const company = ref({
  name: '',
  siren: ''
})

const customer = ref({
  name: '',
  email: '',
  phone: ''
})

const installation = ref({
  address: '',
  date: '',
})

const panels = ref<panel[]>([
  {
    code: undefined,
    type: panelTypes[0]
  }
])

// Functions that mutate state and trigger updates
const addPanel = () => {
  const newPanel =   {
    code: undefined,
    type: panelTypes[0] as panelType
  }
  panels.value.push(newPanel)
}

const removePanel = (index: number) => {
  panels.value.splice(index, 1)
}
</script>

<template>
  <div>
    <h2>Company Infos</h2>
    <input v-model="company.name" placeholder="Name" />
    <input v-model="company.siren" placeholder="Siren" />
  </div>

  <div>
    <h2>Customer Infos</h2>
    <input v-model="customer.name" placeholder="Name" />
    <input v-model="customer.email" placeholder="Email" />
    <input v-model="customer.phone" placeholder="Phone" />
  </div>

  <div>
    <h2>Installation Details</h2>
    <input v-model="installation.address" placeholder="Address" />
    <input v-model="installation.date" placeholder="Date" />
  </div>

  <div>
    <h2>Panels</h2>
    <div v-for="(panel, index) in panels" :key="index">
      <input v-model="panel.code" placeholder="Id"/>
      <select v-model="panel.type">
        <option v-for="panelType in panelTypes" :value="panelType" :key="panelType">
          {{ panelType }}
        </option>
      </select>
      <button @click="removePanel(index)">x</button>
    </div>
    <button @click="addPanel">Add Panel</button>
  </div>
</template>

<style scoped>
</style>
