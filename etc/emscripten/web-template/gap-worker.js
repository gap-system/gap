importScripts("https://cdn.jsdelivr.net/npm/xterm-pty@0.9.4/workerTools.js");

onmessage = (msg) => {
  // Prepare the Module object BEFORE importing gap.js
  self.Module = self.Module || {};
  importScripts("gap.js");
  emscriptenHack(new TtyClient(msg.data));
};