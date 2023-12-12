console.debug("SW Script: start reading");
importScripts("/pwa/config.js");
self.addEventListener('install', e => {
    // activate SW immediately. This avoids the need to close pages controlled by old SW.
    self.skipWaiting();
    // Remove unwanted caches
    e.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cache => {
                    if (pwaConfig.oldCacheToDelete === cache) {
                        console.log('Service Worker: Clearing Old Cache');
                        return caches.delete(cache);
                    }
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
                        var path = getPath(e.request.url);
                        if (!ignoreCachingForPath(path)) {
                            path = getCachePath(e.request.url);
                            cache.put(path, resClone);
                        }
                    });
                }

                return res;
            })
            .catch(err => {
                var path = getPath(e.request.url);
                if (!ignoreCachingForPath(path)) {
                    path = getCachePath(e.request.url);
                    return caches.match(path).then(res => {
                        if (res) {
                            return res;
                        }
                        else if (isFetchingBaseMap(e.request.url)) {
                            return  fetch(pwaConfig.noCacheTileFile);
                        }
                    });
                }

                return err;
            })
    );
});
console.debug("SW Script: completed registering listeners");
function getPath(url) {
    return new URL(url).pathname;
}

function getCachePath(url) {
    var path =  new URL(url).pathname;
    for (var i in pwaConfig.cachePathForRequestsStartingWith) {
        var cachePath = pwaConfig.cachePathForRequestsStartingWith[i];
        if (path.indexOf(cachePath) === 0) {
            return path;
        }
    }

    return url;
}

function ignoreCachingForPath(urlPath) {
    for (var i in pwaConfig.pathsToIgnoreCache) {
        var path = pwaConfig.pathsToIgnoreCache[i];
        if (urlPath.indexOf(path) == 0) {
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
    return cache.addAll(pwaConfig.filesToPreCache);
}
console.debug("SW Script: end reading");