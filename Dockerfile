FROM golang:1.25.5@sha256:8bbd14091f2c61916134fa6aeb8f76b18693fcb29a39ec6d8be9242c0a7e9260 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN make

FROM ubuntu:noble-20251013@sha256:c35e29c9450151419d9448b0fd75374fec4fff364a27f176fb458d472dfc9e54 AS base

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/bin/kamal-proxy /usr/local/bin/

EXPOSE 80 443

RUN useradd kamal-proxy \
    && mkdir -p /home/kamal-proxy/.config/kamal-proxy \
    && chown -R kamal-proxy:kamal-proxy /home/kamal-proxy

USER kamal-proxy:kamal-proxy

CMD ["kamal-proxy", "run"]
