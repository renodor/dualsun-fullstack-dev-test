<script setup lang="ts">
import { ref } from 'vue'

import InputErrors from './components/InputErrors.vue'
// Types
const panelFlavors = ['photovoltaic', 'hybrid'] as const;
type panelFlavor = typeof panelFlavors[number];
type panel = { code: number | undefined, flavor: panelFlavor, errors: {} }

// Reactive state
const company = ref({
  id: undefined,
  name: '',
  siren: '',
  errors: {}
})

const customer = ref({
  id: undefined,
  name: '',
  email: '',
  phone: '',
  errors: {}
})

const installation = ref({
  id: undefined,
  date: '',
  address1: '',
  address2: '',
  city: '',
  zipcode: '',
  country: '',
  errors: {}
})

const panels = ref<panel[]>([
  {
    code: undefined,
    flavor: panelFlavors[0],
    errors: {}
  }
])
const panelsGlobalError = ref('')

const currentStep = ref('company')

// Functions that mutate state and trigger updates
const addPanel = () => {
  const newPanel =   {
    code: undefined,
    flavor: panelFlavors[0] as panelFlavor,
    errors: {}
  }
  panels.value.push(newPanel)
}

const removePanel = (index: number) => {
  panels.value.splice(index, 1)
}

const postToBackend = async (endpoint, payload) => {
  return await fetch(`http://localhost:3000/${endpoint}`, { // TODO: don't hardcode this url
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then((response) => response.json())
    .then((data) => data)
    .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
}

const findOrCreateCompany = async () => {
  const { name, siren } = company.value
  const payload = { name, siren }

  const response = await postToBackend('companies/find_or_create', payload)
  if (response.status === 200) {
    company.value.id = response.id
    currentStep.value = 'customer'
  } else {
    company.value.errors = response.errors
  }
}

const findOrCreateCustomer = async () => {
  const { name, email, phone } = customer.value
  const payload = { name, email, phone }

  const response = await postToBackend('customers/find_or_create', payload)
  if (response.status === 200) {
    customer.value.id = response.id
    currentStep.value = 'installation'
  } else {
    customer.value.errors = response.errors
  }
}

const createInstallation = async () => {
  const { date, address1, city, zipcode, country } = installation.value
  const payload = {
    date,
    address1,
    city,
    zipcode,
    country,
    company_id: company.value.id,
    customer_id: customer.value.id
  }

  const response = await postToBackend('installations', payload)
  if (response.status === 200) {
    installation.value.id = response.id
    currentStep.value = 'panels'
  } else {
    installation.value.errors = response.errors
  }
}

const createPanels = async () => {
  if (panels.value.some((panel) => !panel.code)) {
    panelsGlobalError.value = 'Please add ID to all panels before confirming your Installation.'
  } else {
    panelsGlobalError.value = ''

    const payload = { panels: panels.value, installation_id: installation.value.id }
    const response = await postToBackend('panels/bulk_create', payload)
    if (response.status === 200) {
      panels.value.forEach((panel) => {
        panel.errors = {}
      })
      console.log('SUCCESSS')
    } else {
      panels.value.forEach((panel) => {
        panel.errors = response.errors[panel.code] || {}
      })
    }
  }
}
</script>

<template>
  <div v-if="currentStep === 'company'">
    <h2>Company Infos</h2>
    <input v-model.trim="company.name" placeholder="Name" />
    <input v-model.trim="company.siren" placeholder="Siren" />
    <InputErrors :errors="company.errors" />

    <button typ="submit" @click="findOrCreateCompany">Continue</button>
  </div>

  <div v-if="currentStep === 'customer'">
    <h2>Company Infos</h2>
    <p>Name: {{ company.name }}</p>
    <p>Siren: {{ company.siren }}</p>

    <h2>Customer Infos</h2>
    <input v-model.trim="customer.name" placeholder="Name" />
    <input v-model.trim="customer.email" placeholder="Email" />
    <input v-model.trim="customer.phone" placeholder="Phone" />
    <InputErrors :errors="customer.errors" />

    <button typ="submit" @click="findOrCreateCustomer">Continue</button>
  </div>

  <div v-if="currentStep === 'installation'">
    <h2>Company Infos</h2>
    <p>Name: {{ company.name }}</p>
    <p>Siren: {{ company.siren }}</p>

    <h2>Customer Infos</h2>
    <p>Name: {{ customer.name }}</p>
    <p>Email: {{ customer.email }}</p>
    <p>Phone: {{ customer.phone }}</p>

    <h2>Installation Details</h2>
    <input v-model.trim="installation.date" placeholder="Date" type="date" /> <!-- TODO: set as HTML5 date input-->
    <input v-model.trim="installation.address1" placeholder="Address" />
    <input v-model.trim="installation.zipcode" placeholder="Zip Code" />
    <input v-model.trim="installation.city" placeholder="City" />
    <input v-model.trim="installation.country" placeholder="Country" />
    <InputErrors :errors="installation.errors" />
    <button typ="submit" @click="createInstallation">Ok!</button>
  </div>

  <div v-if="currentStep === 'panels'">
    <h2>Company Infos</h2>
    <p>Name: {{ company.name }}</p>
    <p>Siren: {{ company.siren }}</p>

    <h2>Customer Infos</h2>
    <p>Name: {{ customer.name }}</p>
    <p>Email: {{ customer.email }}</p>
    <p>Phone: {{ customer.phone }}</p>

    <h2>Installation Details</h2>
    <p>Date: {{ installation.date }}</p>
    <p>Address: {{ installation.address1 }}</p>
    <p>Zip Code: {{ installation.zipcode }}</p>
    <p>City: {{ installation.city }}</p>
    <p>Country: {{ installation.country }}</p>

    <h2>Panels</h2>
    <div v-for="(panel, index) in panels" :key="index">
      <input v-model.trim="panel.code" placeholder="Id" />
      <select v-model.trim="panel.flavor">
        <option v-for="panelFlavor in panelFlavors" :value="panelFlavor" :key="panelFlavor">
          {{ panelFlavor }}
        </option>
      </select>
      <button @click="removePanel(index)">x</button>
      <InputErrors :errors="panel.errors" />
    </div>
    <button @click="addPanel">Add Another Panel</button>

    <p>{{ panelsGlobalError }}</p>

    <br /><br />
    <button type="submit" @click="createPanels">Confirm Installation</button>
  </div>
</template>

<style scoped>
</style>
