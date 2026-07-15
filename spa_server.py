import os
import sys
import http.server
import socketserver

PORT = 8081
DIRECTORY = "build/web"

class SPABuildHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Clean path to look for real file
        path = self.translate_path(self.path)
        
        # If the file or directory does not exist, and it doesn't have an extension like (.js, .css, .png etc.)
        # fallback to index.html for SPA routing
        if not os.path.exists(path) and '.' not in os.path.basename(path.split('?')[0]):
            self.path = "/index.html"
            
        return super().do_GET()

# Prevent port reuse issues
socketserver.TCPServer.allow_reuse_address = True

print(f"Starting RoadRobos SPA server on port {PORT}...")
with socketserver.TCPServer(("", PORT), SPABuildHandler) as httpd:
    print(f"SPA dev server running at: http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
        sys.exit(0)
