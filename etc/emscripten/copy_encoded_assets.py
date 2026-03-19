import sys
import urllib.parse
import os
import shutil

def main():

    dest_dir = sys.argv[1]
    os.makedirs(dest_dir, exist_ok=True)
    
    copied_count = 0

    for line in sys.stdin:
        path = line.strip()
        if not path:
            continue

        encoded_name = urllib.parse.quote(path, safe='/')

        dest_path = os.path.join(dest_dir, encoded_name)

        os.makedirs(os.path.dirname(dest_path), exist_ok=True)

        shutil.copy2(path, dest_path)
        copied_count += 1

    print(f"Successfully copied {copied_count} files into {dest_dir}", file=sys.stderr)

if __name__ == "__main__":
    main()