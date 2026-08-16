#!/usr/bin/env bash
#
# Starts the tracker on this Mac and prints the link to open on your phone.
# Stop it with Ctrl-C, or from another terminal: pkill -f http.server
#
set -uo pipefail
cd "$(dirname "$0")"

PORT=8000
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "")
NAME=$(scutil --get LocalHostName 2>/dev/null || echo "")

# Free the port if a previous run is still holding it.
pkill -f "http.server $PORT" 2>/dev/null && sleep 1

echo
echo "  Brawl Ledger is running."
echo
if [ -n "$NAME" ]; then
  echo "    On your phone: http://$NAME.local:$PORT"
  echo
  echo "    ^ Use this one. Your matches are stored per-address, and this name"
  echo "      stays the same even when the router hands out a different IP."
else
  echo "    On your phone: http://${IP:-?}:$PORT"
fi
echo
echo "    On this Mac  : http://localhost:$PORT"
[ -n "$IP" ] && echo "    By IP        : http://$IP:$PORT   (changes over time — avoid)"
echo
echo "  Same wifi, and the Mac has to stay awake. Press Ctrl-C to stop."
echo

python3 -m http.server "$PORT" --bind 0.0.0.0 >/dev/null 2>&1
