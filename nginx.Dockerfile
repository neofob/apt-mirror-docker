FROM nginx:1.23-alpine-slim

RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/mirror.conf
