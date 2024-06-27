# Utiliser l'image de base Node.js pour compiler l'application Vue.js
FROM node:16 AS build-stage

WORKDIR /app

# Copier les fichiers package.json et yarn.lock et installer les dépendances
COPY package.json yarn.lock ./
RUN yarn install

# Copier le reste du code de l'application et construire
COPY . .
RUN yarn build

# Utiliser l'image de base NGINX pour servir l'application
FROM nginx:stable

# Copier les fichiers construits depuis l'étape précédente
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copier la configuration NGINX
COPY ../nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
