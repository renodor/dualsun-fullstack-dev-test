<script setup lang="ts">
defineProps<{
  errors: {
    [key: string]: []
  }
}>()
</script>

<template>
  <div class="input-errors">
    <p v-for="(value, key) in errors" :key="key">
      <span>{{ key }}:</span> {{ value.join(', ') }}
    </p>
  </div>
</template>

<style lang="scss" scoped>
.input-errors {
  color: var(--color-error);
  span {
    text-transform: capitalize;
  }
}
</style>
