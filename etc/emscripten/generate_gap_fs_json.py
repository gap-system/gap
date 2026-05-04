import sys
import json
import os

def main():
    paths = [line.strip() for line in sys.stdin if line.strip()]

    try:
        with open('gap-fs.json', 'w', encoding='utf-8') as f:
            json.dump(paths, f, separators=(',', ':'))
            
        print(f"Successfully wrote {len(paths)} files to gap-fs.json", file=sys.stderr)
    except Exception as e:
        print(f"Failed to write gap-fs.json: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
