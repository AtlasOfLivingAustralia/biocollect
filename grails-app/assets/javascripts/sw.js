const cacheName = "v3"
const fcConfig = {
    pathsToIgnoreCache: ["/image/upload", "/ws/attachment/upload", "/ajax/keepSessionAlive", "/noop", '/pwa/sw.js'],
    cachePathForRequestsStartingWith: ["/pwa/bioActivity/edit/", "/pwa/createOrEditFragment/", "/pwa/bioActivity/index/", "/pwa/indexFragment/", "/pwa/offlineList"]
}
self.addEventListener('install', e => {
    // activate SW immediately. This avoids the need to close pages controlled by old SW.
    self.skipWaiting();
    console.log("SW: Install");
});

self.addEventListener('activate', e => {
    e.waitUntil(self.clients.claim());
    console.log("SW: Activated");
    // Remove unwanted caches
    e.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cache => {
                    if (cache !== cacheName) {
                        console.log('Service Worker: Clearing Old Cache');
                        return caches.delete(cache);
                    }
                })
            );
        })
    );

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
                    caches.open(cacheName).then(cache => {
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
                        return res;
                    });
                }

                return err;
            })
    );
});

function getPath(url) {
    return new URL(url).pathname;
}

function getCachePath(url) {
    var path =  new URL(url).pathname;
    for (var i in fcConfig.cachePathForRequestsStartingWith) {
        var cachePath = fcConfig.cachePathForRequestsStartingWith[i];
        if (path.indexOf(cachePath) === 0) {
            return path;
        }
    }

    return url;
}

function ignoreCachingForPath(urlPath) {
    for (var i in fcConfig.pathsToIgnoreCache) {
        var path = fcConfig.pathsToIgnoreCache[i];
        if (urlPath.indexOf(path) == 0) {
            return true;
        }
    }

    return false;
}