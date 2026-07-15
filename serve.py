"""
SPA-aware HTTP server for Flutter Web.
Serves static files normally, but falls back to index.html for any
path that doesn't map to a physical file — enabling client-side routing
(GoRouter, deep links, OAuth callbacks like /login-callback).

Usage:
    python serve.py [port]   # default port 8080
"""
import http.server
import os
import sys
import socketserver
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
DIRECTORY = Path(__file__).parent / "build" / "web"

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)

    def do_GET(self):
        # Strip query string to check physical file existence
        path_only = self.path.split("?")[0].split("#")[0]
        full_path = DIRECTORY / path_only.lstrip("/")

        if not full_path.exists():
            # Not a real file → serve index.html for SPA routing
            self.path = "/index.html"

        return super().do_GET()

    def log_message(self, format, *args):
        # Suppress noisy 200/304 access logs; only show real errors
        if args[1] not in ("200", "304"):
            super().log_message(format, *args)

    def handle_error(self, request, client_address):
        # WinError 10053 / 10054 = browser closed connection before transfer
        # completed (tab navigate/refresh). This is normal — suppress it.
        import traceback, errno
        exc = sys.exc_info()[1]
        if isinstance(exc, (ConnectionAbortedError, ConnectionResetError)):
            return  # silent — not a server bug
        if hasattr(exc, 'winerror') and exc.winerror in (10053, 10054):
            return  # silent on Windows
        super().handle_error(request, client_address)

class QuietTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

    def handle_error(self, request, client_address):
        exc = sys.exc_info()[1]
        if isinstance(exc, (ConnectionAbortedError, ConnectionResetError)):
            return
        if hasattr(exc, 'winerror') and exc.winerror in (10053, 10054):
            return
        super().handle_error(request, client_address)

with QuietTCPServer(("", PORT), SPAHandler) as httpd:
    print(f"[OK] Serving Flutter Web at http://localhost:{PORT}")
    print(f"     Root: {DIRECTORY}")
    print("     SPA routing ON — /login-callback and deep links work correctly.")
    print("     Press Ctrl+C to stop.\n")
    httpd.serve_forever()
