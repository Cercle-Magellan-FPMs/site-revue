# syntax=docker/dockerfile:1
# Astro n'est utilisé que pendant la compilation.
FROM node:22-alpine AS builder

WORKDIR /app
ENV CI=true

COPY package*.json ./
# Pas de package-lock.json dans ce dépôt pour le moment.
RUN npm install --no-audit --no-fund

COPY . .
RUN npm run build

# En production, aucun runtime Node.js ni dépendance npm.
FROM nginx/nginx-unprivileged:stable-alpine AS runtime

COPY --from=builder --chown=nginx:nginx /app/dist/ /usr/share/nginx/html/
COPY --chown=nginx:nginx nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
