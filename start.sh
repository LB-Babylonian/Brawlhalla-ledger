#!/usr/bin/env bash
#
# Starts the tracker on this Mac and prints the link to open on your phone.
# Stop it with Ctrl-C, or from another terminal: pkill -f http.server
#
set -uo pipefail
cd "$(dirname "$0")"

PORT=8000
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")

# Free the port if a previous run is still holding it.
pkill -f "http.server $PORT" 2>/dev/null && sleep 1

echo
echo "  Brawl Ledger is running."
echo
echo "    On this Mac : http://localhost:$PORT"
if [ -n "$IP" ]; then
  echo "    On your phone: http://$IP:$PORT      (same wifi, Mac must stay awake)"
else
  echo "    On your phone: unavailable — no wifi connection detected"
fi
echo
echo "  Press Ctrl-C to stop."
echo

python3 -m http.server "$PORT" --bind 0.0.0.0 >/dev/null 2>&1
