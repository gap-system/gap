// GAP worker: loads the wasm module and wires its TTY to the xterm-pty
// server on the main thread.
//
// Once GAP's main() starts, this thread never returns to the event loop:
// every terminal operation goes through TtyClient, which posts a request
// and then blocks in Atomics.wait until the main thread responds. So
// postMessage TO this worker is never delivered after startup. File
// uploads therefore use a SharedArrayBuffer mailbox (sending side in
// gap-ui.js), drained at the top of every terminal operation — the
// moments this thread is provably awake. postMessage FROM this worker is
// the tty request channel itself, so it always works; downloads are
// pushed to the page that way.

importScripts("vendor/xterm-pty/workerTools.js");

// ---------------------------------------------------------------------
// Upload mailbox (main thread -> worker).
//
// Layout: Int32Array ctrl[4] in bytes [0,16), then a Uint8Array data
// area. ctrl[MB_STATE] is the handshake word: the main thread may only
// write a chunk when it is MB_IDLE (new session) or MB_CONSUMED (next
// chunk), and sets it to MB_READY; the worker consumes the chunk and
// sets MB_CONSUMED, or MB_IDLE after the session-closing END chunk.
//
// A session is one or more files, each sent as a HEADER chunk (JSON
// {name, size}) followed by data chunks with the last flagged FINAL,
// and is terminated by an empty END chunk. The worker consumes a whole
// session in one drainMailbox() call, blocking in Atomics.wait between
// chunks (the main thread never blocks; it polls with Atomics.waitAsync
// or setTimeout). Keep the constants in sync with gap-ui.js.

const MB_STATE = 0, MB_LEN = 1, MB_FLAGS = 2;
const MB_IDLE = 0, MB_READY = 1, MB_CONSUMED = 2;
const MB_FLAG_HEADER = 1, MB_FLAG_FINAL = 2, MB_FLAG_END = 4;
const MB_CTRL_BYTES = 16;

let mbCtrl = null;
let mbData = null;

const USER_DIR = "/home/web_user";

function drainMailbox() {
    if (mbCtrl === null || Atomics.load(mbCtrl, MB_STATE) !== MB_READY)
        return;

    let cur = null; // file in transit: { name, buf, off }
    for (;;) {
        const flags = mbCtrl[MB_FLAGS];
        const len = mbCtrl[MB_LEN];

        if (flags & MB_FLAG_END) {
            // Session closed; hand the mailbox back to the main thread.
            Atomics.store(mbCtrl, MB_STATE, MB_IDLE);
            Atomics.notify(mbCtrl, MB_STATE);
            return;
        }

        if (flags & MB_FLAG_HEADER) {
            // slice (not subarray): TextDecoder rejects views backed by
            // a SharedArrayBuffer, so decode from a non-shared copy.
            const header = JSON.parse(
                new TextDecoder().decode(mbData.slice(0, len)));
            cur = {
                name: header.name,
                buf: new Uint8Array(header.size),
                off: 0,
            };
        } else {
            cur.buf.set(mbData.subarray(0, len), cur.off);
            cur.off += len;
            if (flags & MB_FLAG_FINAL) {
                if (cur.off !== cur.buf.length)
                    throw new Error("gap-worker: upload of " + cur.name +
                        " ended at " + cur.off + " of " + cur.buf.length +
                        " bytes");
                FS.writeFile(USER_DIR + "/" + cur.name, cur.buf);
                postMessage({ type: "gap-file-uploaded", name: cur.name });
                cur = null;
            }
        }

        Atomics.store(mbCtrl, MB_STATE, MB_CONSUMED);
        Atomics.notify(mbCtrl, MB_STATE);

        // Wait for the main thread to publish the next chunk. It answers
        // within its event-loop latency; a long stall means the page side
        // died mid-transfer, and hanging GAP forever on that would be
        // worse than abandoning the upload loudly.
        while (Atomics.load(mbCtrl, MB_STATE) !== MB_READY) {
            const r = Atomics.wait(mbCtrl, MB_STATE, MB_CONSUMED, 30000);
            if (r === "timed-out") {
                console.error("gap-worker: upload stalled; abandoning transfer");
                postMessage({ type: "gap-file-error",
                              name: cur === null ? null : cur.name,
                              error: "transfer stalled" });
                Atomics.store(mbCtrl, MB_STATE, MB_IDLE);
                return;
            }
        }
    }
}

// ---------------------------------------------------------------------
// Download push (worker -> main thread).
//
// GAP starts in USER_DIR, which begins empty, so everything under it is
// user-created (or uploaded). Whenever GAP asks for terminal input —
// i.e. output has settled and any files it wrote are complete — walk the
// directory and push new/changed files to the page, which caches the
// bytes so a download click never needs the (possibly blocked) worker.
//
// No throttling: the scan before GAP blocks for input is the LAST chance
// to notice a new file (nothing re-triggers while it is blocked), so a
// time-based throttle would skip exactly the scan that matters. The walk
// is stat-only and the directory is small; files are only read (and
// posted) when size/mtime changed.

const knownFiles = new Map(); // relative path -> "size:mtime" key

function scanUserFiles() {
    const changedPaths = [];
    const seen = new Set();
    (function walk(dir, rel) {
        for (const name of FS.readdir(dir)) {
            if (name === "." || name === "..")
                continue;
            const path = dir + "/" + name;
            const st = FS.stat(path);
            const relPath = rel === "" ? name : rel + "/" + name;
            if (FS.isDir(st.mode)) {
                walk(path, relPath);
            } else if (FS.isFile(st.mode)) {
                seen.add(relPath);
                const key = st.size + ":" + st.mtime.getTime();
                if (knownFiles.get(relPath) !== key) {
                    knownFiles.set(relPath, key);
                    changedPaths.push(relPath);
                }
            }
        }
    })(USER_DIR, "");

    const removed = [];
    for (const p of knownFiles.keys()) {
        if (!seen.has(p)) {
            knownFiles.delete(p);
            removed.push(p);
        }
    }

    if (changedPaths.length === 0 && removed.length === 0)
        return;
    const changed = changedPaths.map((p) => {
        const data = FS.readFile(USER_DIR + "/" + p); // returns a fresh copy
        return { path: p, size: data.length, data: data };
    });
    postMessage({ type: "gap-user-files", changed: changed, removed: removed },
                changed.map((f) => f.data.buffer));
}

// ---------------------------------------------------------------------
// Startup. Two messages, in order: the page's gap-init (carrying the
// upload mailbox), then the tty SharedArrayBuffer that TtyServer.start()
// posts. Everything else happens inside terminal-operation hooks.

onmessage = (msg) => {
    if (msg.data && msg.data.type === "gap-init") {
        mbCtrl = new Int32Array(msg.data.mailbox, 0, 4);
        mbData = new Uint8Array(msg.data.mailbox, MB_CTRL_BYTES);
        return;
    }

    // Prepare the Module object BEFORE importing gap.js. The FS init in
    // gap-fs.js chdirs to USER_DIR, so tell GAP its root explicitly.
    self.Module = self.Module || {};
    self.Module.arguments = ["-l", "/"];
    importScripts("gap-fs.js");
    importScripts("gap.js");

    // Hook every terminal operation: drain pending uploads first (so a
    // pasted Read("file.g"); line always finds its file — the paste's
    // own keystrokes trigger the drain before GAP sees the newline), and
    // scan for new user files when GAP is asking for input.
    //
    // An exception escaping these hooks would propagate into the wasm
    // stack, where emscripten's invoke trampolines can swallow it with
    // no console output (observed with TextDecoder throwing on a shared
    // buffer) — leaving GAP dead and the failure invisible. Report
    // loudly before letting it propagate.
    const fileTransferHook = (scan) => {
        try {
            drainMailbox();
            if (scan) scanUserFiles();
        } catch (e) {
            console.error("gap-worker: file transfer hook failed:", e);
            postMessage({ type: "gap-file-error", name: null,
                          error: String(e) });
            throw e;
        }
    };
    const client = new TtyClient(msg.data);
    const hooked = Object.create(client);
    hooked.onRead = (length) => {
        fileTransferHook(true);
        return client.onRead(length);
    };
    hooked.onWaitForReadable = (timeout) => {
        fileTransferHook(true);
        return client.onWaitForReadable(timeout);
    };
    hooked.onWrite = (buf) => {
        fileTransferHook(false);
        return client.onWrite(buf);
    };
    emscriptenHack(hooked);
};
