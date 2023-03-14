ARG APP_VERSION

FROM golang:alpine3.17 as builder
ARG APP_VERSION
WORKDIR /app

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY cmd/ ./
COPY templates/ ./templates/

RUN GOOS=linux go build -ldflags="-s -w" 

FROM alpine:3.17
ARG APP_VERSION
ENV VERSION=$APP_VERSION
COPY --from=builder /app/bgdemo /bgdemo
COPY --from=builder /app/templates/index.tmpl /templates/index.tmpl

CMD [ "/bgdemo" ]