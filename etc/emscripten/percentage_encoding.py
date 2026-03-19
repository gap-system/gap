import sys
import urllib.parse
import os

def main():
    mappings = []

    for line in sys.stdin:
        path = line.strip()
        if not path:
            continue

        encoded_name = urllib.parse.quote(path, safe='/')
        
        fetch_name = encoded_name.replace('%', '%25')

        mappings.append((path, fetch_name))

    try:
        with open('lazy_fs.js', 'w', encoding='utf-8') as f:
            f.write("Module.preRun = Module.preRun || [];\n")
            f.write("Module.preRun.push(function() {\n")
            f.write("    var fileMap = {\n")
            
            for path, fetch_name in mappings:
                safe_path = path.replace('"', '\\"')
                f.write(f'        "{safe_path}": "{fetch_name}",\n')
            
            f.write("    };\n\n")
            f.write('    var physicalDir = "assets/";\n')
            
            f.write("    var createdDirs = {};\n")
            f.write("    Object.keys(fileMap).forEach(function(appPath) {\n")
            f.write("        var parts = appPath.split('/');\n")
            f.write("        parts.pop();\n")
            f.write("        var parentDir = '/' + parts.join('/');\n")
            f.write("        if (!createdDirs[parentDir]) {\n")
            f.write("            try { FS.mkdirTree(parentDir); } catch(e) {}\n")
            f.write("            createdDirs[parentDir] = true;\n")
            f.write("        }\n")
            f.write("    });\n\n")
            
            f.write("    try { FS.mkdirTree('/gap_idb_cache'); } catch(e) {}\n")
            f.write("    FS.mount(IDBFS, {}, '/gap_idb_cache');\n")
            f.write("    addRunDependency('idbfs_sync');\n\n")
            
            f.write("    FS.syncfs(true, async function(err) {\n")

            f.write("        Object.keys(fileMap).forEach(function(appPath) {\n")
            f.write("            var parts = appPath.split('/');\n")
            f.write("            parts.pop();\n")
            f.write("            var parentDir = '/' + parts.join('/');\n")
            f.write("            try { FS.mkdirTree('/gap_idb_cache' + parentDir); } catch(e) {}\n")
            f.write("        });\n\n")

            f.write("        var needsSave = false;\n")
            f.write("        var startupSet = new Set();\n")

            f.write("        try {\n")
            f.write("            const manifestRes = await fetch('startup_manifest.json');\n")
            f.write("            if (manifestRes.ok) {\n")
            f.write("                const manifest = await manifestRes.json();\n")
            f.write("                manifest.forEach(p => {\n")
            f.write("                    if (p.startsWith('/')) p = p.substring(1);\n")
            f.write("                    startupSet.add(p);\n")
            f.write("                });\n")
            f.write("            }\n")
            f.write("        } catch (e) {}\n\n")

            f.write("        var fetchPromises = Object.keys(fileMap).map(async function(appPath) {\n")
            f.write("            var fetchRelativePath = fileMap[appPath];\n")
            
            f.write("            var fetchPath = physicalDir + fetchRelativePath;\n")
            f.write("            var idbfsPath = '/gap_idb_cache/' + appPath;\n")
            f.write("            var finalAppPath = '/' + appPath;\n\n")
            
            # For example, if appPath is "pkg/jupyterviz/examples/EV Charge Points.json",
            # then fetchPath is "pkg/jupyterviz/examples/EV%2520Charge%2520Points.json"

            f.write("            if (startupSet.has(fetchPath)) {\n")
            f.write("                try {\n")
            f.write("                    FS.stat(idbfsPath);\n")
            f.write("                    FS.writeFile(finalAppPath, FS.readFile(idbfsPath));\n")
            f.write("                } catch (e) {\n")
            f.write("                    try {\n")
            f.write("                        const response = await fetch(fetchPath);\n")
            f.write("                        if (response.ok) {\n")
            f.write("                            const buffer = await response.arrayBuffer();\n")
            f.write("                            const data = new Uint8Array(buffer);\n")
            f.write("                            FS.writeFile(finalAppPath, data);\n")
            f.write("                            FS.writeFile(idbfsPath, data);\n")
            f.write("                            needsSave = true;\n")
            f.write("                        }\n")
            f.write("                    } catch (fetchErr) {}\n")
            f.write("                }\n")
            f.write("            } else {\n")
            f.write("                var parts = appPath.split('/');\n")
            f.write("                var fileName = parts.pop();\n")
            f.write("                var parentDir = '/' + parts.join('/');\n")
            f.write("                FS.createLazyFile(parentDir, fileName, fetchPath, true, false);\n")
            f.write("            }\n")
            f.write("        });\n\n")
            
            f.write("        await Promise.all(fetchPromises);\n")
            f.write("        if (needsSave) {\n")
            f.write("            FS.syncfs(false, function(saveErr) {\n")
            f.write("                removeRunDependency('idbfs_sync');\n")
            f.write("            });\n")
            f.write("        } else {\n")
            f.write("            removeRunDependency('idbfs_sync');\n")
            f.write("        }\n")
            f.write("    });\n")
            f.write("});\n")
            
        print(f"Successfully encoded {len(mappings)} files into lazy_fs.js", file=sys.stderr)
    
    except Exception as e:
        print(f"Failed to write lazy_fs.js: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()