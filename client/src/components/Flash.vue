<script setup lang="ts">
defineProps<{
  type: 'success' | 'error',
  message: string,
}>()
</script>

<template>
  <div class="flash" v-if="message.length > 0">
    {{ message }}
  </div>
</template>

<style lang="scss" scoped>
.flash {
  text-align: center;
  padding: 20px;
  background-color: var(--color-error);
  color: white;
}
</style>