<script setup lang="ts">
defineProps<{
  errors: {
    [key: string]: []
  }
}>()
</script>

<template>
  <ul>
    <li v-for="(value, key) in errors" :key="key">
      {{ key }}: {{ value.join(', ') }}
    </li>
  </ul>
</template>

<style scoped>
</style>
