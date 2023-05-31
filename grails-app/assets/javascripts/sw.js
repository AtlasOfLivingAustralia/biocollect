const cacheName = "v3"
const fcConfig = {
    pathsToIgnoreCache: ["/image/upload", "/ws/attachment/upload"]
}
self.addEventListener('install', e => {
    console.log("SW: Install");
});

self.addEventListener('activate', e => {
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
                            // Add response to cache
                            cache.put(path, resClone);
                        }
                    });
                }

                return res;
            })
            .catch(err => {
                var path = getPath(e.request.url);
                return caches.match(path).then(res => {
                    return res;
                });
            })
    );
});

function getPath(url) {
    return new URL(url).pathname;
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