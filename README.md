# Brawl Ledger — Brawlhalla 2v2 tracker

A single-page app for tracking a 2v2 duo's matches: who played which legend, what the
score was, and who you were up against. No server, no account, no cost.

![tabs](https://img.shields.io/badge/stack-one%20HTML%20file-ffc247) ![cost](https://img.shields.io/badge/cost-%240-41d18a)

## Quick start

**Locally** — portraits are loaded with `fetch`-style relative paths, so open it through a
server rather than double-clicking the file:

```bash
cd brawlhalla-2v2-tracker
python3 -m http.server 8000
# → http://localhost:8000
```

**On your phones (recommended)** — push to a GitHub repo and turn on Pages:

1. Create a repo and push this folder.
2. *Settings → Pages → Source: Deploy from a branch → `main` / `(root)`*.
3. Open `https://<you>.github.io/<repo>/` on your phone and **Add to Home Screen**.
   It launches full-screen like a native app.

Everything is static, so GitHub Pages hosts it free forever.

## Logging a match

Tap each of the four slots to pick a legend, then tap the result. That's it — about ten
seconds. The legends stay selected after saving, because you usually replay the same comp.

**Score** is the winning team's remaining stocks. A 2v2 ends the moment one team runs out,
so the final score is always `X–0` or `0–X` — there is no `3–2`. If you play custom lobbies
with a different stock count, change it under **Data → Stocks / team**.

**"Who lost the stocks?"** is optional and appears only when you actually lost stocks. It is
the *only* per-player signal in a 2v2 (stocks are shared), so it's what powers the
**Better player** card. Skip it and everything else still works.

## What you get

| Card | Answers |
|---|---|
| Win rate · avg stock diff · streak | Are you actually good, and how convincingly |
| **Best duos** | Which pairing to lock in — ordered, so "you on Bödvar" ≠ "her on Bödvar" |
| **Better player** | Stocks lost per match, each of you |
| **Colin's / Yesmine's legends** | Each player's personal pocket picks |
| **Favourite prey** / **Nemeses** | Enemy legends you beat, and the ones to practise against |
| **Toughest enemy duos** | Enemy pairings with a winning record over you |

Every row shows its sample size, and the **Minimum matches** filter defaults to 3+ so a
single lucky game never crowns a "best" anything.

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

## Files

```
index.html         the whole app — markup, styles and logic
assets/legends/    70 legend portraits (240×240)
fetch-legends.sh   downloads/refreshes portraits from the wiki
manifest.json      makes it installable as a home-screen app
icon.svg           app icon
```

## Nice-to-haves, deliberately left out

- **Live sync between phones.** Export/import covers a duo. If manual merging gets old,
  a [Supabase](https://supabase.com) free-tier table plus ~40 lines of `fetch` would give
  you real-time sync at no cost.
- **Offline support.** Add a service worker if you want it working without signal.
- **Editing a saved match.** Delete it in History and re-log — it's faster than a form.
