# Build environment for compiling GAP to WebAssembly via Emscripten.
#
# Pinned to emsdk 3.1.23: GAP relies on subtle memory/stack behaviour
# (notably the ASYNCIFY interaction with GASMAN) that has broken on newer
# emscripten releases.

FROM emscripten/emsdk:3.1.23

RUN apt-get update && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        libtool \
        make \
        python3 \
        ca-certificates \
        curl \
        bison \
        byacc \
        m4 \
    && rm -rf /var/lib/apt/lists/*

# Allow running as a non-root host UID without breaking the emscripten cache.
RUN mkdir -p /emsdk/upstream/emscripten/cache \
    && chmod -R 0777 /emsdk/upstream/emscripten/cache

# Cache the GAP package distribution tarball so container runs don't
# re-download it from GitHub each time. The URL pins to the "latest"
# release on the PackageDistro side, so this snapshot drifts as upstream
# tags new releases — rebuild the image (--no-cache) to refresh.
ARG GAP_PACKAGES_URL=https://github.com/gap-system/PackageDistro/releases/download/latest/packages.tar.gz
RUN curl --fail --location --silent --show-error \
        --output /opt/gap-packages.tar.gz \
        "$GAP_PACKAGES_URL" \
    && chmod 0644 /opt/gap-packages.tar.gz

WORKDIR /gap
