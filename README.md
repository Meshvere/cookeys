# aciah-apprenti-clavier
CooKeys pour l'ACIAH

# Lancer le projet en mode développement
Se rendre dans le répertoire où a été cloné le repository et lancer la commande

`docker compose --profile dev up -d`

La première initialisation sera potentiellement longue car il devra construire les conteneurs et effectuer l'installation des dépendances Javascript.

# Lancer le projet en mode production
## 1) Construire le conteneur de production

`docker compose --profile prod build`

## 2) Lancer la production en local

`docker compose --profile prod up -d`

# Générer l'application autonome
Le conteneur n'a pas vocation a resté monté, il n'est là que pour générer les applications.
## 1) Construire le conteneur de génération

`docker compose --profile app build`

## 2) Lancer la génération en local

`docker compose --profile app up`

## 3) Récupérer les applications
Elles seront stockées dans le répertoire release de votre repository

## Installer Docker sous Debian
### Installer les dépendances nécessaires

`sudo apt update`

`sudo apt install -y ca-certificates curl gnupg lsb-release`

### Ajouter la clé GPG officielle de Docker

`sudo install -m 0755 -d /etc/apt/keyrings`

`curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg`

`sudo chmod a+r /etc/apt/keyrings/docker.gpg`

### Ajouter le dépôt Docker stable

`echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null`

### Installer Docker Engine, Docker CLI, containerd et Docker Compose plugin

`sudo apt update`

`sudo apt install -y docker-ce docker-ce-cli containerd.io  docker-buildx-plugin docker-compose-plugin`

### Vérifier que Docker fonctionne

`sudo docker version`

On doit voir Docker Compose listé dans les plugins, on peut le vérifier avec :
`docker compose version`
