# ──────── 1️⃣  STAGE BUILD : installation des dépendances ────────
# Contournement de la version ancienne de Vue.js
FROM node:14-slim AS build

# Yarn classic
RUN corepack enable && corepack prepare yarn@1.22.19 --activate

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build        # crée le dossier dist/

# ──────── 2️⃣  STAGE PROD – Nginx ultra‑léger ────────
FROM nginx:1.27 AS prod

# Copie du build statique
COPY --from=build /app/dist /usr/share/nginx/html

# Configuration Nginx adaptée aux SPAs (fallback → index.html)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
