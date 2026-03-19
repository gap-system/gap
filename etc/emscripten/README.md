Code to allow building gap to WASM using Emscripten.

Files:

- `build.sh`: Run as `etc/emscripten/build.sh` from a fresh copy of GAP.

- `web-template`: Uses 'xterm-pty' to create a "nice" interface to the Wasm GAP.

- `build_startup_manifest.js`: Run it in the web root directory to build `startup_manifest.json` that contains resources to preload.

- `build_manual_manifest.js`: Run it in the web root directory to build `manual_manifest.json` that contains all `.six` files to preload.

See 'run-web-demo.sh' as an example on how to set up a working website.

Note that this demo uses xterm-pty, a library which provides a terminal interface
for emscripten-compiled programs. This uses a javascript feature called 
"SharedArrayBuffer", which requires some headers are returned by the server:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

For more details, see for [this article](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer).

The file "coi-serviceworker.js" works around this problem on Github pages. This won't
work locally, so "server.rb" is a simple ruby script, which just starts a web-server
which returns the required headers.

You can combine `startup_manifest.json` and `manual_manifest.json` using the command:
```
jq -s 'add | unique' startup_manifest.json manual_manifest.json > temp_manifest.json 
mv temp_manifest.json startup_manifest.json
```