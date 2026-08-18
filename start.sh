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
pkill -f "serve.py $PORT" 2>/dev/null; pkill -f "http.server $PORT" 2>/dev/null; sleep 1

# Your matches are stored per-address by the browser, so a new IP looks like an empty
# app. Warn loudly rather than letting that be discovered mid-session.
LAST=".last-ip"
if [ -n "$IP" ] && [ -f "$LAST" ] && [ "$(cat "$LAST")" != "$IP" ]; then
  echo
  echo "  ############################################################"
  echo "  #  WARNING: this Mac's IP changed"
  echo "  #    was:  $(cat "$LAST")"
  echo "  #    now:  $IP"
  echo "  #"
  echo "  #  Matches logged at the OLD address will not appear at the"
  echo "  #  new one. They are not deleted — the browser files them"
  echo "  #  per-address. To get them back, put this Mac back on the"
  echo "  #  old IP (System Settings > Network > Wi-Fi > Details >"
  echo "  #  TCP/IP > 'Using DHCP with manual address'), reopen the"
  echo "  #  old URL on the phone, and Data > Export JSON."
  echo "  ############################################################"
fi
[ -n "$IP" ] && printf '%s' "$IP" > "$LAST"

echo
echo "  Brawl Ledger is running."
echo
[ -n "$IP" ]   && echo "    On your phone: http://$IP:$PORT"
[ -n "$NAME" ] && echo "    Or by name   : http://$NAME.local:$PORT"
echo "    On this Mac  : http://localhost:$PORT"
echo
echo "    Matches are stored per-address, so pick one and stick to it."
echo "    The IP is the reliable one; the .local name survives IP changes"
echo "    if your phone resolves it. Export from Data before switching."
echo
echo "  Same wifi, and the Mac has to stay awake. Press Ctrl-C to stop."
echo

python3 "$(dirname "$0")/serve.py" "$PORT"
