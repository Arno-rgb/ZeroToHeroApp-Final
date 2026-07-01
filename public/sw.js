const cacheName = 'coach-demo-v4';
const cacheablePaths = new Set(['/manifest.webmanifest', '/images/logo.png']);

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(cacheName).then(cache => cache.addAll([...cacheablePaths]))
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches
      .keys()
      .then(keys => {
        const oldCacheKeys = keys.filter(key => key.startsWith('coach-demo-') && key !== cacheName);
        return Promise.all(oldCacheKeys.map(key => caches.delete(key))).then(() => oldCacheKeys.length > 0);
      })
      .then(deletedOldCaches => {
        return self.clients.claim().then(() => deletedOldCaches);
      })
      .then(deletedOldCaches => {
        if (!deletedOldCaches) {
          return undefined;
        }

        return self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(clients => {
          clients.forEach(client => {
            client.navigate(client.url);
          });
        });
      })
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET' || new URL(event.request.url).origin !== self.location.origin) {
    return;
  }

  if (event.request.mode === 'navigate') {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then(response => {
        if (response.ok && cacheablePaths.has(new URL(event.request.url).pathname)) {
          const copy = response.clone();
          caches.open(cacheName).then(cache => cache.put(event.request, copy));
        }
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
