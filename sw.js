/* コトバ Kotoba — Service Worker（離線快取 ＋ 自動更新）
   改過任何檔案後版本號要往上加一號，手機才會知道有新版。
   用「手機版-一鍵更新.bat」的話會自動加，不用手動改。 */
const CACHE = 'kotoba-v7';
const ASSETS = [
  './',
  './index.html',
  './bank-vocab.js',
  './bank-verb.js',
  './bank-grammar.js',
  './bank-sentence.js',
  './bank-course.js',
  './bank-kana.js',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).catch(() => {}));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('message', e => {
  if (e.data === 'SKIP_WAITING') self.skipWaiting();
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;
  e.respondWith(
    fetch(req)
      .then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        return res;
      })
      .catch(() => caches.match(req).then(r => r || caches.match('./index.html')))
  );
});
