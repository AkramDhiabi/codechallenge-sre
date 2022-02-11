FROM node:14-slim as builder

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
ARG VERSION
ARG BUILD_BUCKET

RUN apt-get update \
    && apt-get install -y \
     fontconfig \
     zip \
     unzip \
     curl \
   && rm -rf /var/lib/apt/lists/*

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip
RUN ./aws/install && aws --version

# Push frontend build to s3
RUN aws s3 cp --cache-control max-age=0,no-cache,no-store,must-revalidate \
              --recursive ./build \
                s3://$BUILD_BUCKET/deployment/$VERSION
            

FROM nginx:1.21.4-alpine as dev

COPY --from=builder /app/build/ /usr/share/nginx/html
