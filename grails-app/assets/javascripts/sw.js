console.debug("SW Script: start reading");
importScripts("/pwa/config.js");
self.addEventListener('install', e => {
    // activate SW immediately. This avoids the need to close pages controlled by old SW.
    self.skipWaiting();
    // Remove unwanted caches
    e.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.filter(cache => pwaConfig.oldCacheToDelete === cache).map(cache => {
                    console.log('Service Worker: Clearing Old Cache');
                    return caches.delete(cache);
                })
            );
        })
    );

    e.waitUntil(precache());
    console.log("SW: Install");
});
self.addEventListener('activate', e => {
    e.waitUntil(self.clients.claim());
    console.log("SW: Activated");
});

self.addEventListener('fetch', e => {
    console.log('Service Worker: Fetching');
    e.respondWith(
        fetch(e.request)
            .then(res => {
                // Make copy/clone of response
                const resClone = res.clone();
                // Open cache
                if (res.ok) {
                    caches.open(pwaConfig.cacheName).then(cache => {
                        let path = getPath(e.request.url);
                        if (!ignoreCachingForPath(path)) {
                            path = getCachePath(e.request.url);
                            cache.put(path, resClone);
                        }
                    });
                }

                return res;
            })
            .catch(() => {
                let path = getPath(e.request.url);
                if (!ignoreCachingForPath(path)) {
                    path = getCachePath(e.request.url);
                    return caches.match(path).then(res => {
                        if (res) {
                            return res;
                        }
                        else if (isFetchingBaseMap(e.request.url)) {
                            return caches.match(pwaConfig.noCacheTileFile).then(res => {
                                if (res) {
                                    return res;
                                }

                                return Response.error();
                            });
                        }

                        return Response.error();
                    });
                }

                return Response.error();
            })
    );
});
console.debug("SW Script: completed registering listeners");
function getPath(url) {
    return new URL(url).pathname;
}

function getCachePath(url) {
    const path =  new URL(url).pathname;
    for (const i in pwaConfig.cachePathForRequestsStartingWith) {
        const cachePath = pwaConfig.cachePathForRequestsStartingWith[i];
        if (path.indexOf(cachePath) === 0) {
            return path;
        }
    }

    return url;
}

function ignoreCachingForPath(urlPath) {
    for (const i in pwaConfig.pathsToIgnoreCache) {
        const path = pwaConfig.pathsToIgnoreCache[i];
        if (urlPath.indexOf(path) === 0) {
            return true;
        }
    }

    return false;
}

function isFetchingBaseMap (url) {
    return url.indexOf(pwaConfig.baseMapPrefixUrl) === 0;
}

async function precache() {
    const cache = await caches.open(pwaConfig.cacheName);
    const files = pwaConfig.filesToPreCache || [];

    for (let i = 0; i < files.length; i++) {
        await cache.delete(files[i]);
    }

    // Prefer per-URL caching over addAll: one 404 must not fail the whole install.
    const results = await Promise.allSettled(files.map(url => cache.add(url)));
    results.forEach((result, i) => {
        if (result.status === 'rejected') {
            console.warn('SW: Failed to precache', files[i], result.reason);
        }
    });
}
console.debug("SW Script: end reading");