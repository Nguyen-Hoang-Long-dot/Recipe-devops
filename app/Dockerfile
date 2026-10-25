# ---------- Stage 1: cai dependency ----------
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev --no-audit --no-fund

# ---------- Stage 2: image chay that ----------
FROM node:20-alpine
ENV NODE_ENV=production
WORKDIR /app

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package.json ./
COPY --chown=node:node src ./src
COPY --chown=node:node views ./views
COPY --chown=node:node public ./public

# Hardening: khong chay bang root (user "node" uid=1000 co san trong image)
USER node
EXPOSE 3000
CMD ["node", "src/server.js"]
