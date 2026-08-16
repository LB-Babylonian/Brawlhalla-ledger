#!/usr/bin/env python3
"""
Static file server for Brawl Ledger, listening on IPv4 *and* IPv6.

`python3 -m http.server` binds IPv4 only. Bonjour publishes both an A and an
AAAA record for a Mac's `.local` name, and iOS will happily pick the IPv6 one —
which an IPv4-only server never answers, so the phone just times out. Binding a
dual-stack socket (AF_INET6 with IPV6_V6ONLY off) accepts both.

Usage:  ./serve.py [port]        default 8000
"""
import http.server
import os
import socket
import socketserver
import sys


class DualStackServer(socketserver.TCPServer):
    address_family = socket.AF_INET6
    allow_reuse_address = True
    daemon_threads = True

    def server_bind(self):
        # Off = accept IPv4-mapped connections on the same socket.
        try:
            self.socket.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
        except (AttributeError, OSError):
            pass  # kernel without dual-stack support; IPv6-only is still better than crashing
        super().server_bind()


class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass  # start.sh owns the console


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    try:
        with DualStackServer(("::", port), Handler) as httpd:
            httpd.serve_forever()
    except OSError as e:
        print(f"  Could not bind port {port}: {e}", file=sys.stderr)
        print(f"  Something else may be using it — try: pkill -f serve.py", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n  Stopped.")


if __name__ == "__main__":
    main()
