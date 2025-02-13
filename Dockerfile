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

RUN git clone --depth=1 https://github.com/gap-system/gap.git

WORKDIR /opt/gap

RUN ./autogen.sh && \
    ./configure --parallel=$(nproc) && \
    make -j$(nproc)

FROM alpine:latest

RUN apk add --no-cache gmp zlib

WORKDIR /opt/gap
COPY --from=builder /opt/gap /opt/gap

RUN adduser -D -g "" gapuser
USER gapuser

ENTRYPOINT ["./gap"]
