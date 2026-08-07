FROM alpine:latest AS builder

RUN apk add --no-cache \
    build-base \
    autoconf \
    automake \
    libtool \
    gmp-dev \
    zlib-dev \
    curl \
    git

WORKDIR /opt

COPY . .

RUN ./autogen.sh && \
    ./configure && \
    make -j$(nproc)

RUN adduser -D -g "" gapuser
USER gapuser

ENTRYPOINT ["./gap"]
