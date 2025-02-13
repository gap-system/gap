FROM alpine:latest

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
    ./configure && \
    make -j$(nproc)

CMD ["./gap"]
