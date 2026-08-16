#!/usr/bin/env bash
#
# Downloads every legend portrait into assets/legends/.
#
# The legend table in index.html is the single source of truth — this script
# reads it, so adding a legend there is the only edit you ever need to make.
#
# The wiki rate-limits bursts (HTTP 429), hence the throttling and backoff.
# Portraits already on disk are skipped, so re-running after a new legend
# ships only fetches the new one.
#
# Usage:  ./fetch-legends.sh          fetch what's missing
#         ./fetch-legends.sh --force  re-fetch everything
#
set -uo pipefail

cd "$(dirname "$0")"
SRC="https://brawlhalla.wiki.gg/images"
OUT="assets/legends"
FORCE=${1:-}

mkdir -p "$OUT"

table=$(grep -oE '\{n:"[^"]*",k:"[a-z0-9]+",r:"[^"]+"\}' index.html \
        | sed -E 's/.*k:"([^"]+)",r:"([^"]+)".*/\1\t\2/')

if [ -z "$table" ]; then
  echo "Could not find the legend table in index.html — aborting." >&2
  exit 1
fi

total=$(printf '%s\n' "$table" | wc -l | tr -d ' ')
got=0; skipped=0; missing=()

echo "Fetching $total legend portraits into $OUT/"

while IFS=$'\t' read -r key remote; do
  dest="$OUT/$key.png"

  if [ -s "$dest" ] && [ "$FORCE" != "--force" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  ok=0
  for attempt in 1 2 3 4; do
    code=$(curl -sS -w '%{http_code}' -o "$dest.part" "$SRC/$remote" || echo 000)
    if [ "$code" = "200" ]; then
      mv "$dest.part" "$dest"; ok=1; break
    fi
    rm -f "$dest.part"
    # 429 = rate limited; back off and try again
    sleep $((attempt * 5))
  done

  if [ "$ok" = "1" ]; then
    got=$((got + 1)); printf '  ✓ %s\n' "$key"
  else
    missing+=("$key"); printf '  ✗ %s (%s → HTTP %s)\n' "$key" "$remote" "$code"
  fi

  sleep 1.2   # stay under the wiki's burst limit
done <<< "$table"

echo
echo "Downloaded $got · already present $skipped · failed ${#missing[@]}"
if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing: ${missing[*]}"
  echo "The app falls back to a coloured crest for these, so it still works."
  echo "Re-run the script later, or drop a square PNG at $OUT/<key>.png yourself."
fi
