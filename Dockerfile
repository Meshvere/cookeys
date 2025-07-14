# ──────── (1)  STAGE BUILD : installation des dépendances ────────
# Contournement de la version ancienne de Vue.js
FROM node:14-slim AS build

# Yarn classic
RUN corepack enable && corepack prepare yarn@1.22.19 --activate

# Ajout de Git pour yarn install
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build        # crée le dossier dist/

# ──────── (2)  STAGE PROD – Nginx ultra‑léger ────────
FROM nginx:1.27 AS prod

# Copie du build statique
COPY --from=build /app/dist /usr/share/nginx/html

# Configuration Nginx adaptée aux SPAs (fallback → index.html)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# ──────── (3)  STAGE APP – ElectronJS Windows & Linux ────────
FROM electronuserland/builder:wine AS electron-build

# Dépendances Linux que l’image wine n’installe pas toujours
RUN apt-get update && apt-get install -y \
    libgtk-3-0 libnss3 libxss1 libasound2 libatk-bridge2.0-0 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copie l’ensemble du code + le dist depuis l’étape de build
WORKDIR /app
COPY . .

WORKDIR /app
# Mise à jour des dépendances (yarn déjà dispo dans l'image)
RUN yarn install --frozen-lockfile

# Corrige les permissions du sandbox
RUN chown root:root node_modules/electron/dist/chrome-sandbox && \
    chmod 4755 node_modules/electron/dist/chrome-sandbox

# ──────── (4)  STAGE APP – Tauri ────────
FROM ubuntu:24.04 as tauri

RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list
RUN apt update

# ---------- 1. Dépendances de cross‑compilation ----------
RUN apt update && \
    apt install -y build-essential curl \
      wget \
      gnupg \
      libssl-dev \
      fuse \
      libayatana-appindicator3-dev \
      patchelf \
    mingw-w64 xz-utils zip gnupg2 ca-certificates \
    git pkg-config libglib2.0-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    squashfs-tools \
    wine-stable wine64 nsis nsis-common

# ---------- 2. Node & Yarn ----------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs && npm i -g yarn

# ---------- 3. Rust toolchain + cible windows‑gnu ----------
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add x86_64-pc-windows-gnu

# ---------- 5. Build ----------
WORKDIR /app
COPY . .

# installe deps front, bundle, puis build tauri pour windows
RUN yarn install --frozen-lockfile
RUN yarn build
