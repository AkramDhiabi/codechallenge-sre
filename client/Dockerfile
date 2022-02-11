FROM node:14-alpine as builder

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY src src
COPY public public

RUN npm run build

FROM nginx:1.21.4-alpine as dev

COPY --from=builder /app/build/ /usr/share/nginx/html
