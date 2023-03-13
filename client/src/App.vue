<script setup lang="ts">
import { ref } from 'vue'

// Types
const panelFlavors = ['photovoltaic', 'hybrid'] as const;
type panelFlavor = typeof panelFlavors[number];
type panel = { code: number | undefined, flavor: panelFlavor, errors: object }

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

const findOrCreateCompany = () => {
  const { name, siren } = company.value
  const payload = { name, siren }
  fetch('http://localhost:3000/companies/find_or_create', { // TODO: don't hardcode this url
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then((response) => response.json())
    .then((data) => {
      if (data.status === 200) {
        company.value.id = data.id
        currentStep.value = 'customer'
      } else {
        company.value.errors = data.errors
      }
    })
    .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
}

const findOrCreateCustomer = () => {
  const { name, email, phone } = customer.value
  const payload = { name, email, phone }

  fetch('http://localhost:3000/customers/find_or_create', { // TODO: don't hardcode this url
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then((response) => response.json())
    .then((data) => {
      if (data.status === 200) {
        customer.value.id = data.id
        currentStep.value = 'installation'
      } else {
        customer.value.errors = data.errors
      }
    })
    .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
}

const createInstallation = () => {
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

  fetch('http://localhost:3000/installations', { // TODO: don't hardcode this url
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then((response) => response.json())
    .then((data) => {
      if (data.status === 200) {
        installation.value.id = data.id
        currentStep.value = 'panels'
      } else {
        installation.value.errors = data.errors
      }
    })
    .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
}

const submitForm = () => {
  if (panels.value.some((panel) => !panel.code)) {
    panelsGlobalError.value = 'Please add ID to all panels before confirming your Installation.'
  } else {
    panelsGlobalError.value = ''
    fetch('http://localhost:3000/panels/bulk_create', { // TODO: don't hardcode this url
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ panels: panels.value, installation_id: installation.value.id })
    }).then((response) => response.json())
      .then((data) => {
        if (data.status === 200) {
          console.log('SUCCESSS')
        } else {
          panels.value.forEach((panel) => {
            panel.errors = data.errors[panel.code]
          })
        }
      })
      .catch(() => console.log('Something went wrong')) // TODO: trigger flash. Why do we get here for 4xx response?
  }
}
</script>

<template>

  <div v-if="currentStep === 'company'">
    <h2>Company Infos</h2>
    <input v-model.trim="company.name" placeholder="Name" />
    <input v-model.trim="company.siren" placeholder="Siren" />
    <div>
      <ul>
        <li v-for="(value, key) in company.errors" :key="key">
          {{ key }}: {{ value.join(', ') }}
        </li>
      </ul>
    </div>

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
    <div>
      <ul>
        <li v-for="(value, key) in customer.errors" :key="key">
          {{ key }}: {{ value.join(', ') }}
        </li>
      </ul>
    </div>

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
    <ul> <!-- TODO: not very DRY... -->
      <li v-for="(value, key) in installation.errors" :key="key">
        {{ key }}: {{ value.join(', ') }}
      </li>
    </ul>
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
      <ul> <!-- TODO: not very DRY... -->
        <li v-for="(value, key) in panel.errors" :key="key">
          {{ key }}: {{ value.join(', ') }}
        </li>
      </ul>
    </div>
    <button @click="addPanel">Add Another Panel</button>

    <p>{{ panelsGlobalError }}</p>

    <br /><br />
    <button type="submit" @click="submitForm">Confirm Installation</button>
  </div>
</template>

<style scoped>
</style>
