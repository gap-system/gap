# Build environment for compiling GAP to WebAssembly via Emscripten.
#
# Pinned to emsdk 3.1.23 for reproducibility. Both pieces of the in-browser
# REPL are sensitive to the exact toolchain version:
#
#  - GASMAN, GAP's conservative garbage collector, scans the stack including
#    pointers held in wasm registers, reached via emscripten_scan_registers()
#    (see src/gasman.c). That path is now compiled correctly regardless of
#    version, so the GC itself is no longer the constraint.
#
#  - The terminal uses xterm-pty, whose emscriptenHack() monkey-patches
#    emscripten's internal TTY device so GAP's tcsetattr() (turning off echo
#    and canonical mode) reaches the line discipline. That patch is tied to
#    emscripten's TTY internals: on 3.1.47 the ioctl no longer reaches
#    xterm-pty, echo stays on, and every typed line is echoed twice.
#
# 3.1.23 is the version where the pinned xterm-pty (0.9.4) works. Bump both
# together and re-test the REPL -- including that typed input is not
# double-echoed -- before changing this.

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
