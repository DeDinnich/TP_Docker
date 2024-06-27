<template>
  <div class="message-list">
    <div v-for="message in messages" :key="message.id" class="message-item">
      <h3>{{ message.name }}</h3>
      <p>{{ message.message }}</p>
      <span class="date">{{ formatDate(message.created_at) }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MessageList',
  props: {
    messages: Array
  },
  methods: {
    formatDate(value) {
      if (value) {
        return new Date(value).toLocaleDateString('fr-FR', {
          year: 'numeric', month: 'long', day: 'numeric',
          hour: '2-digit', minute: '2-digit'
        });
      }
      return '';
    }
  }
}
</script>

<style>
.message-list {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.message-item {
  width: 100%;
  max-width: 600px;
  background: #f9f9f9;
  padding: 15px;
  margin-bottom: 15px;
  border-radius: 8px;
  box-shadow: rgba(0, 0, 0, 0.25) 0px 0.0625em 0.0625em, rgba(0, 0, 0, 0.25) 0px 0.125em 0.5em, rgba(255, 255, 255, 0.1) 0px 0px 0px 1px inset;
}

.message-item h3 {
  color: #333;
  margin: 0 0 5px 0;
}

.message-item p {
  color: #666;
  line-height: 1.5;
}

.message-item .date {
  font-size: 0.85rem;
  color: #999;
  text-align: right;
  margin-top: 10px;
}
</style>
