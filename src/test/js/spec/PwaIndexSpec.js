describe("PwaIndexSpec", function (){
    beforeEach(function() {
        window.tileSize = 256;
        window.crs = L.CRS.EPSG3857;
        window.minNumberOfTilesPerZoom = 25;
        window.maxTilesPerAxis = 5;
    });
    afterEach(function() {
        delete window.titleSize;
        delete window.crs;
        delete window.minNumberOfTilesPerZoom;
        delete window.maxTilesPerAxis;
    });
    describe("tileYCoordinateFromLatLng", function() {
        it("should return the correct tile coordinate for a given latitude, longitude, and zoom level", function() {
            expect(tileYCoordinateFromLatLng(0, 0, 0)).toBe(0);
            expect(tileYCoordinateFromLatLng(51, 0, 10)).toBe(342);
            expect(tileYCoordinateFromLatLng(-33, -32, 12)).toBe(2446);
            window.tileSize = 512;
            expect(tileYCoordinateFromLatLng(51, 0, 10)).toBe(171);
            expect(tileYCoordinateFromLatLng(-33, -32, 12)).toBe(1223);
        });
    });

    describe("tileXCoordinateFromLatLng", function() {
        it("should return the correct tile coordinate for a given latitude, longitude, and zoom level", function() {
            expect(tileXCoordinateFromLatLng(0, 0, 0)).toBe(0);
            expect(tileXCoordinateFromLatLng(0, 180, 10)).toBe(1024);
            expect(tileXCoordinateFromLatLng(0, -90, 10)).toBe(256);
            window.tileSize = 512;
            expect(tileXCoordinateFromLatLng(0, 180, 10)).toBe(512);
            expect(tileXCoordinateFromLatLng(0, -90, 10)).toBe(128);
        });
    });

    describe("totalTilesForBoundsAtZoom", function() {
        it("should return the correct total number of tiles for a given bounds and zoom level", function() {
            var bounds1 = L.latLngBounds(L.latLng(0, 0), L.latLng(85.0511, 180));
            expect(totalTilesForBoundsAtZoom(bounds1, 0)).toBe(1);

            var bounds2 = L.latLngBounds(L.latLng(0, 0), L.latLng(85.0511, 180));
            expect(totalTilesForBoundsAtZoom(bounds2, 10)).toBe(263169);
        });
    });

    describe("totalTilesForBounds", function() {
        it("should return the correct total number of tiles for a given bounds and range of zoom levels", function() {
            var bounds1 = L.latLngBounds(L.latLng(0, 0), L.latLng(85.0511, 180));
            expect(totalTilesForBounds(bounds1, 0, 0)).toBe(1);

            var bounds2 = L.latLngBounds(L.latLng(0, 0), L.latLng(85.0511, 180));
            expect(totalTilesForBounds(bounds2, 5, 7)).toBe(5603);
        });
    });

    describe("deleteMapTiles", function() {
        it("should delete map tiles within the specified bounds and zoom levels", async function() {
            const bounds = L.latLngBounds(L.latLng(0, 0), L.latLng(0.1, 0.1));
            const tileUrl = "https://abc.com/{Z}/{y}/{x}.png";
            const minZoom = 0;
            const maxZoom = 2;
            window.cacheName = "v1";
            const callback = jasmine.createSpy("callback");
            const fakeCache = {
                delete: async function(requestUrl) {
                    return Promise.resolve();
                }
            };
            spyOn(caches, "open").and.returnValue(fakeCache);
            await deleteMapTiles(bounds, tileUrl, minZoom, maxZoom, callback);
            expect(callback).toHaveBeenCalled();
        });
    });

    describe("downloadMapTiles", function() {
        it("should delete map tiles within the specified bounds and zoom levels", async function() {
            const bounds = L.latLngBounds(L.latLng(0, 0), L.latLng(0.1, 0.1));
            const tileUrl = "https://abc.com/{Z}/{y}/{x}.png";
            const minZoom = 0;
            const maxZoom = 2;
            window.cacheName = "v1";
            const callback = jasmine.createSpy("callback");
            const fakeCache = {
                match: async function(requestUrl) {
                    return Promise.resolve({});
                }
            };
            spyOn(caches, "open").and.returnValue(fakeCache);
            await downloadMapTiles(bounds, tileUrl, minZoom, maxZoom, callback);
            expect(callback).toHaveBeenCalled();
        });
    });

    describe("downloadProjectActivityArtefacts", function() {
        var fakeIframe;

        beforeAll(function() {
            jasmine.Ajax.install();
            // Create a fake iframe element
            fakeIframe = document.createElement("iframe");
            fakeIframe.id = "form-content";
            document.body.appendChild(fakeIframe);
        });

        afterAll(function() {
            jasmine.Ajax.uninstall();
            // Remove the fake iframe and restore original functions
            document.body.removeChild(fakeIframe);
        });

        it("should resolve the promise when all URLs are successfully loaded", async function() {
            // Mock the viewModel and fcConfig objects
            var viewModel = {
                numberOfFormsDownloaded: jasmine.createSpy("numberOfFormsDownloaded"),
                totalFormDownload: jasmine.createSpy("totalFormDownload"),
            };

            window.fcConfig = {
                createActivityUrl: "data:text/html,<html><body><p>This is a mock content 1</p></body></html>",
                indexActivityUrl: "data:text/html,<html><body><p>This is a mock content 2</p></body></html>",
                offlineListUrl: "data:text/html,<html><body><p>This is a mock content 3</p></body></html>",
            };

            var intervalId = setInterval(function() {
                var viewModelLoadedEvent = new Event('view-model-loaded');
                document.dispatchEvent(viewModelLoadedEvent);
            },1000);

            await downloadProjectActivityArtefacts(viewModel, fcConfig);
            expect(viewModel.numberOfFormsDownloaded).toHaveBeenCalled();
            expect(viewModel.totalFormDownload).toHaveBeenCalled();
            clearInterval(intervalId);
        });
    });

    describe("OfflineViewModel", function() {
        var div, viewModel, sw, fakeIframe, intervalId,
        site ={ siteId: 'site1', name: "site 1", extent: { geometry: { type: 'Point', coordinates: [ 149.12043571472168, -35.301817150253676 ] } } };

        beforeAll(function() {
            window.maxArea = 25 * 1000 * 1000;
            window.L.Google = function(){};
            window.L.Google.isGoogleMapsReady = function () {return false};
            window.ALA = {
                MapConstants : {
                    /**
                     * Types of drawing objects
                     */
                    DRAW_TYPE: {
                        POINT_TYPE: "Point",
                        CIRCLE_TYPE: "Circle",
                        POLYGON_TYPE: "Polygon",
                        LINE_TYPE: "LineString"
                    },

                    /**
                     * Types of layers
                     */
                    LAYER_TYPE: {
                        MARKER: "marker"
                    }
                },
                Map: function () {
                    return {
                        getMapImpl: function () {
                            return {
                                getZoom: function () {
                                    return 15;
                                },
                                getBounds: function () {
                                },
                                fitBounds: function () {
                                },
                                invalidateSize: function (){}
                            };
                        },
                        addLayer: function () {
                        },
                        removeLayer: function () {
                        },
                        getBounds: function () {
                        },
                        getZoom: function () {
                            return 15;
                        },
                        fitBounds: function () {
                        },
                        registerListener: function () {
                        },
                    }
                }
            };
            window.fcConfig = {
                createActivityUrl: "data:text/html,<html><body onload=\"document.dispatchEvent(new Event(\'view-model-loaded\'))\"><p>This is a mock content 1</p></body></html>",
                indexActivityUrl: "data:text/html,<html><body onload=\"document.dispatchEvent(new Event(\'view-model-loaded\'))\"><p>This is a mock content 2</p></body></html>",
                offlineListUrl: "data:text/html,<html><body onload=\"document.dispatchEvent(new Event(\'view-model-loaded\'))\"><p>This is a mock content 3</p></body></html>",
            };
        });

        beforeEach(function() {
            window.entities = {
                getSpeciesForProjectActivity: function (pa, fn) {viewModel.progress(100); viewModel.totalCount(100); return Promise.resolve({data: []})},
                getProjectActivityMetadata: function () {return Promise.resolve({data: { pActivity: { sites: [
                    site
                ] }, project: {}}})},
                saveSites: function () {return Promise.resolve({data: undefined})},
                deleteAllSpecies: function () {return Promise.resolve({data: undefined})},
                saveMap: function () {return Promise.resolve({data: undefined})},
                getMaps: function () {return Promise.resolve({data: [{id: 1, name: "test"}]})},
                deleteMap: function () {return Promise.resolve({data: undefined})},
            };

            spyOn(window.entities, "getSpeciesForProjectActivity").and.callThrough();
            spyOn(window.entities, "getProjectActivityMetadata").and.callThrough();
            spyOn(window.entities, "saveSites").and.callThrough();
            spyOn(window.entities, "deleteAllSpecies").and.callThrough();
            spyOn(window.entities, "saveMap").and.callThrough();
            spyOn(window.entities, "getMaps").and.callThrough();
            spyOn(window.entities, "deleteMap").and.callThrough();
            sw = navigator.serviceWorker.getRegistration;
            spyOn(navigator.serviceWorker, 'getRegistration').and.callFake(function () {
                intervalId = setInterval(function () {
                    var viewModelLoadedEvent = new Event('view-model-loaded');
                    document.dispatchEvent(viewModelLoadedEvent);
                }, 1000);

                return Promise.resolve({});
            });


            jasmine.Ajax.install();
            div = document.createElement("div");
            div.id = "map1";
            document.body.appendChild(div);

            fakeIframe = document.createElement("iframe");
            fakeIframe.id = "form-content";
            document.body.appendChild(fakeIframe);
        });

        afterEach(function() {
            jasmine.Ajax.uninstall();
            navigator.serviceWorker = sw;
            clearInterval(intervalId);
            document.body.removeChild(div);
            document.body.removeChild(fakeIframe);
        });

        it("should check if survey is offline capable", async function() {
            initViewModel();
            var originalPostMessage = window.parent.postMessage;
            spyOn(window.parent, 'postMessage');
            viewModel.metadataStatus(viewModel.statuses.done);
            viewModel.formStatus(viewModel.statuses.done);
            viewModel.speciesStatus(viewModel.statuses.done);
            viewModel.mapStatus(viewModel.statuses.done);
            viewModel.sitesStatus(viewModel.statuses.done);
            expect(window.parent.postMessage).toHaveBeenCalled();
            expect(window.parent.postMessage).toHaveBeenCalledTimes(5);
            expect(window.parent.postMessage).toHaveBeenCalledWith({event: "download-removed"}, "*");
            expect(window.parent.postMessage).toHaveBeenCalledWith({event: "download-complete"}, "*");
            window.parent.postMessage = originalPostMessage;
        });

        it("should automatically check if bound is within permitted area", async function() {
            initViewModel();
            viewModel.bounds(L.latLngBounds(L.latLng(-33, 150), L.latLng(-34, 151)));
            expect(viewModel.isBoundsWithinMaxArea()).toBe(false);
            expect(Number.parseInt(viewModel.areaInKmOfBounds().toString())).toBe(8615);
            viewModel.bounds(L.latLngBounds(L.latLng(-35.301817150253676, 149.12043571472168), L.latLng(-35.336693572690436, 149.08198356628418)));
            expect(viewModel.isBoundsWithinMaxArea()).toBe(true);
            expect(Number.parseInt(viewModel.areaInKmOfBounds().toString())).toBe(12);
        });

        it("should download tiles when the download button is clicked", async function() {
            initViewModel();
            viewModel.bounds(L.latLngBounds(L.latLng(-35.301817150253676, 149.12043571472168), L.latLng(-35.336693572690436, 149.08198356628418)));
            viewModel.name("Canberra");
            var originalDownloadMapTiles = downloadMapTiles;
            spyOn(window, "downloadMapTiles").and.callFake(function() {
                return Promise.resolve();
            });

            viewModel.clickDownload();

            return new Promise(function(resolve, reject) {
                setTimeout(function() {
                    expect(entities.saveMap).toHaveBeenCalledTimes(1);
                    expect(entities.getMaps).toHaveBeenCalledTimes(1);
                    expect(viewModel.downloading()).toBe(false);

                    window.downloadMapTiles = originalDownloadMapTiles;
                    resolve();
                }, 1000);
            });
        });

        it("should sequentially call appropriate function as stage changes", async function() {
            initViewModel({doNotInit: false});
            viewModel.offlineMaps([])
            spyOn(viewModel, "numberOfFormsDownloaded").and.callThrough();
            spyOn(viewModel, "totalFormDownload").and.callThrough();
            var originalDownloadMapTiles = downloadMapTiles;
            spyOn(window, "downloadMapTiles").and.callFake(function() {
                return Promise.resolve();
            });

            return new Promise(function(resolve, reject) {
                setTimeout(function() {
                    expect(entities.getProjectActivityMetadata).toHaveBeenCalledTimes(1);
                    expect(entities.getProjectActivityMetadata).toHaveBeenCalledWith("abc123", undefined);
                    expect(entities.saveSites).toHaveBeenCalledWith([site]);
                    expect(entities.saveSites).toHaveBeenCalledTimes(1);
                    expect(viewModel.numberOfFormsDownloaded).toHaveBeenCalled();
                    expect(viewModel.totalFormDownload).toHaveBeenCalled();
                    expect(entities.getSpeciesForProjectActivity).toHaveBeenCalledTimes(1);
                    expect(entities.getMaps).toHaveBeenCalledTimes(1);
                    expect(viewModel.currentStage()).toBe(viewModel.stages.sites);
                    clearInterval(intervalId);
                    window.downloadMapTiles = originalDownloadMapTiles;
                    resolve();
                }, 10000);
            });
        }, 1000000000);

        function initViewModel (config) {
            config = Object.assign({}, {
                mapId: "map1",
                baseMapUrl: "https://abc.com/{Z}/{y}/{x}.png",
                projectActivityId: 'abc123',
                totalUrl: "/totalUrl",
                downloadSpeciesUrl: "/downloadSpeciesUrl",
                doNotInit: true,
                baseMapOptions: {
                    maxZoom: 20,
                    attribution: "abc"
                }
            }, config);

            viewModel = new OfflineViewModel(config);
            return viewModel;
        }
    });
});