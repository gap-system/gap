# Vendored assets

Pinned copies of the third-party files the page needs at runtime, so the
deployed site has no CDN dependency and works offline. The COEP header the
page requires (`require-corp`) also makes same-origin copies the most
robust option.

| File(s) | Upstream | Version | Licence |
| ------- | -------- | ------- | ------- |
| `xterm.min.js`, `xterm.css` | <https://cdn.jsdelivr.net/npm/xterm@4.17.0/> | 4.17.0 | MIT |
| `xterm-addon-fit.min.js` | <https://cdn.jsdelivr.net/npm/xterm-addon-fit@0.5.0/> | 0.5.0 | MIT |
| `xterm-pty/index.js`, `xterm-pty/workerTools.js` | <https://cdn.jsdelivr.net/npm/xterm-pty@0.9.4/> | 0.9.4 | MIT |
| `gaplogo.svg`, `favicon.svg` | <https://github.com/gap-system/GapWWW> (`assets/logo/`) | — | GAP project |
| `fonts/*.woff2`, `fonts/UFL.txt` | Ubuntu Font Family, © Canonical Ltd. (<https://design.ubuntu.com/font>); copied from <https://github.com/gap-system/GapWWW> (`assets/fonts/`) | — | Ubuntu Font Licence 1.0 |
| `../coi-serviceworker.js` | <https://github.com/gzuidhof/coi-serviceworker> | master @ 509a799 (post-0.1.7) | MIT |

`coi-serviceworker.js` lives next to `index.html`, not in `vendor/`: a
service worker can only control pages at or below its own path. The
post-0.1.7 master version matters for WebKit (Safari/iOS): 0.1.6 never
injected `Cross-Origin-Resource-Policy`, which WebKit requires under
COEP `require-corp`, so Safari never became cross-origin isolated and
`SharedArrayBuffer` stayed unavailable.

To bump a version, download the new files from the matching jsdelivr URL
and update this table. xterm-pty's version is coupled to the emsdk version
(see `etc/emscripten/README.md`): `emscriptenHack()` patches emscripten's
TTY internals, so test the REPL (echo, line editing, history) after any
change. xterm-addon-fit 0.5.x is the line compatible with xterm 4.x.
