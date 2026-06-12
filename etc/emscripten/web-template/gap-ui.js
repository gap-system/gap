// Main-thread logic for the GAP-in-the-browser page: terminal/worker
// lifecycle (including restart), the upload mailbox sender, the files
// panel, the examples menu, and the loading progress notice.
//
// The worker side (gap-worker.js) explains the central constraint: after
// startup the worker only runs during terminal operations, blocking in
// Atomics.wait the rest of the time. So uploads go through a
// SharedArrayBuffer mailbox the worker drains on terminal activity, and
// the worker pushes copies of every user file to this thread, so
// downloads are served from a local cache and never need to ask a
// (possibly blocked) worker.

"use strict";

// ---- upload mailbox protocol; keep in sync with gap-worker.js ----
const MB_STATE = 0, MB_LEN = 1, MB_FLAGS = 2;
const MB_IDLE = 0, MB_READY = 1, MB_CONSUMED = 2;
const MB_FLAG_HEADER = 1, MB_FLAG_FINAL = 2, MB_FLAG_END = 4;
const MB_CTRL_BYTES = 16;
const MB_DATA_BYTES = 1 << 20;

// Multi-line examples: every line except the last is submitted as it is
// pasted (the newline acts as Enter), so earlier lines run immediately —
// keep them to setup (silenced with ";;" or printing the definition);
// only the last line waits for the user's Enter.
const EXAMPLES = [
  { label: "Intersect two permutation groups",
    code: 'G := Group((1,2,3)(4,5,6), (1,4), (2,5), (3,6));\n' +
          'H := Group((1,2,4,6), (4,6));\n' +
          'Intersection(G, H);' },
  { label: "Character table of A5",
    code: 'Display(CharacterTable(AlternatingGroup(5)));' },
  { label: "The groups of order 12",
    code: 'List(AllSmallGroups(12), StructureDescription);' },
  { label: "Factorise a Fermat number",
    code: 'Factors(2^64 + 1);' },
  { label: "A finitely presented group",
    code: 'F := FreeGroup("a", "b");;\nG := F / [F.1^2, F.2^3, (F.1*F.2)^5];; Size(G);' },
];

const loadingEl = document.getElementById("loading");
const unsupportedEl = document.getElementById("unsupported");
const terminalEl = document.getElementById("terminal");
const restartBtn = document.getElementById("restart");
const uploadInput = document.getElementById("upload-input");
const uploadBtn = document.getElementById("upload-button");
const fileListEl = document.getElementById("file-list");
const fileEmptyEl = document.getElementById("files-empty");
const examplesEl = document.getElementById("example-list");

// URLs reported by gap-fs.js's fetch/XHR instrumentation, for rebuilding
// startup_manifest.json (see README.md). Inspect from the devtools
// console with copy(JSON.stringify(fetchedUrls)).
window.fetchedUrls = [];
const fetchedSet = new Set();

// Number of files the startup manifest will fetch on a cold visit, for
// the progress notice. 0 (missing/empty manifest) keeps the generic text.
let manifestTotal = 0;
fetch("startup_manifest.json")
  .then((r) => (r.ok ? r.json() : []))
  .then((list) => { manifestTotal = list.length; })
  .catch(() => {});

// The files panel cache: path -> entry. Entries survive a session restart
// (status "previous"): the bytes are still here, so they stay
// downloadable, and inserting their Read command first re-uploads them
// into the new session.
//   { size, data: Uint8Array, status: "transferring"|"ready"|"previous" }
const fileEntries = new Map();

// Per-session state; replaced wholesale by startSession() so that any
// in-flight async sender from a dead session aborts cleanly.
let session = null;

function gapQuote(path) {
  return '"' + path.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"';
}

function humanSize(n) {
  if (n < 1024) return n + " B";
  if (n < 1024 * 1024) return (n / 1024).toFixed(1) + " kB";
  return (n / (1024 * 1024)).toFixed(1) + " MB";
}

// Paste text at GAP's prompt. Deliberately no trailing newline: the user
// presses Enter, so nothing is ever auto-executed.
function insertAtPrompt(text) {
  if (session === null) return;
  session.xterm.paste(text);
  session.xterm.focus();
}

// ---------------------------------------------------------------------
// Upload sender. Writes one chunk whenever the worker has consumed the
// previous one; never blocks the main thread (Atomics.wait is forbidden
// here, so it uses Atomics.waitAsync where available and polling
// otherwise). The worker only drains on terminal activity, so a transfer
// started while GAP sits at its prompt completes on the next keystroke —
// in particular, the keystrokes of a pasted Read command arrive after
// the drain runs, so the file is always in place before Enter.

function waitMailboxState(s, want) {
  return new Promise((resolve, reject) => {
    const check = () => {
      if (s.dead) {
        reject(new Error("session restarted"));
        return;
      }
      const cur = Atomics.load(s.mbCtrl, MB_STATE);
      if (cur === want) {
        resolve();
        return;
      }
      if (Atomics.waitAsync) {
        const r = Atomics.waitAsync(s.mbCtrl, MB_STATE, cur, 1000);
        if (r.async) r.value.then(check);
        else check();
      } else {
        setTimeout(check, 10);
      }
    };
    check();
  });
}

function writeChunk(s, bytes, flags) {
  s.mbData.set(bytes, 0);
  s.mbCtrl[MB_LEN] = bytes.length;
  s.mbCtrl[MB_FLAGS] = flags;
  Atomics.store(s.mbCtrl, MB_STATE, MB_READY);
  Atomics.notify(s.mbCtrl, MB_STATE);
}

// files: [{ name, data: Uint8Array }]
async function sendFiles(files) {
  const s = session;
  for (const f of files) {
    fileEntries.set(f.name, { size: f.data.length, data: f.data,
                              status: "transferring" });
    s.uploadQueue.push(f);
  }
  renderFiles();
  if (s.senderActive) return;
  s.senderActive = true;
  try {
    await waitMailboxState(s, MB_IDLE);
    while (s.uploadQueue.length > 0) {
      const f = s.uploadQueue.shift();
      const header = new TextEncoder().encode(
        JSON.stringify({ name: f.name, size: f.data.length }));
      writeChunk(s, header, MB_FLAG_HEADER);
      await waitMailboxState(s, MB_CONSUMED);
      let off = 0;
      do {
        const n = Math.min(MB_DATA_BYTES, f.data.length - off);
        const last = off + n >= f.data.length;
        writeChunk(s, f.data.subarray(off, off + n),
                   last ? MB_FLAG_FINAL : 0);
        off += n;
        await waitMailboxState(s, MB_CONSUMED);
      } while (off < f.data.length);
    }
    // Close the session; the worker hands the mailbox back as MB_IDLE.
    writeChunk(s, new Uint8Array(0), MB_FLAG_END);
  } catch (e) {
    // Only a restart gets here; the entries were already marked
    // "previous" by the restart handler.
    if (!s.dead) throw e;
  } finally {
    s.senderActive = false;
  }
}

// ---------------------------------------------------------------------
// Files panel

function downloadEntry(path) {
  const entry = fileEntries.get(path);
  const blob = new Blob([entry.data]);
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = path.split("/").pop();
  a.click();
  URL.revokeObjectURL(a.href);
}

function insertEntry(path) {
  const entry = fileEntries.get(path);
  if (entry.status === "previous") {
    // From a previous session: put it back first. The re-upload drains
    // before the pasted command's Enter can be processed.
    sendFiles([{ name: path, data: entry.data }]);
  }
  insertAtPrompt("Read(" + gapQuote(path) + ");");
}

function renderFiles() {
  fileListEl.textContent = "";
  fileEmptyEl.style.display = fileEntries.size === 0 ? "" : "none";
  const paths = Array.from(fileEntries.keys()).sort();
  for (const path of paths) {
    const entry = fileEntries.get(path);
    const li = document.createElement("li");

    const nameSpan = document.createElement("span");
    nameSpan.className = "file-name";
    nameSpan.textContent = path;
    nameSpan.title = path;

    const metaSpan = document.createElement("span");
    metaSpan.className = "file-meta";
    metaSpan.textContent = humanSize(entry.size) +
      (entry.status === "transferring" ? " · sending…"
       : entry.status === "failed" ? " · failed"
       : entry.status === "previous" ? " · previous session" : "");

    const insertB = document.createElement("button");
    insertB.className = "icon-button";
    insertB.textContent = "↳";
    insertB.title = "Insert Read(" + gapQuote(path) + "); at the prompt" +
      (entry.status === "previous" ? " (re-uploads the file first)" : "");
    insertB.addEventListener("click", () => insertEntry(path));

    const downloadB = document.createElement("button");
    downloadB.className = "icon-button";
    downloadB.textContent = "⬇";
    downloadB.title = "Download " + path;
    downloadB.addEventListener("click", () => downloadEntry(path));

    const text = document.createElement("div");
    text.className = "file-text";
    text.append(nameSpan, metaSpan);
    li.append(text, insertB, downloadB);
    fileListEl.append(li);
  }
}

uploadBtn.addEventListener("click", () => uploadInput.click());
uploadInput.addEventListener("change", async () => {
  const files = [];
  for (const f of uploadInput.files) {
    // Basename only: uploads land directly in GAP's working directory.
    const name = f.name.split(/[/\\]/).pop();
    if (name === "") continue;
    const data = new Uint8Array(await f.arrayBuffer());
    files.push({ name: name, data: data });
  }
  uploadInput.value = "";
  if (files.length > 0) sendFiles(files);
});

// ---------------------------------------------------------------------
// Examples

for (const ex of EXAMPLES) {
  const li = document.createElement("li");
  const b = document.createElement("button");
  b.className = "example-button";
  b.textContent = ex.label;
  b.title = ex.code;
  b.addEventListener("click", () => insertAtPrompt(ex.code));
  li.append(b);
  examplesEl.append(li);
}

// ---------------------------------------------------------------------
// Session lifecycle

function handleWorkerMessage(ev) {
  const data = ev.data;
  if (!data || !data.type) return;
  switch (data.type) {
    case "gap-fetched":
      if (!fetchedSet.has(data.url)) {
        fetchedSet.add(data.url);
        window.fetchedUrls.push(data.url);
        if (/^(pkg|lib|grp|tst|doc|hpcgap|dev|benchmark)\//.test(data.url)) {
          session.fetchCount++;
          if (!session.started) {
            const progress = "fetched " + session.fetchCount +
              (manifestTotal > 0 ? " of ~" + manifestTotal : "") + " files";
            loadingEl.textContent = "Loading GAP… " + progress + ".";
            // \r keeps overwriting one progress line in the terminal.
            session.xterm.write("\rLoading GAP… " + progress);
          }
        }
      }
      break;
    case "gap-user-files":
      for (const f of data.changed) {
        fileEntries.set(f.path, { size: f.size, data: f.data,
                                  status: "ready" });
      }
      for (const p of data.removed) {
        // Deleted inside GAP; drop it from the panel too.
        fileEntries.delete(p);
      }
      renderFiles();
      break;
    case "gap-file-uploaded": {
      const entry = fileEntries.get(data.name);
      if (entry && entry.status === "transferring") entry.status = "ready";
      renderFiles();
      break;
    }
    case "gap-file-error":
      console.error("Upload failed in worker:", data);
      for (const entry of fileEntries.values()) {
        if (entry.status === "transferring") entry.status = "failed";
      }
      renderFiles();
      break;
  }
}

function startSession() {
  loadingEl.style.display = "";
  loadingEl.textContent = "Loading GAP… The first visit downloads several " +
    "tens of megabytes; later visits are cached by your browser and " +
    "start much faster.";

  const xterm = new Terminal({
    fontFamily: '"Ubuntu Mono", Menlo, Consolas, monospace',
    fontSize: 15,
    cursorBlink: true,
    theme: { background: "#1d1d1d", foreground: "#e6e6e6" },
  });
  const fitAddon = new FitAddon.FitAddon();
  xterm.loadAddon(fitAddon);
  xterm.open(terminalEl);
  fitAddon.fit();

  const { master, slave } = openpty();
  xterm.loadAddon(master);

  const mailbox = new SharedArrayBuffer(MB_CTRL_BYTES + MB_DATA_BYTES);
  const worker = new Worker("gap-worker.js");
  worker.postMessage({ type: "gap-init", mailbox: mailbox });

  session = {
    xterm: xterm,
    fitAddon: fitAddon,
    master: master,
    slave: slave,
    worker: worker,
    mbCtrl: new Int32Array(mailbox, 0, 4),
    mbData: new Uint8Array(mailbox, MB_CTRL_BYTES),
    uploadQueue: [],
    senderActive: false,
    fetchCount: 0,
    started: false,
    dead: false,
  };
  const s = session;

  // GAP's first terminal output arrives as the worker's first "write"
  // tty request. Detect it here (this listener is registered before
  // TtyServer.start assigns worker.onmessage, so it runs first) and
  // reset the terminal, so the waiting/progress text below is wiped
  // and the GAP banner starts on a clean screen.
  worker.addEventListener("message", (ev) => {
    const d = ev.data;
    if (d && d.ttyRequestType === "write" && !s.started) {
      s.started = true;
      s.xterm.reset();
      loadingEl.style.display = "none";
    }
  });

  session.ttyServer = new TtyServer(slave);
  session.ttyServer.start(worker, handleWorkerMessage);

  xterm.write(
    "\x1b[2mPlease wait — downloading and starting GAP.\r\n" +
    "The first visit can take a few minutes; repeat visits are cached " +
    "by your browser and start much faster.\x1b[0m\r\n\r\n");
}

function restartSession() {
  session.dead = true;
  session.worker.terminate();
  session.xterm.dispose();
  for (const entry of fileEntries.values()) {
    // The session's filesystem is gone, but our cached bytes are not.
    entry.status = "previous";
  }
  renderFiles();
  startSession();
}

window.addEventListener("resize", () => {
  if (session !== null) session.fitAddon.fit();
});

restartBtn.addEventListener("click", () => {
  if (session !== null) restartSession();
});

// Without SharedArrayBuffer the worker can't talk to the page
// synchronously; xterm-pty would stall on every read.
if (typeof SharedArrayBuffer === "undefined") {
  loadingEl.style.display = "none";
  unsupportedEl.style.display = "block";
} else {
  renderFiles();
  startSession();
}
