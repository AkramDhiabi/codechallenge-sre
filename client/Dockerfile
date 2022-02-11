FROM node:14-alpine as builder

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY src src
COPY public public

RUN npm run build

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG ENVIRONMENT
ARG BUCKET

# Push frontend build to s3
RUN aws s3 cp --exclude "*index.html" \
                --exclude "*version.json" \
                --cache-control max-age=604800 \
                --recursive ./build \
                s3://$BUCKET/deployment/$ENVIRONMENT
            

FROM nginx:1.21.4-alpine as dev

COPY --from=builder /app/build/ /usr/share/nginx/html
