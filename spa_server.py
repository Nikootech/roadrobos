import http.server
import os
import sys

class SPANavigationHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Strip query params and hash values to test if the physical file exists
        clean_path = self.path.split('?')[0].split('#')[0]
        local_path = self.translate_path(clean_path)
        
        # If it is a directory, append index.html
        if os.path.isdir(local_path):
            local_path = os.path.join(local_path, 'index.html')
            
        # If the physical file does not exist, rewrite it to /index.html
        if not os.path.exists(local_path):
            print(f"[SPA REWRITE] {self.path} -> /index.html")
            # Preserve query parameters so Flutter/Supabase can read the code param
            query = ""
            if '?' in self.path:
                query = '?' + self.path.split('?', 1)[1]
            self.path = '/index.html' + query
            
        return super().do_GET()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8082
    directory = sys.argv[2] if len(sys.argv) > 2 else 'build/web'
    
    abs_dir = os.path.abspath(directory)
    print(f"Serving SPA from {abs_dir} on port {port}...")
    
    os.chdir(abs_dir)
    
    server_address = ('', port)
    # ThreadingHTTPServer is available in Python 3.7+ and handles concurrent asset requests
    httpd = http.server.ThreadingHTTPServer(server_address, SPANavigationHandler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
        httpd.server_close()
