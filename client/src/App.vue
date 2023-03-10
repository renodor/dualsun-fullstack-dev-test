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
const company_error = ref('')

const customer = ref({
  name: '',
  email: '',
  phone: ''
})
const customer_errors = ref({}) // TODO: define type

const installation = ref({
  address1: '',
  date: '',
})
const installation_errors = ref({}) // TODO: define type

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

const submitForm = async () => {
  const payload = JSON.stringify({
    company: company.value,
    customer: customer.value,
    installation: installation.value,
    panels: panels.value
  })

  fetch('http://localhost:3000/installations', { // TODO: don't hardcode this url
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: payload
  }).then((response) => response.json())
    .then((data) => {
      if (data.status === 200) {
        console.log('success')
      } else {
        processErrors(data.errors)
      }
    })
    .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
}

const processErrors = (errors) => {
  company_error.value = errors.company
  customer_errors.value = errors.customer
  installation_errors.value = errors.installation
}
</script>

<template>
  <div>
    <h2>Company Infos</h2>
    <input v-model="company.name" placeholder="Name" />
    <input v-model="company.siren" placeholder="Siren" />
    <div>
      {{ company_error }}
    </div>
  </div>

  <div>
    <h2>Customer Infos</h2>
    <input v-model="customer.name" placeholder="Name" />
    <input v-model="customer.email" placeholder="Email" />
    <input v-model="customer.phone" placeholder="Phone" />
    <div>
      <ul>
        <li v-for="(value, key) in customer_errors" :key="key">
          {{ key }}: {{ value.join(', ') }}
        </li>
      </ul>
    </div>
  </div>

  <div>
    <h2>Installation Details</h2>
    <input v-model="installation.address1" placeholder="Address" />
    <input v-model="installation.date" placeholder="Date" /> <!-- TODO: set as HTML5 date input-->
    <ul> <!-- TODO: not very DRY... -->
      <li v-for="(value, key) in installation_errors" :key="key">
        {{ key }}: {{ value.join(', ') }}
      </li>
    </ul>
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


  <br />
  <button type="submit" @click="submitForm">OK!</button>
</template>

<style scoped>
</style>
