#!/usr/bin/env python3
"""
FOSDEM 2026 Schedule Planner Server
Automatically downloads and serves the FOSDEM schedule locally
"""

import http.server
import socketserver
import os
import urllib.request
import sys
from pathlib import Path

PORT = 8000
SCHEDULE_URL = "https://fosdem.org/2026/schedule/xml"
SCHEDULE_FILE = "schedule.xml"

class FosdemHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler to serve files with proper headers"""
    
    def end_headers(self):
        # Add CORS headers to allow local access
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Custom log format"""
        sys.stdout.write("%s - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format % args))


def download_schedule():
    """Download the FOSDEM schedule if it doesn't exist or is outdated"""
    if os.path.exists(SCHEDULE_FILE):
        # Check if file is older than 1 hour
        file_age = os.path.getmtime(SCHEDULE_FILE)
        current_time = os.path.getctime(SCHEDULE_FILE)
        import time
        age_hours = (time.time() - file_age) / 3600
        
        if age_hours < 1:
            print(f"✓ Using existing schedule file (cached {age_hours:.1f} hours ago)")
            return True
        else:
            print(f"ℹ Schedule file is {age_hours:.1f} hours old, downloading fresh copy...")
    else:
        print("⬇ Downloading FOSDEM 2026 schedule...")
    
    try:
        urllib.request.urlretrieve(SCHEDULE_URL, SCHEDULE_FILE)
        file_size = os.path.getsize(SCHEDULE_FILE) / 1024 / 1024  # MB
        print(f"✓ Downloaded schedule ({file_size:.1f} MB)")
        return True
    except Exception as e:
        print(f"✗ Failed to download schedule: {e}")
        if os.path.exists(SCHEDULE_FILE):
            print("ℹ Using existing (possibly outdated) schedule file")
            return True
        return False


def main():
    """Start the server"""
    print("=" * 60)
    print("FOSDEM 2026 Schedule Planner Server")
    print("=" * 60)
    
    # Download schedule if needed
    if not download_schedule():
        print("\n✗ Cannot start server without schedule file")
        print("  Please check your internet connection and try again")
        sys.exit(1)
    
    # Start server
    print(f"\n🚀 Starting server on port {PORT}...")
    print(f"📂 Serving files from: {os.getcwd()}")
    print(f"\n✅ Open your browser to:")
    print(f"   http://localhost:{PORT}")
    print(f"\n💡 Press Ctrl+C to stop the server\n")
    print("=" * 60)
    
    try:
        with socketserver.TCPServer(("", PORT), FosdemHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped")
        sys.exit(0)
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"\n✗ Port {PORT} is already in use")
            print(f"  Try a different port or stop the other server")
            sys.exit(1)
        raise


if __name__ == "__main__":
    main()
