#!/usr/bin/env python3
"""Serve the current directory with the COOP/COEP headers required by
xterm-pty's SharedArrayBuffer usage. Run from the assembled web-example/
(or any directory containing the gap.* artifacts).

    ./serve.py            # listens on 8080
    ./serve.py 9000       # listens on 9000
"""

from __future__ import annotations

import http.server
import socketserver
import sys


class CrossOriginIsolatedHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        # Without this, browsers cache the UI files heuristically and
        # edits to web-example/ don't show up on reload.
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    with socketserver.TCPServer(("", port), CrossOriginIsolatedHandler) as httpd:
        print(f"Serving on http://localhost:{port}/  (Ctrl-C to stop)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print()


if __name__ == "__main__":
    main()
