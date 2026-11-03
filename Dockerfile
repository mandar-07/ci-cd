FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci --omit=dev

COPY app.js server.js ./

EXPOSE 3000

USER node

CMD ["npm", "start"]
