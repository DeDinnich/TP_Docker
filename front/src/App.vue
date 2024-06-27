<template>
  <div id="app">
    <h1>Livre d'or</h1>
    <MessageForm @message-posted="fetchMessages" />
    <MessageList :messages="messages" />
  </div>
</template>

<script>
import MessageForm from './components/MessageForm.vue'
import MessageList from './components/MessageList.vue'

export default {
  name: 'App',
  components: {
    MessageForm,
    MessageList
  },
  data() {
    return {
      messages: []
    };
  },
  methods: {
    fetchMessages() {
      this.$http.get('/api/messages')
        .then(response => {
          this.messages = response.data;
        })
        .catch(error => {
          console.error("There was an error fetching the messages:", error);
        });
    }
  },
  created() {
    this.fetchMessages();
  }
}
</script>

<style>
#app {
  text-align: center;
  margin-top: 50px;
}

body {
background-image: url('~@/assets/background.svg');
  background-size: cover; 
  background-repeat: no-repeat; 
  background-position: center; 
  min-height: 100vh; 
  width: 100vw; 
}

</style>
