#!/bin/bash

# Charger les variables depuis secrets.env
if [ -f secrets.env ]; then
  set -o allexport
  source secrets.env
  set -o allexport
else
  echo "Le fichier secrets.env est introuvable."
  exit 1
fi

# Fonction pour vérifier et supprimer les conteneurs existants
remove_existing_container() {
  container_name=$1
  if [ "$(docker ps -aq -f name=$container_name)" ]; then
    echo "Suppression du conteneur existant : $container_name"
    docker rm -f $container_name
  fi
}

# 1. Créer et lancer le conteneur MariaDB
remove_existing_container "mariadb-server"
echo "Démarrage du conteneur MariaDB..."
docker pull mariadb:11
docker run -d \
  --name mariadb-server \
  -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  -e MYSQL_USER=${MYSQL_USER} \
  -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  -v $(pwd)/init_db.sql:/docker-entrypoint-initdb.d/init_db.sql \
  -v mariadb_data:/var/lib/mysql \
  -p 3306:3306 \
  mariadb:11

# 2. Construire l'image Docker pour Flask et lancer le conteneur
cd back || exit

# Créer le Dockerfile pour Flask
cat <<EOF > Dockerfile
# Utiliser l'image de base Python
FROM python:3.9-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers requirements.txt et installer les dépendances
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copier le reste du code de l'application
COPY . .

# Exposer le port 5000 et démarrer le serveur Flask
EXPOSE 5000
CMD ["python", "app.py"]
EOF

remove_existing_container "flask-app"
echo "Construction de l'image Docker pour Flask..."
docker build -t flask-app .
docker run -d \
  --name flask-app \
  -p 5000:5000 \
  flask-app
cd ..

# 3. Construire l'image Docker pour Vue.js et lancer le conteneur
cd front || exit

# Créer le Dockerfile pour Vue.js
cat <<EOF > Dockerfile
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
COPY /home/dedinnich/TP_Docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

remove_existing_container "vuejs-app"
echo "Construction de l'image Docker pour Vue.js..."
docker build -t vuejs-app .
docker run -d \
  --name vuejs-app \
  -p 80:80 \
  vuejs-app
cd ..

# 4. Pousser les images Docker sur DockerHub
echo "Poussée des images Docker sur DockerHub..."
docker tag flask-app ${DOCKERHUB_USERNAME}/flask-app:latest
docker tag vuejs-app ${DOCKERHUB_USERNAME}/vuejs-app:latest
docker push ${DOCKERHUB_USERNAME}/flask-app:latest
docker push ${DOCKERHUB_USERNAME}/vuejs-app:latest

# 5. Mettre à jour le code source sur GitHub
echo "Mise à jour du code source sur GitHub..."
git pull
git add .
git commit -m "avancement tp docker"
git push origin

# 6. Créer un réseau Docker et connecter les conteneurs
echo "Création d'un réseau Docker et connexion des conteneurs..."
docker network create my_network
docker network connect my_network mariadb-server
docker network connect my_network flask-app
docker network connect my_network vuejs-app

echo "Déploiement terminé !"
