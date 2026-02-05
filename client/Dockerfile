FROM node:20-alpine AS base

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

FROM node:20-alpine AS dev

WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=development

EXPOSE 3001

CMD ["npm", "run", "dev"]

FROM base AS build

WORKDIR /app
COPY . .

ENV NODE_ENV=production

RUN npm run build

FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app/.output ./.output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]


