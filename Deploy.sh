#!/bin/bash

if [ -f secrets.env ]; then
  set -o allexport
  source secrets.env
  set -o allexport
else
  echo "Le fichier secrets.env est introuvable."
  exit 1
fi

remove_existing_container() {
  container_name=$1
  if [ "$(docker ps -aq -f name=$container_name)" ]; then
    echo "Suppression du conteneur existant : $container_name"
    docker rm -f $container_name
  fi
}

remove_existing_network() {
  network_name=$1
  if [ "$(docker network ls -q -f name=$network_name)" ]; then
    echo "Suppression du réseau existant : $network_name"
    docker network rm $network_name
  fi
}

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

cd back || exit

cat <<EOF > Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
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

cd front || exit

cat <<EOF > Dockerfile
FROM node:16 AS build-stage
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build
FROM nginx:stable
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

remove_existing_container "vuejs-app"
echo "Construction de l'image Docker pour Vue.js..."
docker build -t vuejs-app .

docker run -d \
  --name vuejs-app \
  -p 80:80 \
  vuejs-app || echo "Erreur lors du lancement du conteneur Vue.js, mais continue..."
cd ..

echo "Poussée des images Docker sur DockerHub..."
docker tag flask-app ${DOCKERHUB_USERNAME}/flask-app:latest
docker tag vuejs-app ${DOCKERHUB_USERNAME}/vuejs-app:latest
docker push ${DOCKERHUB_USERNAME}/flask-app:latest
docker push ${DOCKERHUB_USERNAME}/vuejs-app:latest || echo "Erreur lors de la poussée de l'image Vue.js, mais continue..."

echo "Mise à jour du code source sur GitHub..."
git pull origin main
git add .
git commit -m "avancement tp docker"
git push origin main

remove_existing_network "TP_Docker"
echo "Création d'un réseau Docker et connexion des conteneurs..."
docker network create TP_Docker
docker network connect TP_Docker mariadb-server
docker network connect TP_Docker flask-app
docker network connect TP_Docker vuejs-app

echo "Déploiement terminé !"
