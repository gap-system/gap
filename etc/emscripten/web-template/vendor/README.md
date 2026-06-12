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

To bump a version, download the new files from the matching jsdelivr URL
and update this table. xterm-pty's version is coupled to the emsdk version
(see `etc/emscripten/README.md`): `emscriptenHack()` patches emscripten's
TTY internals, so test the REPL (echo, line editing, history) after any
change. xterm-addon-fit 0.5.x is the line compatible with xterm 4.x.
