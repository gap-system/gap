Code to allow building gap to WASM using Emscripten.

Files:

- `build.sh`: Run as `etc/emscripten/build.sh` from a fresh copy of GAP.

Note that this built copy has one major weakness -- the 'gap.data' (which includes all packages files) is huge.


- `web-template`: Uses 'xterm-pty' to create a "nice" interface to the Wasm GAP.

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
