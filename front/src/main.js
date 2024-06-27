import { createApp } from 'vue';
import App from './App.vue';
import axios from 'axios';

const app = createApp(App);

// Configurer Axios avec une URL de base
axios.defaults.baseURL = 'http://localhost:5000'; // Adaptez cette URL à l'URL de votre backend Flask

// Configurer Axios comme propriété globale
app.config.globalProperties.$http = axios;

// Monter l'application Vue
app.mount('#app');
