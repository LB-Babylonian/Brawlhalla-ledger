/* Brawl Ledger service worker — makes the app work with no signal.
 *
 * Strategy, deliberately split by how often each thing changes:
 *   index.html / navigations  → network-first, so a new version lands the moment
 *                               you're online again and you never get stuck on
 *                               a stale build. Falls back to cache when offline.
 *   portraits, icon, manifest → cache-first. 70 PNGs that effectively never
 *                               change; going to the network for them is waste.
 *   Google Fonts              → cache-first in their own bucket, so the display
 *                               font survives offline instead of falling back.
 *
 * The portrait list is derived from the LEGENDS array in index.html at install
 * time, so adding a legend there needs no edit here.
 *
 * Bump VERSION to force every client to re-download and re-precache.
 */
const VERSION = "v1";
const SHELL  = `brawl-ledger-shell-${VERSION}`;
const ASSETS = `brawl-ledger-assets-${VERSION}`;
const FONTS  = `brawl-ledger-fonts-${VERSION}`;
const KEEP   = [SHELL, ASSETS, FONTS];

const SHELL_FILES = ["./", "./index.html", "./manifest.json", "./icon.svg"];

/** Same regex the fetch script uses, so index.html stays the single source of truth. */
async function legendUrls(){
  try{
    const res = await fetch("./index.html", { cache: "reload" });
    if(!res.ok) return [];
    const txt  = await res.text();
    const keys = [...txt.matchAll(/k:"([a-z0-9]+)",r:"/g)].map(m => m[1]);
    return [...new Set(keys)].map(k => `./assets/legends/${k}.png`);
  }catch(e){
    return [];   // no portraits precached; runtime caching still picks them up
  }
}

self.addEventListener("install", event => {
  event.waitUntil((async () => {
    const shell = await caches.open(SHELL);
    await shell.addAll(SHELL_FILES);

    const urls = await legendUrls();
    if(urls.length){
      const bucket = await caches.open(ASSETS);
      // One missing portrait must not fail the whole install, so add individually.
      await Promise.all(urls.map(u => bucket.add(u).catch(() => {})));
    }
    await self.skipWaiting();
  })());
});

self.addEventListener("activate", event => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names
      .filter(n => n.startsWith("brawl-ledger-") && !KEEP.includes(n))
      .map(n => caches.delete(n)));
    await self.clients.claim();
  })());
});

async function cacheFirst(req, cacheName){
  const hit = await caches.match(req);
  if(hit) return hit;
  try{
    const res = await fetch(req);
    if(res && res.ok) (await caches.open(cacheName)).put(req, res.clone());
    return res;
  }catch(e){
    return Response.error();
  }
}

async function networkFirst(req, cacheName){
  try{
    const res = await fetch(req);
    if(res && res.ok) (await caches.open(cacheName)).put(req, res.clone());
    return res;
  }catch(e){
    // Offline: exact match, then the shell (hash routes share one document).
    return (await caches.match(req, { ignoreSearch: true }))
        || (await caches.match("./index.html"))
        || Response.error();
  }
}

self.addEventListener("fetch", event => {
  const req = event.request;
  if(req.method !== "GET") return;

  let url;
  try{ url = new URL(req.url); }catch(e){ return; }

  if(url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com"){
    event.respondWith(cacheFirst(req, FONTS));
    return;
  }
  if(url.origin !== self.location.origin) return;   // leave anything else alone

  if(req.mode === "navigate" || url.pathname.endsWith(".html") || url.pathname.endsWith("/")){
    event.respondWith(networkFirst(req, SHELL));
    return;
  }
  event.respondWith(cacheFirst(req, ASSETS));
});

/** Lets the Data tab report how much is actually stored. */
self.addEventListener("message", event => {
  if(event.data !== "count") return;
  event.waitUntil((async () => {
    const names = (await caches.keys()).filter(n => n.startsWith("brawl-ledger-"));
    let total = 0;
    for(const n of names) total += (await (await caches.open(n)).keys()).length;
    const reply = { type: "count", total };
    // The page sends a MessagePort; fall back to the client if it didn't.
    if(event.ports && event.ports[0]) event.ports[0].postMessage(reply);
    else if(event.source) event.source.postMessage(reply);
  })());
});
