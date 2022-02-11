FROM node:14-alpine

WORKDIR /var/www

COPY package.json .
COPY package-lock.json .

RUN npm ci

COPY index.js .
COPY ./proto/ /var/proto/

CMD ["npm", "start"]
