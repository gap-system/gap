# issue: 
# line.strip() will also remove trailing spaces
# path.replace('"', '\\"') will break if the filename contains the backslash
# Fortunately, there are no files in the directories pkg lib grp tst doc hpcgap dev benchmark 
# whose filenames contains spaces, invisible symbols or backslash.

import sys
import hashlib
import os

def main():
    seen_hashes = {}
    mappings = []

    for line in sys.stdin:
        path = line.strip()
        if not path:
            continue

        h = hashlib.md5(path.encode('utf-8')).hexdigest()
        _, ext = os.path.splitext(path)
        hashed_name = f"{h}{ext}"

        if hashed_name in seen_hashes:
            print("\nError: Hash collision detected!", file=sys.stderr)
            print(f"File 1: {seen_hashes[hashed_name]}", file=sys.stderr)
            print(f"File 2: {path}", file=sys.stderr)
            sys.exit(1)

        seen_hashes[hashed_name] = path
        mappings.append((path, hashed_name))

    try:
        with open('lazy_fs.js', 'w', encoding='utf-8') as f:
            f.write("Module.preRun = Module.preRun || [];\n")
            f.write("Module.preRun.push(function() {\n")
            f.write("    var fileMap = {\n")
            
            for path, hashed_name in mappings:
                safe_path = path.replace('"', '\\"')
                f.write(f'        "{safe_path}": "{hashed_name}",\n')
            
            f.write("    };\n\n")
            f.write("    var createdDirs = {};\n")
            f.write('    var physicalDir = "assets/";\n\n')
            
            f.write("    Object.keys(fileMap).forEach(function(virtualPath) {\n")
            f.write("        var physicalName = fileMap[virtualPath];\n")
            f.write("        var parts = virtualPath.split('/');\n")
            f.write("        var fileName = parts.pop();\n")
            f.write("        var parentDir = '/' + parts.join('/');\n\n")
            
            f.write("        if (!createdDirs[parentDir]) {\n")
            f.write("            try { FS.mkdirTree(parentDir); } catch(e) {}\n")
            f.write("            createdDirs[parentDir] = true;\n")
            f.write("        }\n\n")
            
            f.write("        FS.createLazyFile(parentDir, fileName, physicalDir + physicalName, true, false);\n")
            f.write("    });\n")
            f.write("});\n")
            
        print(f"Successfully mapped {len(mappings)} files into lazy_fs.js", file=sys.stderr)
    
    except Exception as e:
        print(f"Failed to write lazy_fs.js: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()