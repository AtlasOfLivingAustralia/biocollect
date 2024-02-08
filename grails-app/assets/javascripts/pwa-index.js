async function downloadMapTiles(bounds, tileUrl, minZoom, maxZoom, callback) {
    minZoom = minZoom || 0;  // Minimum zoom level
    maxZoom = maxZoom || 20; // Maximum zoom level
    const MAX_PARALLEL_REQUESTS = 10;

    var deferred = $.Deferred(), requestArray = [];
    // Check if the browser supports the Cache API
    if ('caches' in window) {
        // Function to fetch and cache the vector basemap tiles for a bounding box at different zoom levels
        try {
            // Loop through each zoom level
            for (let zoom = minZoom; zoom <= maxZoom; zoom++) {
                // Loop through the tiles within the bounding box at the current zoom level
                var coordinates = getTileCoordinatesForBoundsAtZoom(bounds, zoom),
                    xMin = coordinates[0][0],
                    xMax = coordinates[1][0],
                    yMin = coordinates[0][1],
                    yMax = coordinates[1][1];

                for (let x = xMin; x <= xMax; x++) {
                    for (let y = yMin; y <= yMax; y++) {
                        try {
                            const requestUrl = tileUrl.replace('{z}', zoom).replace('{x}', x).replace('{y}', y);

                            // Open the cache
                            const cache = await caches.open(cacheName);

                            // Check if the tile is already cached
                            const cachedResponse = await cache.match(requestUrl);

                            if (!cachedResponse) {
                                console.log(`Tile at zoom ${zoom}, x ${x}, y ${y} not found in cache. Fetching and caching...`);

                                // run x number of queries in parallel
                                if (requestArray.length <= MAX_PARALLEL_REQUESTS) {
                                    requestArray.push(fetch(requestUrl).then(function (response) {
                                        // Clone the response, as it can only be consumed once
                                        const responseClone = response.clone();

                                        // Cache the response
                                        cache.put(requestUrl, responseClone);
                                    }));
                                } else {
                                    await Promise.all(requestArray);
                                    requestArray = [];
                                }

                                console.log(`Tile at zoom ${zoom}, x ${x}, y ${y} cached.`);
                            } else {
                                console.log(`Tile at zoom ${zoom}, x ${x}, y ${y} found in cache.`);
                            }
                        } catch (e) {
                            console.error("Error fetching tiles" + e);
                        }

                        callback && callback();
                    }
                }
            }

            if (requestArray.length > 0) {
                await Promise.all(requestArray);
            }
            console.log('Vector basemap tiles cached for the bounding box.');
            deferred.resolve();
        } catch (error) {
            console.error('Error caching vector basemap: ' + error);
            deferred.reject();
        }        // Call the function to cache the vector basemap tiles for the bounding box
    } else {
        console.log('Cache API not supported in this browser.');
        deferred.reject();
    }

    return deferred.promise();
}

async function deleteMapTiles(bounds, tileUrl, minZoom, maxZoom, callback) {
    minZoom = minZoom || 0;  // Minimum zoom level
    maxZoom = maxZoom || 20; // Maximum zoom level

    var deferred = $.Deferred();
    // Check if the browser supports the Cache API
    if ('caches' in window) {
        // Function to fetch and cache the vector basemap tiles for a bounding box at different zoom levels
        try {
            // Loop through each zoom level
            for (let zoom = minZoom; zoom <= maxZoom; zoom++) {
                // Loop through the tiles within the bounding box at the current zoom level
                var coordinates = getTileCoordinatesForBoundsAtZoom(bounds, zoom),
                    xMin = coordinates[0][0],
                    xMax = coordinates[1][0],
                    yMin = coordinates[0][1],
                    yMax = coordinates[1][1];

                for (let x = xMin; x <= xMax; x++) {
                    for (let y = yMin; y <= yMax; y++) {
                        const requestUrl = tileUrl.replace('{z}', zoom).replace('{x}', x).replace('{y}', y);

                        // Open the cache
                        const cache = await caches.open(cacheName);

                        // Check if the tile is already cached
                        await cache.delete(requestUrl);

                        callback && callback();
                    }
                }
            }

            console.log('Vector basemap tiles cached for the bounding box.');
            deferred.resolve();
        } catch (error) {
            console.error('Error caching vector basemap: ' +  error);
            deferred.reject();
        }        // Call the function to cache the vector basemap tiles for the bounding box
    } else {
        console.log('Cache API not supported in this browser.');
        deferred.reject();
    }

    return deferred.promise();
}

function getTileCoordinatesForBoundsAtZoom (bounds, zoom) {
    var nLat = bounds.getNorth(),
        sLat = bounds.getSouth(),
        wLng = bounds.getWest(),
        eLng = bounds.getEast(),
        xWest =  tileXCoordinateFromLatLng(nLat, wLng, zoom),
        xEast = tileXCoordinateFromLatLng(sLat, eLng, zoom),
        yNorth =  tileYCoordinateFromLatLng(nLat, eLng, zoom),
        ySouth = tileYCoordinateFromLatLng(sLat, wLng, zoom),
        xMin = Math.min(xWest, xEast),
        xMax = Math.max(xWest, xEast),
        yMin = Math.min(yNorth, ySouth),
        yMax = Math.max(yNorth, ySouth);

    // each zoom level should have at least 25 tiles i.e. 5 in each axis
    if ((yMax - yMin) * (xMax - xMin) < minNumberOfTilesPerZoom) {
        var xDiff = xMax - xMin,
            yDiff = yMax - yMin,
            xAddEachSide = Math.floor((maxTilesPerAxis - xDiff) / 2),
            yAddEachSide = Math.floor((maxTilesPerAxis - yDiff) / 2),
            max = Math.pow(2, zoom) - 1;

        xMin -= xAddEachSide;
        xMax += xAddEachSide;
        yMin -= yAddEachSide;
        yMax += yAddEachSide;
        xMin = xMin < 0 ? 0 : xMin;
        xMax = xMax > max ? max : xMax;
        yMin = yMin < 0 ? 0 : yMin;
        yMax = yMax > max ? max : yMax;
    }

    return [[xMin, yMin], [xMax, yMax]];
}

function totalTilesForBoundsAtZoom (bounds, zoom) {
    var coordinates = getTileCoordinatesForBoundsAtZoom(bounds, zoom),
        xMin = coordinates[0][0],
        xMax = coordinates[1][0],
        yMin = coordinates[0][1],
        yMax = coordinates[1][1];

    return (xMax - xMin + 1) * (yMax - yMin + 1);
}

function totalTilesForBounds(bounds, minZoom, maxZoom) {
    var totalTiles = 0;
    for (var zoom = minZoom; zoom <= maxZoom; zoom++) {
        totalTiles += totalTilesForBoundsAtZoom(bounds, zoom);
    }

    return totalTiles;
}

// Function to convert longitude to tile coordinate
function tileXCoordinateFromLatLng(lat, lng, zoom) {
    var latLng = L.latLng(lat, lng);
    return Math.floor(crs.latLngToPoint(latLng, zoom).x / tileSize);
}

// Function to convert latitude to tile coordinate
function tileYCoordinateFromLatLng(lat, lng, zoom) {
    var latLng = L.latLng(lat, lng);
    return Math.floor(crs.latLngToPoint(latLng, zoom).y / tileSize);
}

function OfflineViewModel(config) {
    var self = this,
        minZoom = config.minZoom || 0,
        maxZoom = config.maxZoom || 20,
        mapId = config.mapId,
        overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig(),
        mapOptions = {
            autoZIndex: false,
            zoomToObject: true,
            preserveZIndex: true,
            addLayersControlHeading: false,
            drawControl: false,
            showReset: false,
            draggableMarkers: false,
            useMyLocation: true,
            maxAutoZoom: maxZoom,
            maxZoom: maxZoom,
            minZoom: minZoom,
            allowSearchLocationByAddress: true,
            allowSearchRegionByAddress: true,
            trackWindowHeight: false,
            baseLayer: L.tileLayer(config.baseMapUrl, config.baseMapOptions),
            wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
            wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl
        },
        alaMap = new ALA.Map(mapId, mapOptions),
        mapImpl = alaMap.getMapImpl(),
        pa = null,
        project = null,
        mapSection = config.mapSection || "mapSection";

    self.stages = {metadata: 'metadata', species: 'species', map: 'map', form: 'form', sites: "sites"};
    self.statuses = {done: 'downloaded', doing: 'downloading', error: 'error', wait: 'waiting'};
    self.currentStage = ko.observable();
    self.metadataStatus = ko.observable(self.statuses.wait);
    self.speciesStatus = ko.observable(self.statuses.wait);
    self.sitesStatus = ko.observable(self.statuses.wait);
    self.mapStatus = ko.observable(self.statuses.wait);
    self.formStatus = ko.observable(self.statuses.wait);
    self.isOnline = ko.observable(true);
    self.name = ko.observable();
    self.downloading = ko.observable(false);
    self.offlineMaps = ko.observableArray([]);
    self.bounds = ko.observable(mapImpl.getBounds());
    self.areaInKmOfBounds = ko.pureComputed(function () {
        var bounds = self.bounds();
        return bounds && (area( bounds ) / Math.pow(10, 6));
    })
    self.numberOfTilesDownloaded = ko.observable(0);
    self.totalNumberOfTiles = ko.observable(1);
    self.progress = ko.observable(0);
    self.totalCount = ko.observable(1);
    self.numberOfFormsDownloaded = ko.observable(0);
    self.totalFormDownload = ko.observable(1);
    self.loadMetadata = ko.observable(false);
    self.totalSiteTilesDownload = ko.observable(1);
    self.numberOfSiteTilesDownloaded = ko.observable(0);
    self.percentageFormDownloaded = ko.pureComputed(function (){
        return Math.round(self.numberOfFormsDownloaded() / self.totalFormDownload() * 100);
    });
    self.percentageSitesDownloaded = ko.pureComputed(function (){
        return Math.round(self.numberOfSiteTilesDownloaded() / self.totalSiteTilesDownload() * 100);
    });
    self.isSurveyOfflineCapable = ko.computed(function () {
        var statuses = [self.metadataStatus(), self.formStatus(), self.speciesStatus(), self.mapStatus(), self.sitesStatus()]
        if (statuses.every(item => item === self.statuses.done)) {
            window.parent && window.parent.postMessage && window.parent.postMessage({event: "download-complete"}, "*");
        }
        else {
            window.parent && window.parent.postMessage && window.parent.postMessage({event: "download-removed"}, "*");
        }
    });

    self.canMapBeOffline = ko.pureComputed(function () {
        return self.offlineMaps().length > 0;
    });
    self.showSpeciesProgressBar = ko.pureComputed(function () {
        return self.progress() > 0;
    });
    self.downloadPercentageComplete = ko.pureComputed(function () {
        return Math.round(self.numberOfTilesDownloaded() / self.totalNumberOfTiles() * 100);
    });
    self.canDownload = ko.computed(function () {
        return !!self.name() && self.isBoundsWithinMaxArea();
    });
    self.isBoundsWithinMaxArea = ko.pureComputed(function () {
        var bounds = self.bounds();
        return area(bounds) <= maxArea;
    });

    self.speciesDownloadPercentageComplete = ko.pureComputed(function (){
       return Math.round(self.progress() / self.totalCount() * 100);
    });

    self.offlineMaps.subscribe(offlineMapCheck);
    self.currentStage.subscribe(function (stage) {
        switch (stage) {
            case self.stages.metadata:
                getProjectActivityMetadata();
                break;
            case self.stages.form:
                startDownloadingSurveyForms();
                break;
            case self.stages.species:
                startDownloadingSpecies();
                break;
            case self.stages.sites:
                startDownloadingSites();
                break;
            case self.stages.map:
                offlineMapCheck();
                break;
        }
    });

    function offlineMapCheck() {
        if (self.canMapBeOffline()) {
            self.mapStatus(self.statuses.done);
        }
        else {
            self.mapStatus(self.statuses.error);
        }
    }

    self.clickSpeciesDownload = function () {
        self.progress(0);
        self.totalCount(1);
        entities.deleteAllSpecies().then(startDownloadingSpecies);
    }

    self.clickDownload = function () {
        if (self.canDownload()) {
            var bounds = self.bounds(),
                baseMapUrl = config.baseMapUrl,
                minZoom = config.minZoom || 0;

            self.downloading(true);
            self.numberOfTilesDownloaded(0);
            self.totalNumberOfTiles(totalTilesForBounds(bounds, minZoom, maxZoom));
            downloadMapTiles(bounds, config.baseMapUrl, minZoom, maxZoom, function () {
                self.numberOfTilesDownloaded(self.numberOfTilesDownloaded() + 1);
            }).finally(function () {
                self.numberOfTilesDownloaded(0);
                self.totalNumberOfTiles(1);
                self.downloading(false);
                entities.saveMap({
                    name: self.name(),
                    bounds: self.getBoundsArray(bounds),
                    baseMapUrl: baseMapUrl
                }).then(function (result) {
                    self.getOfflineMaps();
                });
            });
        }
    }

    self.getOfflineMaps = function () {
        entities.getMaps().then(function (result) {
            var maps = result.data;
            self.offlineMaps(maps);
        });
    }

    self.getBoundsArray = function (bounds) {
        return [{lat: bounds.getNorth(), lng:bounds.getWest()}, {lat: bounds.getSouth(), lng:bounds.getEast()}];
    }

    self.getBoundsFromArray = function (boundsArray) {
        var nw = L.latLng(boundsArray[0]),
            se = L.latLng(boundsArray[1]);

        return L.latLngBounds(nw, se);
    }

    self.preview = function (data) {
        var data = this,
            boundsArray = data.bounds,
            bounds = self.getBoundsFromArray(boundsArray);

        bounds && mapImpl.fitBounds(bounds);
    }

    self.removeMe = function () {
        var data = this,
            boundsArray = data.bounds,
            bounds = self.getBoundsFromArray(boundsArray),
            minZoom = 14;

        if (data && data.id) {
            deleteMapTiles(bounds, data.baseMapUrl).finally(function () {
                entities.deleteMap(data.id).then(function (){
                    self.offlineMaps.remove(data);
                });
            });
        }
    }

    self.scrollToMapSection = function () {
        var offset = $("#" + mapSection).offset();

        if (offset) {
            $("html, body").animate({
                scrollTop: offset.top + 'px'
            });
        }
    }

    function area(bounds) {
        var pt1 = new L.LatLng(bounds.getNorth(), bounds.getWest()),
            pt2 = new L.LatLng(bounds.getNorth(), bounds.getEast()),
            pt3 = new L.LatLng(bounds.getSouth(), bounds.getEast()),
            pt4 = new L.LatLng(bounds.getSouth(), bounds.getWest()),
            area = pt1.distanceTo(pt2) * pt3.distanceTo(pt4);

        console.log(area);
        return area;
    }

    /**
     * Downloads base map tiles and wms layer of a site for offline use.
     * It is done for all sites of a project activity.
     * @returns {Promise<void>}
     */
    async function startDownloadingSites() {
        const TIMEOUT = 3000, // 3 seconds
            MAP_LOAD_TIMEOUT = 1000, // 1 seconds
            MAX_ZOOM=20,
            MIN_ZOOM= 10;
        var sites = pa.sites || [], zoom = 15, mapZoomedInIndicator, tileLoadedPromise, cancelTimer,
            callback = function () {
                cancelTimer && clearTimeout(cancelTimer);
                cancelTimer = null;
                // resolve it in the next event loop
                if(mapZoomedInIndicator && mapZoomedInIndicator.state() == 'pending') {
                    // setTimeout(function () {
                        mapZoomedInIndicator && mapZoomedInIndicator.resolve();
                    // }, 0);
                }
            };
        self.currentStage(self.stages.sites);
        self.sitesStatus(self.statuses.doing);
        alaMap.registerListener('dataload', callback);

        try {
            self.numberOfSiteTilesDownloaded(0);
            self.totalSiteTilesDownload(sites.length);
            for (var i = 0; i < sites.length; i++) {
                var site = sites[i],
                    geoJson = Biocollect.MapUtilities.featureToValidGeoJson(site.extent.geometry),
                    geoJsonLayer = alaMap.setGeoJSON(geoJson, {
                        wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                        wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl,
                        maxZoom: MAX_ZOOM
                    });

                // so that layer zooms beyond default max zoom of 18
                geoJsonLayer.options.maxZoom = MAX_ZOOM;
                mapZoomedInIndicator = $.Deferred();
                // cancel waiting for map to load feature data
                cancelTimer = setTimeout(function (){
                    mapZoomedInIndicator && mapZoomedInIndicator.resolve();
                }, TIMEOUT);

                // no need to wait if promise is resolved.
                if (mapZoomedInIndicator && mapZoomedInIndicator.state() == 'pending') {
                    // wait for map layer to load feature data from spatial server for pid.
                    await mapZoomedInIndicator.promise();
                }

                // zoom into to map to get tiles and feature from spatial server
                for (zoom = MIN_ZOOM; zoom <= MAX_ZOOM; zoom++) {
                    tileLoadedPromise = $.Deferred();
                    mapImpl.setZoom(zoom, {animate: false});
                    timer(MAP_LOAD_TIMEOUT, tileLoadedPromise);
                    await tileLoadedPromise.promise();
                }

                alaMap.clearLayers();
                self.numberOfSiteTilesDownloaded(self.numberOfSiteTilesDownloaded() + 1);
            }

            alaMap.removeListener('dataload', callback);
            completedSitesDownload();
        } catch (e) {
            console.error(e);
            errorSitesDownload();
        }
    }

    function timer(ms, deferred) {
        return setTimeout(deferred.resolve, ms);
    }

    function completedSitesDownload() {
        updateSitesProgressBar(self.totalCount(), self.totalCount());
        self.sitesStatus(self.statuses.done);
        if (self.mapStatus() != self.statuses.done) {
            self.mapStatus(self.statuses.doing);
            self.currentStage(self.stages.map);
        }
    }

    function errorSitesDownload() {
        self.sitesStatus(self.statuses.error);
        showReloadPrompt();
    }

    function startDownloadingSpecies() {
        self.currentStage(self.stages.species);
        self.speciesStatus(self.statuses.doing);
        entities.getSpeciesForProjectActivity(pa, updateSpeciesProgressBar).then(completedSpeciesDownload, errorSpeciesDownload);
    }

    function updateSitesProgressBar (total, count) {
        self.totalCount(total);
        self.progress(count);
    }

    function completedSpeciesDownload() {
        updateSpeciesProgressBar(self.totalCount(), self.totalCount());
        self.speciesStatus(self.statuses.done);
        self.sitesStatus(self.statuses.doing);
        self.currentStage(self.stages.sites);
    }

    function errorSpeciesDownload() {
        self.speciesStatus(self.statuses.error);
        showReloadPrompt();
    }

    function updateSpeciesProgressBar (total, count) {
        self.totalCount(total);
        self.progress(count);
    }

    function startDownloadingSurveyForms() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.getRegistration().then( function (){
                self.formStatus(self.statuses.doing);
                downloadProjectActivityArtefacts(self).then(completedFormDownload, errorFormDownload);
            }, errorFormDownload);
        }
        else {
            errorFormDownload();
        }
    }

    function completedFormDownload() {
        self.formStatus(self.statuses.done);
        self.currentStage(self.stages.species);
        self.speciesStatus(self.statuses.doing);
    }

    function errorFormDownload() {
        self.formStatus(self.statuses.error);
        showReloadPrompt();
    }

    function showReloadPrompt () {
        bootbox.confirm({
            title: 'Failed to take survey offline',
            message: 'Encountered an error while taking survey offline. Click reload to try again. Contact administrator if problem persists.',
            buttons: {
                cancel: {
                    label: '<i class="far fa-times-circle"></i> Cancel'
                },
                confirm: {
                    label: '<i class="fas fa-sync"></i> Reload'
                }
            },
            callback: function (result) {
                if (result) {
                    window.location.reload();
                }
            }
        });
    }

    function getProjectActivityMetadata() {
        self.metadataStatus(self.statuses.doing);
        return entities.getProjectActivityMetadata(config.projectActivityId, undefined).then(function (result) {
            var data = result.data,
                deferred = $.Deferred();
            pa = data.pActivity;
            project = data.project;
            entities.saveSites(pa.sites).then(completedMetadataDownload, errorMetadataDownload);
            return deferred.promise();
        });
    }

    function completedMetadataDownload() {
        self.metadataStatus(self.statuses.done);
        self.currentStage(self.stages.form);
        self.formStatus(self.statuses.doing);
    }

    function errorMetadataDownload() {
        self.metadataStatus(self.statuses.error);
        showReloadPrompt();
    }

    if (!config.doNotInit) {
        (function init() {
            alaMap.registerListener('zoomend', function () {
                self.bounds(mapImpl.getBounds());
            })

            self.getOfflineMaps();
            self.currentStage(self.stages.metadata);
        })();
    }
}


function downloadProjectActivityArtefacts(viewModel) {
    var IFRAME_ID = 'form-content',
        iframeWindow,
        delay = 4 * 60 * 1000, // four minutes
        deferred = $.Deferred();

    var urls = [fcConfig.createActivityUrl, fcConfig.indexActivityUrl, fcConfig.offlineListUrl, fcConfig.settingsUrl],
        urlsIndex = 0;

    document.addEventListener('view-model-loaded',function () {
        increaseFormDownloadedCount();
        ++urlsIndex;
        loadIframe();
    });

    function loadIframe () {
        if (urlsIndex < urls.length) {
            var url = urls[urlsIndex],
                iframe = document.getElementById(IFRAME_ID);
            iframe.src = url;
            iframeWindow = iframe.contentWindow;
            rejectPromiseIfErrorLoadingPage(urlsIndex);
            increaseFormDownloadedCount();
        } else {
            console.info("Finished downloading artefacts!");
            deferred.resolve();
        }
    }

    function increaseFormDownloadedCount () {
        viewModel.numberOfFormsDownloaded(viewModel.numberOfFormsDownloaded() + 1);
    }

    function rejectPromiseIfErrorLoadingPage (index) {
        setTimeout(function () {
            if (index == urlsIndex) {
                deferred.reject();
            }
        }, delay);
    }

    function init(){
        viewModel.totalFormDownload(urls.length * 2);
        viewModel.numberOfFormsDownloaded(0);
        loadIframe();
    }

    init();
    return deferred.promise();
};