self.Module = self.Module || {};
self.Module.preRun = self.Module.preRun || [];

self.Module.preRun.push(function() {
    addRunDependency('gap_fs_init');

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
                fileList.forEach(function(appPath) {
                    var parts = appPath.split('/');
                    parts.pop();
                    var parentDir = '/' + parts.join('/');
                    try { FS.mkdirTree('/gap_idb_cache' + parentDir); } catch(e) {}
                });

                var needsSave = false;
                var startupSet = new Set();

                try {
                    const manifestRes = await fetch('startup_manifest.json');
                    if (manifestRes.ok) {
                        const manifest = await manifestRes.json();
                        manifest.forEach(p => {
                            if (p.startsWith('/')) p = p.substring(1);
                            startupSet.add(p);
                        });
                    }
                } catch (e) {}

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
                            try {
                                const response = await fetch(fetchPath);
                                if (response.ok) {
                                    const buffer = await response.arrayBuffer();
                                    const data = new Uint8Array(buffer);
                                    FS.writeFile(finalAppPath, data);
                                    FS.writeFile(idbfsPath, data);
                                    needsSave = true;
                                }
                            } catch (fetchErr) {}
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