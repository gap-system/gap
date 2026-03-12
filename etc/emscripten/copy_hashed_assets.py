import sys
import hashlib
import os
import shutil

def main():
    if len(sys.argv) < 2:
        print("Error: Must provide destination directory.", file=sys.stderr)
        sys.exit(1)

    dest_dir = sys.argv[1]
    os.makedirs(dest_dir, exist_ok=True)
    
    copied_count = 0

    for line in sys.stdin:
        path = line.strip()
        if not path:
            continue

        h = hashlib.md5(path.encode('utf-8')).hexdigest()
        _, ext = os.path.splitext(path)
        hashed_name = f"{h}{ext}"

        dest_path = os.path.join(dest_dir, hashed_name)

        shutil.copy2(path, dest_path)
        copied_count += 1

    print(f"Successfully copied {copied_count} files into {dest_dir}", file=sys.stderr)

if __name__ == "__main__":
    main()