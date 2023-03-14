<script setup lang="ts">
import { ref } from 'vue'

import Header from './components/Header.vue'
import InputErrors from './components/InputErrors.vue'
import Footer from './components/Footer.vue'

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

type FormStep = 'company' | 'customer' | 'installation' | 'panels' | 'confirmed'

interface Flash {
  status: 'success' | 'error' | 'default',
  message: string
}

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

const currentStep = ref<FormStep>('company')

const flash = ref<Flash>({
  status: 'default',
  message: ''
})

// Functions that mutate state and trigger updates
const addPanel = () => {
  const newPanel = {
    code: null,
    flavor: panelFlavors[0],
    errors: {}
  } as Panel
  panels.value.push(newPanel)
}

const removePanel = (index: number) => (panels.value.splice(index, 1))

const postToBackend = async (endpoint: string, payload: object) => {
  return await fetch(`${backendPath}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then((response) => response.json())
    .then((data) => {
      flash.value.message = ''
      return data
    })
    .catch(() => {
      flash.value.status = 'error'
      flash.value.message = 'Sorry but something went wrong. Please try again.'
    })
}

const findOrCreateCompany = async () => {
  const { name, siren } = company.value
  const payload = { name, siren }

  const response = await postToBackend('companies/find_or_create', payload)

  if (response?.status === 200) {
    company.value.id = response.id
    currentStep.value = 'customer'
  } else if (response?.errors) {
    company.value.errors = response.errors
  }
}

const findOrCreateCustomer = async () => {
  const { name, email, phone } = customer.value
  const payload = { name, email, phone }

  const response = await postToBackend('customers/find_or_create', payload)
  if (response?.status === 200) {
    customer.value.id = response.id
    currentStep.value = 'installation'
  } else if (response?.errors) {
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
  if (response?.status === 200) {
    installation.value.id = response.id
    currentStep.value = 'panels'
  } else if (response?.errors) {
    installation.value.errors = response.errors
  }
}

const createPanels = async () => {
  if (panels.value.some(({ code }) => !code)) {
    panelsGlobalError.value = 'Please add Code to all panels before confirming your Installation.'
    return
  }

  if (panels.value.length === 0) {
    panelsGlobalError.value = 'Please add at least one Panel to your Installation.'
    return
  }

  panelsGlobalError.value = ''

  const payload = { panels: panels.value, installation_id: installation.value.id }
  const response = await postToBackend('panels/bulk_create', payload)
  if (response?.status === 200) {
    panels.value.forEach((panel) => panel.errors = {})
    currentStep.value = 'confirmed'
    flash.value.status = 'success'
    flash.value.message = 'Your installation informations has been sent to DualSun. Thank you!'
  } else if (response?.errors) {
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
      <div class="form-summary">
        <div v-if="['customer', 'installation', 'panels', 'confirmed'].includes(currentStep)" data-cy="company-summary">
          <h2>Company Infos</h2>
          <p>Name: {{ company.name }}</p>
          <p>Siren: {{ company.siren }}</p>
        </div>

        <div v-if="['installation', 'panels', 'confirmed'].includes(currentStep)" data-cy="customer-summary">
          <h2>Customer Infos</h2>
          <p>Name: {{ customer.name }}</p>
          <p>Email: {{ customer.email }}</p>
          <p>Phone: {{ customer.phone }}</p>
        </div>

        <div v-if="['panels', 'confirmed'].includes(currentStep)" data-cy="installation-summary">
          <h2>Installation Details</h2>
          <p>Date: {{ installation.date }}</p>
          <p>Address: {{ installation.address }}</p>
          <p>City: {{ installation.city }}</p>
        </div>

        <div v-if="currentStep === 'confirmed'" data-cy="panels-summary">
          <h2>Panels</h2>
          <div v-for="(panel, index) in panels" :key="index">
            <p>{{ panel.code }} - {{ panel.flavor }}</p>
          </div>
        </div>
      </div>

      <div v-if="currentStep === 'company'" data-cy="company-form">
        <h2>Company Infos</h2>
        <div class="form-group">
          <input v-model.trim="company.name" placeholder="Name" data-cy="company-name" />
        </div>
        <div class="form-group">
          <input v-model.trim="company.siren" placeholder="Siren" data-cy="company-siren" />
        </div>
        <InputErrors :errors="company.errors" />

        <button
          type="submit"
          class="button primary"
          @click="findOrCreateCompany"
          data-cy="submit-company"
        >Continue</button>
      </div>

      <div v-if="currentStep === 'customer'" data-cy="customer-form">
        <h2>Customer Infos</h2>
        <div class="form-group">
          <input v-model.trim="customer.name" placeholder="Name" data-cy="customer-name" />
        </div>
        <div class="form-group">
          <input v-model.trim="customer.email" placeholder="Email" data-cy="customer-email" />
        </div>
        <div class="form-group">
          <input v-model.trim="customer.phone" placeholder="Phone" data-cy="customer-phone" />
        </div>
        <InputErrors :errors="customer.errors" />

        <button
          type="submit"
          class="button primary"
          @click="findOrCreateCustomer"
          data-cy="submit-customer"
        >Continue</button>
      </div>

      <div v-if="currentStep === 'installation'" data-cy="installation-form">
        <h2>Installation Details</h2>
        <div class="form-group">
          <input v-model.trim="installation.date" placeholder="Date" type="date" data-cy="installation-date" />
        </div>
        <div class="form-group">
          <input v-model.trim="installation.address" placeholder="Address" data-cy="installation-address" />
        </div>
        <div class="form-group">
          <input v-model.trim="installation.city" placeholder="City" data-cy="installation-city" />
        </div>
        <InputErrors :errors="installation.errors" />
        <button
          type="submit"
          class="button primary"
          @click="createInstallation"
          data-cy="submit-installation"
        >Continue</button>
      </div>

      <div v-if="currentStep === 'panels'" data-cy="panels-form">
        <h2>Panels</h2>
        <div v-for="(panel, index) in panels" :key="index">
          <div class="form-group" data-cy="panel-form">
            <input v-model.trim="panel.code" placeholder="Code" data-cy="panel-code" />
            <select v-model.trim="panel.flavor" data-cy="panel-flavor">
              <option v-for="panelFlavor in panelFlavors" :value="panelFlavor" :key="panelFlavor">
                {{ panelFlavor }}
              </option>
            </select>
            <button class="remove" @click="removePanel(index)" data-cy="remove-panel">
              <Cross />
            </button>
          </div>
          <InputErrors :errors="panel.errors" />
        </div>
        <button type="button" class="button secondary" @click="addPanel" data-cy="add-panel">
          Add Another Panel
        </button>

        <p class="panels-global-error" data-cy="panels-global-error">
          {{ panelsGlobalError }}
        </p>

        <br /><br />
        <button
          type="submit"
          class="button primary"
          @click="createPanels"
          data-cy="submit-panels"
        >Confirm Installation</button>
      </div>
    </div>
  </div>

  <div class="flash" v-if="flash.message.length > 0" :class="flash.status" data-cy="flash">
    {{ flash.message }}
  </div>
  <Footer />
</template>

<style lang="scss" scoped>
#main {
  display: flex;
  justify-content: center;
  flex-grow: 1;
  margin-bottom: 30px;

  #installation-form {
    width: 300px;
    padding: 20px 30px;

    h2 {
      color: var(--color-gray);
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
      color: var(--color-gray);
      margin-bottom: 30px;
    }

    .panels-global-error {
      color: var(--color-error);
    }
  }

  #confirmation-message {
    p {
      &:first-child {
        color: var(--color-primary);
      }

      &:last-child {
        color: var(--color-secondary);
      }
    }
  }
}
.flash {
  text-align: center;
  padding: 20px;
  color: white;

  &.success {
    background-color: var(--color-primary);
  }

  &.error {
    background-color: var(--color-error);
  }

  &.default {
    background-color: var(--color-gray);
  }
}
</style>
