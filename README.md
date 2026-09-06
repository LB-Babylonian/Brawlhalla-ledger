# Brawl Ledger — Brawlhalla 2v2 tracker

A single-page app for tracking Brawlhalla matches — 2v2 and 1v1, on separate ladders: who
played which legend, how many stocks each player finished with, and who you were up against.
No server, no account, no cost.

![tabs](https://img.shields.io/badge/stack-one%20HTML%20file-ffc247) ![cost](https://img.shields.io/badge/cost-%240-41d18a)

## Quick start

**Locally** — portraits load over relative paths, so serve it rather than double-clicking
the file:

```bash
./start.sh
```

That prints two links: one for this Mac, one for your phone on the same wifi. Ctrl-C stops
it. The Mac has to stay awake, and offline mode stays off over a plain wifi address —
browsers only enable it on `localhost` or real HTTPS.

**On your phones (recommended)** — push to a GitHub repo and turn on Pages:

1. Create a repo and push this folder.
2. *Settings → Pages → Source: Deploy from a branch → `main` / `(root)`*.
3. Open `https://<you>.github.io/<repo>/` on your phone and **Add to Home Screen**.
   It launches full-screen like a native app.

Everything is static, so GitHub Pages hosts it free forever.

## Two ladders: 2v2 and 1v1

The **2v2 / 1v1** switch in the header changes the whole app — logging, stats and history all
show one ladder at a time, and the two never mix. Matches logged before 1v1 existed are 2v2
by definition, so nothing needed converting.

1v1 works the same way with one legend a side, plus a **Playing as** selector, since either of
you might be laddering solo. Each of you keeps your own pre-filled legend, your own legend
stats and your own record.

That last part is why 1v1 is worth tracking separately: **Solo records** puts your two win
rates side by side, and unlike 2v2 nobody can hide behind a teammate. The ◈ average-stocks
figure is also far more meaningful here — in 2v2 it's diluted by matches your partner closed
out, whereas in 1v1 it is purely yours.

**Solo stats are never blended.** A `Solo stats for:` selector scopes the whole 1v1 view —
KPIs, legends, matchups and the header line — to one of you, defaulting to whoever is playing.
Two people with different styles meet different opponents and struggle against different
legends, so averaging your matchup records together would hide exactly the thing you'd act on.
`Combined` is there if you want it, but you have to ask for it. **Solo records** always shows
both, since comparing is its whole purpose.

## Logging a match

Pick the four legends, then tap **each player's own remaining stocks**. The result works
itself out: whichever team has more stocks left won.

In practice that's usually **two taps**. Finishing with stocks left means the other team was
wiped, so the moment you set a number above 0 for anyone, the opposing pair fills in as 0
automatically. Your teammate stays blank — that's the one number still worth asking for.

The losing side is then **locked to 0** — its other buttons are dimmed and inert, because a
team that lost was wiped. One consequence worth knowing: a **timeout**, where the clock runs
out with both teams still alive, cannot be recorded. It would save as a clean sweep instead.
Say the word if that ever matters and the lock can become an override.

The winning panel gets a slow green pulse and the losing one steps back, so the result is
readable at a glance before you hit save.

Each slot also carries your **historical record** with that legend — `6W 0L · 100%` under an
opponent means you have beaten that legend six times out of six. Green above 55%, red below
45%, gold in between. It is scoped to the current ladder, and in 1v1 to the current player,
since the two of you keep separate records.

**Your legends are pre-filled.** Petra and Sidra to start with, and after that whatever you
last played, with your own recent picks pinned at the top of the picker. Opponents get
neither — their draw is effectively random, so a "recent" list would be noise — and they
clear after every save, so you can never record the wrong enemy team by forgetting to
change it.

Recording stocks per player rather than one team score is what makes **Better player** a real
measurement instead of a guess, and it lets every legend row show how long that pick keeps
*you* alive, not just whether the team won.

Two consequences worth knowing:

- A **timeout** is handled properly — if the clock runs out at 2 stocks vs 1, that's a win,
  even though nobody hit zero.
- A **tie can't be saved**. Brawlhalla always resolves in sudden death, so equal totals mean
  a typo; the app says so rather than storing it.

Default is 3 stocks each. Change it under **Data → Stocks / player** for custom lobbies.

## What you get

| Card | Answers |
|---|---|
| Win rate · avg stock diff · streak | Are you actually good, and how convincingly |
| **Best duos** | Which pairing to lock in — ordered, so "you on Bödvar" ≠ "her on Bödvar" |
| **Better player** | Your own average stocks left, and how often each of you survives |
| **Colin's / Yesmine's legends** | Team win rate per pick, plus ◈ that player's own average stocks left — how Petra and Sidra really compare to your alternates |
| **Favourite prey** / **Nemeses** | Enemy legends you beat, and the ones to practise against |
| **Toughest enemy duos** | Enemy pairings with a winning record over you |

Every row shows its sample size, and the **Minimum matches** filter defaults to 3+ so a
single lucky game never crowns a "best" anything.

## Where your data lives — and how to not lose it

Matches are written to `localStorage` on the device that logged them. That is **on disk, not
in memory**: closing the tab, quitting the browser and restarting the Mac or phone all leave
it intact. There's no session to expire.

The catch is that browsers key that storage to the **exact address** you opened, scheme, host
and port included. These are three separate, unrelated stores of the same app:

```
http://localhost:8000              ← the Mac
http://192.168.1.208:8000          ← the phone, by IP
http://macbook-de-colin.local:8000 ← the phone, by name
```

Your router hands out that IP on a 24-hour DHCP lease. It usually renews to the same address,
but a router reboot or a stretch away from home can change it — and then the app looks
completely empty on your phone. Nothing was deleted; it's filed under an address you're no
longer visiting.

**The IP is the reliable address; the `.local` name is the stable one.** Use the name if your
phone resolves it — it survives lease changes — and fall back to the IP if it doesn't.

`.local` needs two things to work: your phone must resolve Bonjour names, and the server must
answer on whatever address family it picks. `python3 -m http.server` binds **IPv4 only**, while
Bonjour publishes both A and AAAA records, so an iPhone that chose the IPv6 address would hit
nothing at all. That's why this repo ships [`serve.py`](serve.py), which binds a dual-stack
socket. If `.local` still doesn't resolve on your phone, the durable alternative is a DHCP
reservation in your router so the IP never changes.

Three other ways storage disappears, none of them specific to this app:

- **Private / incognito tabs** discard everything on close. Use a normal tab.
- **"Clear History and Website Data"** wipes it, like any site.
- **Safari clears script storage for sites left unopened for about a week.** Playing regularly
  resets that clock, and adding it to your Home Screen helps, but it's the strongest argument
  for the export habit below.

None of this applies once it's on GitHub Pages: a fixed `https://` address never changes, so
the whole class of problem goes away.

## Two phones, one dataset

Matches live in `localStorage`, which is per-browser and per-device. To combine your logs:

**Data → Export JSON** on one phone, then **Import / merge** on the other. Merging is by
match ID, so re-importing the same file twice is safe and nothing is duplicated.

Export now and then regardless — clearing your browser data wipes `localStorage`.

## Legend portraits

All 70 portraits live in `assets/legends/<key>.png`, fetched from the
[official Brawlhalla wiki](https://brawlhalla.wiki.gg). They're already committed, so the
app works out of the box.

When a new legend ships:

1. Add a row to the `LEGENDS` array in `index.html`
   (`{n:"Name", k:"assetkey", r:"Portrait_Name.png"}`).
2. Run `./fetch-legends.sh` — it reads that array, skips what's already downloaded, and
   fetches only the new portrait. Add `--force` to re-fetch everything.

If a portrait is ever missing the app falls back to a coloured crest with the legend's
initials, so nothing breaks. You can also just drop your own square PNG at
`assets/legends/<key>.png`.

> The newest legend, Qinghua & Baobao, has no proper portrait on the wiki yet — the
> placeholder is a cropped photo. Replace `assets/legends/qinghuabaobao.png` when a real one
> appears.

Portraits are Brawlhalla artwork © Blue Mammoth Games / Ubisoft, used here for a personal,
non-commercial tracker. Don't ship this as a product.

## Offline

The app works with no signal. On first load a service worker stores `index.html`, the icon,
the display font and all 70 portraits on the device — 74 files, about 3 MB — so it opens
instantly and keeps working in airplane mode. **Data → Offline** shows how many files are
stored.

Caching is split by how often things change, so you never get stuck on a stale build:

| | Strategy |
|---|---|
| `index.html`, navigations | **Network-first** — a new version lands as soon as you're online, cache is the fallback |
| Portraits, icon, manifest | **Cache-first** — they never change, so never hit the network |
| Google Fonts | **Cache-first**, own bucket, so the display font survives offline |

The portrait list is derived from the `LEGENDS` array in `index.html` at install time, so
adding a legend needs no edit to `sw.js`.

If a new version ever refuses to appear, hit **Reset offline cache** in the Data tab (your
matches are untouched), or bump `VERSION` in [`sw.js`](sw.js) to force every device to
re-download.

> During local development the service worker will serve cached files. `python3 -m http.server`
> plus a hard reload is usually enough; otherwise use the reset button.

## Files

```
index.html         the whole app — markup, styles and logic
sw.js              service worker: offline support and precaching
assets/legends/    70 legend portraits (240×240)
start.sh           serves the app locally and prints the phone link
serve.py           dual-stack (IPv4 + IPv6) static server used by start.sh
fetch-legends.sh   downloads/refreshes portraits from the wiki
manifest.json      makes it installable as a home-screen app
icon.svg           app icon
```

## Nice-to-haves, deliberately left out

- **Live sync between phones.** Export/import covers a duo. If manual merging gets old,
  a [Supabase](https://supabase.com) free-tier table plus ~40 lines of `fetch` would give
  you real-time sync at no cost.
- **Editing a saved match.** Delete it in History and re-log — it's faster than a form.
