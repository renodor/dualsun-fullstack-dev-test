<script setup lang="ts">
import { ref } from 'vue'
import Header from './components/Header.vue'
import InputErrors from './components/InputErrors.vue'
import Cross from './components/icons/Cross.vue'

const backendPath = 'http://localhost:3000/'

// Types
interface Company {
  id: number | null,
  name: string,
  siren: number | null,
  errors: {
    [key: string]: []
  }
}

interface Customer {
  id: number | null,
  name: string,
  email: string,
  phone: string,
  errors: {
    [key: string]: []
  }
}

interface Installation {
  id: number | null,
  date: string,
  address: string,
  city: string,
  errors: {
    [key: string]: []
  }
}

const panelFlavors = ['photovoltaic', 'hybrid'] as const;
type PanelFlavor = typeof panelFlavors[number];
interface Panel {
  code: number | null,
  flavor: PanelFlavor,
  errors: {
    [key: string]: []
  }
}

type FormSteps = 'company' | 'customer' | 'installation' | 'panels'

// Reactive state
const company = ref<Company>({
  id: null,
  name: '',
  siren: null,
  errors: {}
})

const customer = ref<Customer>({
  id: null,
  name: '',
  email: '',
  phone: '',
  errors: {}
})

const installation = ref<Installation>({
  id: null,
  date: '',
  address: '',
  city: '',
  errors: {}
})

const panels = ref<Panel[]>([
  {
    code: null,
    flavor: panelFlavors[0],
    errors: {}
  }
])
const panelsGlobalError = ref('')

const currentStep = ref<FormSteps>('company')

// Functions that mutate state and trigger updates
const addPanel = () => {
  const newPanel =   {
    code: null,
    flavor: panelFlavors[0] as PanelFlavor,
    errors: {}
  }
  panels.value.push(newPanel)
}

const removePanel = (index: number) => (panels.value.splice(index, 1))

const postToBackend = async (endpoint: string, payload: object) => {
  return await fetch(`${backendPath}${endpoint}`, { // TODO: don't hardcode this url
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
  const { date, address, city } = installation.value
  const payload = {
    date,
    address,
    city,
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
    return
  }

  panelsGlobalError.value = ''

  const payload = { panels: panels.value, installation_id: installation.value.id }
  const response = await postToBackend('panels/bulk_create', payload)
  if (response.status === 200) {
    panels.value.forEach((panel) => panel.errors = {})
    console.log('SUCCESSS')
  } else {
    panels.value.forEach((panel) => {
      panel.errors = response.errors[panel.code] || {}
    })
  }
}
</script>

<template>
  <Header />
  <div id="main">
    <div id="installation-form">
      <div v-if="currentStep === 'company'">
        <h2>Company Infos</h2>
        <div class="form-group"><input v-model.trim="company.name" placeholder="Name" /></div>
        <div class="form-group"><input v-model.trim="company.siren" placeholder="Siren" /></div>
        <InputErrors :errors="company.errors" />

        <button type="submit" class="button primary" @click="findOrCreateCompany">Continue</button>
      </div>

      <div v-if="currentStep === 'customer'">
        <div class="form-summary">
          <h2>Company Infos</h2>
          <p>Name: {{ company.name }}</p>
          <p>Siren: {{ company.siren }}</p>
        </div>

        <h2>Customer Infos</h2>
        <div class="form-group"><input v-model.trim="customer.name" placeholder="Name" /></div>
        <div class="form-group"><input v-model.trim="customer.email" placeholder="Email" /></div>
        <div class="form-group"><input v-model.trim="customer.phone" placeholder="Phone" /></div>
        <InputErrors :errors="customer.errors" />

        <button type="submit" class="button primary" @click="findOrCreateCustomer">Continue</button>
      </div>

      <div v-if="currentStep === 'installation'">
        <div class="form-summary">
          <h2>Company Infos</h2>
          <p>Name: {{ company.name }}</p>
          <p>Siren: {{ company.siren }}</p>

          <h2>Customer Infos</h2>
          <p>Name: {{ customer.name }}</p>
          <p>Email: {{ customer.email }}</p>
          <p>Phone: {{ customer.phone }}</p>
        </div>

        <h2>Installation Details</h2>
        <div class="form-group"><input v-model.trim="installation.date" placeholder="Date" type="date" /></div>
        <div class="form-group"><input v-model.trim="installation.address" placeholder="Address" /></div>
        <div class="form-group"><input v-model.trim="installation.city" placeholder="City" /></div>
        <InputErrors :errors="installation.errors" />
        <button type="submit" class="button primary" @click="createInstallation">Continue</button>
      </div>

      <div v-if="currentStep === 'panels'">
        <div class="form-summary">
          <h2>Company Infos</h2>
          <p>Name: {{ company.name }}</p>
          <p>Siren: {{ company.siren }}</p>

          <h2>Customer Infos</h2>
          <p>Name: {{ customer.name }}</p>
          <p>Email: {{ customer.email }}</p>
          <p>Phone: {{ customer.phone }}</p>

          <h2>Installation Details</h2>
          <p>Date: {{ installation.date }}</p>
          <p>Address: {{ installation.address }}</p>
          <p>City: {{ installation.city }}</p>
        </div>

        <h2>Panels</h2>
        <div v-for="(panel, index) in panels" :key="index">
          <div class="form-group">
            <input v-model.trim="panel.code" placeholder="Id" />
            <select v-model.trim="panel.flavor">
              <option v-for="panelFlavor in panelFlavors" :value="panelFlavor" :key="panelFlavor">
                {{ panelFlavor }}
              </option>
            </select>
            <button class="remove" @click="removePanel(index)">
              <Cross />
            </button>
          </div>
          <InputErrors :errors="panel.errors" />
        </div>
        <button type="button" class="button secondary" @click="addPanel">Add Another Panel</button>

        <p class="panel-global-error">{{ panelsGlobalError }}</p>

        <br /><br />
        <button type="submit" class="button primary" @click="createPanels">Confirm Installation</button>
      </div>
    </div>
  </div>
  <Footer />
</template>

<style lang="scss" scoped>
#main {
  display: flex;
  justify-content: center;

  #installation-form {
    width: 300px;
    padding: 20px 30px;

    h2 {
      color: #4E5354;
    }

    .form-group {
      margin-bottom: 15px;
      display: flex;
      column-gap: 10px;

      input {
        padding: 5px;
        border-bottom: 1px solid var(--color-primary);
        border-left: none;
        border-right: none;
        border-top: none;
        outline: none;
        width: 100%;
        font-size: 16px;
      }

      select {
        border: 1px solid var(--color-primary);
        background-color: white;
        outline: none;
        color: var(--color-primary);
        text-transform: capitalize;
      }

      .remove {
        background-color: transparent;
        border: none;
        font-size: 20px;
        color: var(--color-primary);
        cursor: pointer;
      }
    }

    .button {
      padding: 10px 20px;
      cursor: pointer;
      border-radius: 30px;
      transition: background-color .3s ease, color .3s ease;

      &.primary {
        width: 100%;
        border: 2px solid var(--color-primary);
        background-color: var(--color-primary);
        color: white;
        font-weight: 600;

        &:hover {
          background-color: white;
          color: var(--color-primary);
        }
      }

      &.secondary {
        background-color: white;
        color: var(--color-primary);
        border: 1px solid var(--color-primary);
      }
    }

    .form-summary {
      color: #4E5354;
      margin-bottom: 30px;
    }

    .panel-global-error {
      color: var(--color-error);
    }
  }
}
</style>
