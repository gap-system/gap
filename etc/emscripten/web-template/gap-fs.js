// Instrument fetch and XMLHttpRequest so the page can collect the list of
// URLs the worker actually requests, for rebuilding startup_manifest.json
// without scraping the browser network panel. Each unique URL is posted
// to the main thread as { type: "gap-fetched", url: ... }.
(function instrumentFetches() {
    const seen = new Set();
    const report = (raw) => {
        if (typeof raw !== "string") return;
        if (seen.has(raw)) return;
        seen.add(raw);
        self.postMessage({ type: "gap-fetched", url: raw });
    };

    const origFetch = self.fetch;
    self.fetch = function(input, init) {
        report(typeof input === "string" ? input : input && input.url);
        return origFetch.apply(this, arguments);
    };

    const origOpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url) {
        report(url);
        return origOpen.apply(this, arguments);
    };
})();

self.Module = self.Module || {};
self.Module.preRun = self.Module.preRun || [];

self.Module.preRun.push(function() {
    addRunDependency('gap_fs_init');

    // GAP starts in /home/web_user, which stays empty here, so anything
    // under it is user-created (uploads, PrintTo output, ...). That keeps
    // user files cleanly apart from the GAP tree at /; gap-worker.js
    // passes "-l /" so GAP still finds its root.
    FS.mkdirTree('/home/web_user');
    FS.chdir('/home/web_user');

    async function initFS() {
        try {
            const mapRes = await fetch('gap-fs.json');
            const fileList = await mapRes.json();
            const physicalDir = "";

            var createdDirs = {};
            fileList.forEach(function(appPath) {
                var parts = appPath.split('/');
                parts.pop();
                var parentDir = '/' + parts.join('/');
                if (!createdDirs[parentDir]) {
                    try { FS.mkdirTree(parentDir); } catch(e) {}
                    createdDirs[parentDir] = true;
                }
            });

            try { FS.mkdirTree('/gap_idb_cache'); } catch(e) {}
            FS.mount(IDBFS, {}, '/gap_idb_cache');

            FS.syncfs(true, async function(err) {
                var needsSave = false;

                // Discard the cache when the site was redeployed: a
                // library file cached from one build must never be
                // paired with the kernel of another. build-id is
                // written by assemble-website.sh; a site without one
                // (e.g. hand-assembled) keeps its cache indefinitely.
                var storedId = null;
                try {
                    storedId = new TextDecoder().decode(
                        FS.readFile('/gap_idb_cache/.build-id'));
                } catch (e) {}
                var buildId = null;
                try {
                    const idRes = await fetch('build-id', { cache: 'no-cache' });
                    if (idRes.ok) buildId = (await idRes.text()).trim();
                } catch (e) {}
                if (buildId === null) {
                    console.info("gap-fs: no build-id served; reusing any cached files");
                } else if (storedId !== buildId) {
                    if (storedId !== null) {
                        console.info("gap-fs: site updated (" + storedId +
                            " -> " + buildId + "); discarding cached files");
                    }
                    (function wipe(dir) {
                        FS.readdir(dir).forEach(function(name) {
                            if (name === '.' || name === '..') return;
                            var p = dir + '/' + name;
                            if (FS.isDir(FS.stat(p).mode)) {
                                wipe(p);
                                FS.rmdir(p);
                            } else {
                                FS.unlink(p);
                            }
                        });
                    })('/gap_idb_cache');
                    FS.writeFile('/gap_idb_cache/.build-id', buildId);
                    needsSave = true;
                }

                fileList.forEach(function(appPath) {
                    var parts = appPath.split('/');
                    parts.pop();
                    var parentDir = '/' + parts.join('/');
                    try { FS.mkdirTree('/gap_idb_cache' + parentDir); } catch(e) {}
                });
                var startupSet = new Set();

                try {
                    const manifestRes = await fetch('startup_manifest.json');
                    if (manifestRes.ok) {
                        const manifest = await manifestRes.json();
                        manifest.forEach(p => {
                            if (p.startsWith('/')) p = p.substring(1);
                            startupSet.add(p);
                        });
                    } else {
                        console.info("startup_manifest.json not present; falling back to fully lazy loading");
                    }
                } catch (e) {
                    console.warn("Failed to load startup_manifest.json:", e);
                }

                var fetchPromises = fileList.map(async function(appPath) {
                    var fetchRelativePath = appPath.split('/').map(encodeURIComponent).join('/');
                    var fetchPath = physicalDir + fetchRelativePath;
                    
                    var idbfsPath = '/gap_idb_cache/' + appPath;
                    var finalAppPath = '/' + appPath;

                    if (startupSet.has(appPath)) { 
                        try {
                            FS.stat(idbfsPath);
                            FS.writeFile(finalAppPath, FS.readFile(idbfsPath));
                        } catch (e) {
                            const response = await fetch(fetchPath);
                            if (!response.ok) {
                                throw new Error("Failed to fetch startup file " + fetchPath + ": " + response.status);
                            }
                            const buffer = await response.arrayBuffer();
                            const data = new Uint8Array(buffer);
                            FS.writeFile(finalAppPath, data);
                            FS.writeFile(idbfsPath, data);
                            needsSave = true;
                        }
                    } else {
                        var parts = appPath.split('/');
                        var fileName = parts.pop();
                        var parentDir = '/' + parts.join('/');
                        FS.createLazyFile(parentDir, fileName, fetchPath, true, false);
                    }
                });

                await Promise.all(fetchPromises);

                if (needsSave) {
                    FS.syncfs(false, function(saveErr) {
                        removeRunDependency('gap_fs_init');
                    });
                } else {
                    removeRunDependency('gap_fs_init');
                }
            });
        } catch(err) {
            console.error("Failed to initialize GAP FS:", err);
            removeRunDependency('gap_fs_init');
        }
    }

    initFS();
});
