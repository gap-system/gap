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

FROM alpine:latest

RUN apk add --no-cache gmp zlib

WORKDIR /opt
COPY --from=builder /opt/gap /opt/gap

RUN adduser -D -g "" gapuser
USER gapuser

ENTRYPOINT ["./gap"]
