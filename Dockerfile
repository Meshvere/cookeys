# ──────── 1️⃣  STAGE BUILD : installation des dépendances ────────
# Contournement de la version ancienne de Vue.js
FROM node:14-slim AS build

RUN corepack enable && corepack prepare yarn@1.22.19 --activate

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# ──────── 2️⃣  STAGE RUNTIME : exécution en mode développement avec Node 10 ────────
FROM node:10

# Installe Yarn 1.x sans créer de lien manuel
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Ajoute ~/.yarn/bin au PATH pour tous les users
ENV PATH="/root/.yarn/bin:$PATH"

WORKDIR /app

COPY --from=build /app/node_modules ./node_modules
COPY . .

EXPOSE 8080

CMD ["yarn", "dev"]
