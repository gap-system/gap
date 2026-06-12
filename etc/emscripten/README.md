# GAP in the browser

Build GAP as a WebAssembly module and serve it as a self-contained website.
The terminal interface uses [xterm-pty](https://github.com/mame/xterm-pty),
so the resulting page behaves like a normal GAP REPL. The page is styled
to match <https://www.gap-system.org> (Ubuntu fonts, GAP logo, crimson
accents, dark-mode support) and adds a side panel for moving files in and
out of the browser session, an examples menu, and a restart button.

## Quick start

From a fresh GAP checkout, with either Docker or Podman installed:

```sh
etc/emscripten/build-in-docker.sh
cd web-example
../etc/emscripten/serve.py
```

Then open <http://localhost:8080/>. The first build takes 10–30 minutes; the
docker image, the GAP package distribution, and the GMP/zlib builds are all
cached for subsequent runs.

To pick up newer GAP packages from upstream, force a fresh image build:

```sh
docker build --no-cache -t gap-emscripten-build:3.1.23 etc/emscripten/
```

On Apple Silicon (and other non-amd64 hosts), the build runs `linux/amd64`
under emulation, since `emscripten/emsdk:3.1.23` is amd64-only on Docker
Hub. `build-in-docker.sh` pins the platform explicitly so the layer cache
holds across runs; set `BUILD_PLATFORM` to override.

The output directory `web-example/` is fully self-contained — copy it to any
static host (see "Hosting" below for the headers it needs).

## Building without Docker

If you already have emsdk 3.1.23 sourced in your shell, you can run the
underlying build directly:

```sh
etc/emscripten/build.sh
etc/emscripten/assemble-website.sh
```

emsdk 3.1.23 is the version we test against, paired with xterm-pty 0.9.4.
GAP relies on ASYNCIFY together with GASMAN's conservative GC, which scans
wasm registers via `emscripten_scan_registers()` (see `src/gasman.c`); and
the terminal relies on xterm-pty's `emscriptenHack()` patching emscripten's
TTY device so `tcsetattr()` reaches the line discipline. Both are sensitive
to the toolchain version (a newer emsdk leaves `tcsetattr` unhonoured, so
typed input is echoed twice), so re-test the REPL when changing emsdk.

## The page: file transfer, examples, restart

GAP runs with its working directory set to `/home/web_user` in the
virtual filesystem (the GAP tree itself sits at `/`, passed via `-l /`).
That directory starts empty, so everything in it is the user's: uploads
land there, and anything GAP creates there (`PrintTo`, `LogTo`, …) shows
up in the page's Files panel for download.

The design is shaped by one constraint. Once GAP's `main()` starts, the
worker thread never returns to its event loop: every terminal operation
blocks in `Atomics.wait` inside xterm-pty's `TtyClient` until the main
thread responds. So `postMessage` *to* the worker is never delivered
after startup, while `postMessage` *from* the worker (the tty request
channel itself) always works. Hence:

- **Uploads** go through a `SharedArrayBuffer` mailbox (chunked, see the
  protocol comment in `gap-worker.js`; the sending side is in
  `gap-ui.js`). The worker drains it at the start of every terminal
  operation — the moments it is provably awake. An upload made while GAP
  sits idle at its prompt therefore completes on the next terminal
  activity; in particular, the Files panel's "insert `Read("file");`"
  button pastes keystrokes whose processing drains the mailbox before
  GAP ever sees the Enter, so the file is always in place in time.
- **Downloads** are pushed: when GAP asks for input (output has settled,
  files are complete), the worker rescans `/home/web_user` and posts new
  or changed files to the page, which caches the bytes. A download click
  is served from that cache — it never has to ask the possibly-blocked
  worker. This is also why a freshly written file only appears in the
  panel once GAP is back at a prompt (or asks for input).
- Inserted commands (file hints and the examples menu) are pasted
  *without* a newline; the user always presses Enter, so nothing is
  auto-executed.

Known limitations, all consequences of the same architecture:

- Ctrl-C cannot interrupt a running computation: there are no signals,
  the main thread cannot reach the worker's wasm heap, and GAP cannot
  poll JavaScript state while computing. The Restart button (which
  terminates and respawns the worker) is the only escape from a runaway
  computation. The Files panel keeps its cached entries across a
  restart, still downloadable; inserting one re-uploads it first.
- User files do not persist across reloads or restarts (syncing them to
  IndexedDB would need the worker's event loop, which is starved).
- The terminal is sized to the window before GAP starts; GAP does not
  notice later resizes (no SIGWINCH), though xterm itself reflows.

## Hosting

The xterm-pty terminal uses `SharedArrayBuffer`, which browsers only allow
when the page is served with these two headers:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

`serve.py` is a 20-line stdlib-only Python server that adds them. For
GitHub Pages and other static hosts that don't let you set headers,
`web-template/coi-serviceworker.js` is included as a workaround (it
re-fetches resources through a service worker that adds the headers).

## Files

| File | Role |
| ---- | ---- |
| `build-in-docker.sh` | One-stop entry point. Builds the image, runs `build.sh` inside, then `assemble-website.sh`. |
| `Dockerfile` | Pinned `emscripten/emsdk:3.1.23` with autotools, python3, bison/byacc/m4, and a baked-in copy of the GAP package distribution tarball at `/opt/gap-packages.tar.gz`. |
| `build.sh` | Configures and builds GMP, zlib, and GAP itself for wasm. |
| `assemble-website.sh` | Copies the build outputs and data directories (`pkg`, `lib`, `grp`, …) into `web-example/`. |
| `generate_gap_fs_json.py` | Reads file paths on stdin, writes `gap-fs.json` (the manifest of every file in the virtual FS). |
| `startup_manifest.json` | List of files to fetch eagerly at startup, captured from a real GAP run. Anything not in this list is fetched lazily on first read. See "Updating the startup manifest" below for how to refresh it. |
| `serve.py` | Local server that adds the COOP/COEP headers. |
| `web-template/` | Static UI: `index.html`, the page logic (`gap-ui.js`), the worker scripts, the FS init shim, and the COOP/COEP service worker for hosts where you can't set headers. |
| `web-template/vendor/` | Pinned local copies of xterm, xterm-pty, the fit addon, the GAP logo and the Ubuntu fonts, so the deployed site has no CDN dependency. See `web-template/vendor/README.md` for versions and how to update them. |

## Updating the startup manifest

`startup_manifest.json` lists files (relative to the GAP root) that the FS
init shim downloads up front instead of lazily. The current list was
captured from a real GAP run reaching its prompt, so it includes both
the core library bootstrap (`lib/init.g`, `lib/read*.g`, …) and any
default-loaded packages. Entries that no longer exist in the build are
silently ignored, so it is safe to leave stale entries in place; it is
also safe to leave the list empty (every file becomes lazy).

The manifest is a startup-time optimisation, not a correctness mechanism:
a wrong list never breaks the build, it only makes startup slower (files
GAP needs but the manifest omits get fetched lazily, one round-trip each)
or wastes bandwidth (files in the manifest that GAP doesn't actually
read are downloaded anyway). So it's worth refreshing when something
changes the set of files read at startup — most importantly when the
default loaded packages change, but also after large library reshuffles.

To regenerate it after such changes:

1. Build the website (`build-in-docker.sh`) and serve it (`serve.py`).
2. **Empty the served manifest before capturing.** Replace
   `web-example/startup_manifest.json` with `[]` (or delete it).
   Otherwise the existing entries are eagerly pre-fetched at startup,
   appear in `fetchedUrls`, and you'll just round-trip the old list.
   Editing the served file is enough — no rebuild is needed.
3. Open the page and wait for the GAP prompt to appear. Every file that
   GAP actually reads now goes through the lazy `XHR` path and gets
   captured.
4. Open devtools and read the captured URLs from the page's JS console:
   `window.fetchedUrls` is an array of every unique URL the worker
   requested. Chrome/Firefox provide a `copy()` console helper:
   `copy(JSON.stringify(fetchedUrls))` puts the JSON on your clipboard.
5. Strip non-GAP-FS entries (`gap.js`, `gap.wasm`, `gap-fs.json`, and any
   `vendor/` assets) and write the result to
   `etc/emscripten/startup_manifest.json` (so it's checked in and gets
   picked up by the next `assemble-website.sh`). A `jq` filter that
   keeps just GAP filesystem paths:

   ```sh
   jq '[.[] | select(test("^(pkg|lib|grp|tst|doc|hpcgap|dev|benchmark)/"))]' \
      fetched-urls.json > etc/emscripten/startup_manifest.json
   ```

The bookkeeping lives in `web-template/gap-fs.js` (wraps `fetch` and
`XMLHttpRequest.open` to report URLs to the main thread) and
`web-template/index.html` (accumulates them onto `window.fetchedUrls`).
