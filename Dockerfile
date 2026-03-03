# NanoClaw Orchestrator
# Runs the main NanoClaw process (WhatsApp + K8s Job creator)

FROM node:22-slim AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --ignore-scripts

COPY tsconfig.json ./
COPY src/ ./src/
RUN npx tsc

FROM node:22-slim
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

# Set in K8s Deployment: DATA_DIR, GROUPS_DIR, STORE_DIR, K8S_* vars
# Secrets come from envFrom nanoclaw-secrets: ANTHROPIC_API_KEY, CLAUDE_CODE_OAUTH_TOKEN
CMD ["node", "dist/index.js"]
