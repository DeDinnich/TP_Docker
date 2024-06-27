<template>
  <div class="form-container">
    <form @submit.prevent="submitMessage" class="message-form">
      <input type="text" v-model="name" placeholder="Votre nom" required>
      <textarea v-model="message" placeholder="Votre message" required></textarea>
      <button type="submit">Envoyer</button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'MessageForm',
  data() {
    return {
      name: '',
      message: ''
    };
  },
  methods: {
    submitMessage() {
      this.$http.post('/api/messages', { name: this.name, message: this.message })
        .then(() => {
          this.name = '';
          this.message = '';
          this.$emit('message-posted');
        })
        .catch(error => {
          console.error("There was an error posting the message:", error);
        });
    }
  }
}
</script>

<style>
.form-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.message-form {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 500px;
  box-shadow: rgba(0, 0, 0, 0.19) 0px 10px 20px, rgba(0, 0, 0, 0.23) 0px 6px 6px;
  padding: 20px;
  border-radius: 8px;
}

.message-form input,
.message-form textarea {
  margin-bottom: 15px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.message-form textarea {
  resize: vertical;
}

.message-form button {
  cursor: pointer;
  background-color: #007BFF;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

.message-form button:hover {
  background-color: #0056b3;
}
</style>
