importScripts("https://cdn.jsdelivr.net/npm/xterm-pty@0.9.4/workerTools.js");

onmessage = (msg) => {
  // We wrap the initialization in an async function to handle the data fetching
  async function loadAndStart() {
    const buffers = [];
    let i = 1;

    // Download all split parts
    // It will look for gap.data.part1, part2, etc. until it hits a 404.
    while (true) {
      const url = location.origin + `/gap.data.part${i}`;
      try {
        const response = await fetch(url);
        if (!response.ok) break; // Stop when we hit 404
        
        const buf = await response.arrayBuffer();
        buffers.push(new Uint8Array(buf));
        i++;
      } catch (e) {
        break;
      }
    }

    // Prepare the Module object BEFORE importing gap.js
    self.Module = self.Module || {};

    // Merge data.
    if (buffers.length > 0) {
      const totalLength = buffers.reduce((acc, b) => acc + b.length, 0);
      const mergedData = new Uint8Array(totalLength);
      let offset = 0;
      for (const buffer of buffers) {
        mergedData.set(buffer, offset);
        offset += buffer.length;
      }

      console.log(`Worker: Loaded ${buffers.length} parts. Total size: ${totalLength} bytes.`);

      // Override the default downloader.
      // When gap.js asks for 'gap.data', we give it our merged array immediately.
      // This stops it from trying to fetch 'gap.data' via XHR.
      self.Module.getPreloadedPackage = function(remotePackageName, remotePackageSize) {
        if (remotePackageName === 'gap.data') {
          return mergedData.buffer; 
        }
        return null; // Let other files download normally if any
      };

      // Just in case: also write it to FS in preRun.
      self.Module.preRun = self.Module.preRun || [];
      self.Module.preRun.push(() => {
         try {

             FS.writeFile('/gap.data', mergedData); 
         } catch(e) { /* ignore if already handled by getPreloadedPackage */ }
      });
    } else {
      console.warn("Worker: No gap.data parts found. The standard downloader will likely fail with 404.");
    }

    // Load GAP.
    importScripts(location.origin + "/gap.js");

    emscriptenHack(new TtyClient(msg.data));
  }

  loadAndStart();
};