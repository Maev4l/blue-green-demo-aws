FROM python:3-alpine as builder
ARG APP_VERSION

RUN pip3 install jinja2-cli[yaml,toml,xml]==0.8.2

COPY index.html.j2 /

RUN jinja2 -D APP_VERSION=$APP_VERSION /index.html.j2 > index.html

FROM nginx:alpine

COPY --from=builder /index.html /usr/share/nginx/html