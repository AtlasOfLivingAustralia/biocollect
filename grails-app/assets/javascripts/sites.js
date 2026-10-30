'use strict';

var SiteViewModel = function (mapContainerId, site, mapOptions) {
    var self = $.extend(this, new Documents());

    var pointOfInterestIcon = ALA.MapUtils.createIcon("https://maps.google.com/mapfiles/marker_yellow.png");
    var pointOfInterestMarkers = new L.FeatureGroup();
    var latSubscriber = null;
    var lngSubscriber = null;

    self.transients = {
        loadingGazette: ko.observable(false)
    };
    self.site = ko.observable({
        name: ko.observable(),
        siteId: ko.observable(),
        externalId: ko.observable(),
        catchment: ko.observable(),
        type: ko.observable(),
        area: ko.observable(),
        description: ko.observable(),
        notes: ko.observable(),
        projects: ko.observableArray(),
        extent: ko.observable({
            source: ko.observable(),
            geometry:  ko.observable({
                decimalLatitude: ko.observable(),
                decimalLongitude: ko.observable(),
                uncertainty: ko.observable(),
                precision: ko.observable(),
                datum: ko.observable(),

                type: ko.observable(),
                nrm: ko.observable(),
                state: ko.observable(),
                lga: ko.observable(),
                locality: ko.observable(),
                mvg: ko.observable(),
                mvs: ko.observable(),

                radius: ko.observable(),
                areaKmSq: ko.observable(),
                coordinates: ko.observable(),
                centre: ko.observable(),

                bbox: ko.observable(),
                pid: ko.observable(),
                name: ko.observable(),
                fid: ko.observable(),
                layerName: ko.observable()
            })
        })
    });
    self.pointsOfInterest = ko.observableArray();
    self.showPointAttributes = ko.observable(false);
    self.allowPointsOfInterest = ko.observable(mapOptions.allowPointsOfInterest || false);
    self.displayAreaInReadableFormat = null;
    self.geometrySummaries = ko.observableArray([]);
    self.loadedSite = site || {};
    self.originalSite = {
        extent: self.loadedSite.extent ? JSON.parse(JSON.stringify(self.loadedSite.extent)) : {source: 'none'},
        poi: self.loadedSite.poi ? JSON.parse(JSON.stringify(self.loadedSite.poi)) : [],
        features: self.loadedSite.features && self.loadedSite.features.length ? JSON.parse(JSON.stringify(self.loadedSite.features)) : null
    };
    self.originalVisibility = self.loadedSite.visibility || null;
    self.geometryDirty = false;
    self.suppressDirty = false;

    self.site().extent().geometry().areaKmSq.subscribe(function(val){
        self.site().area(val)
    });

    self.loadSite = function (site) {
        var siteModel = self.site();
        siteModel.name(exists(site, "name"));
        siteModel.siteId(exists(site, "siteId"));
        siteModel.externalId(exists(site, "externalId"));
        siteModel.catchment(exists(site, "catchment"));
        siteModel.type(exists(site, "type"));
        siteModel.area(exists(site, "area"));
        siteModel.description(exists(site, "description"));
        siteModel.notes(exists(site, "notes"));
        siteModel.projects(site.projects || []);

        if (site.extent) {
            self.site().extent().source(exists(site.extent, "source"));
            self.loadGeometry(site.extent.geometry || {}, true);
        } else {
            self.site().extent().source(site.features && site.features.length ? 'drawn' : '');
            self.loadGeometry({}, true);
        }
        self.loadMapFromSite(site);

        if(self.site().extent().geometry().areaKmSq()){
            self.site().area(self.site().extent().geometry().areaKmSq())
        }

        if (!_.isEmpty(site.poi)) {
            site.poi.forEach(function (poi) {
                createPointOfInterest(poi, self.hasPhotoPointDocuments(poi))
            });
        }

        self.displayAreaInReadableFormat = ko.computed(function(){
            if(self.site().area()){
                return convertKMSqToReadableUnit(self.site().area())
            }
        });
    };

    self.hasPhotoPointDocuments = function (poi) {
        if (!self.site.documents) {
            return;
        }
        var hasDoc = false;
        $.each(self.site.documents, function (i, doc) {
            if (doc.poiId === poi.poiId) {
                hasDoc = true;
                return false;
            }
        });
        return hasDoc;
    };

    self.loadGeometry = function (geometry, skipMap) {
        var geometryObservable = self.site().extent().geometry();
        if (latSubscriber) {
            latSubscriber.dispose();
        }
        if (lngSubscriber) {
            lngSubscriber.dispose();
        }
        geometryObservable.decimalLatitude(exists(geometry, 'decimalLatitude')),
        geometryObservable.decimalLongitude(exists(geometry, 'decimalLongitude')),
        geometryObservable.uncertainty(exists(geometry, 'uncertainty')),
        geometryObservable.precision(exists(geometry, 'precision')),
        geometryObservable.datum(exists(geometry, 'datum')),
        geometryObservable.type(exists(geometry, 'type')),
        geometryObservable.nrm(exists(geometry, 'nrm')),
        geometryObservable.state(exists(geometry, 'state')),
        geometryObservable.lga(exists(geometry, 'lga')),
        geometryObservable.locality(exists(geometry, 'locality')),
        geometryObservable.mvg(exists(geometry, 'mvg')),
        geometryObservable.mvs(exists(geometry, 'mvs')),
        geometryObservable.radius(exists(geometry, 'radius')),
        geometryObservable.areaKmSq(exists(geometry, 'areaKmSq')),
        geometryObservable.coordinates(exists(geometry, 'coordinates')),
        geometryObservable.centre(exists(geometry, 'centre')),
        geometryObservable.bbox(exists(geometry, 'bbox')),
        geometryObservable.pid(exists(geometry, 'pid')),
        geometryObservable.name(exists(geometry, 'name')),
        geometryObservable.fid(exists(geometry, 'fid')),
        geometryObservable.layerName(exists(geometry, 'layerName'))

        latSubscriber = geometryObservable.decimalLatitude.subscribe(updateSiteMarkerPosition);
        lngSubscriber = geometryObservable.decimalLongitude.subscribe(updateSiteMarkerPosition);

        if (!skipMap && !_.isEmpty(geometry) && self.site().extent().source() != 'none') {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            if (validGeoJson) {
                self.map.setGeoJSON(validGeoJson);
            }
        }
        self.showPointAttributes(geometry && geometry.type == "Point");
        loadGazetteInformation(geometryObservable.decimalLatitude(), geometryObservable.decimalLongitude());

        return geometryObservable;
    };

    self.loadMapFromSite = function (rawSite) {
        if (!self.map) {
            return;
        }
        var geoJson = Biocollect.MapUtilities.geoJsonForSite(rawSite || {});
        self.suppressDirty = true;
        if (self.map.resetMap) {
            self.map.resetMap();
        }
        if (geoJson) {
            self.map.setGeoJSON(geoJson);
            self.map.fitBounds();
        }
        self.refreshGeometrySummaries(Biocollect.MapUtilities.featuresForSite(rawSite || {}));
        self.suppressDirty = false;
        self.geometryDirty = false;
    };

    self.newPointOfInterest = function () {
        var centre = self.map.getCentre();
        createPointOfInterest({
            name: "Point of interest #" + (self.pointsOfInterest().length + 1),
            geometry: {
                decimalLatitude: centre.lat,
                decimalLongitude: centre.lng
            }
        }, false);
    };

    self.refreshCoordinates = function () {
        updateSiteMarkerPosition();
    };

    function createPointOfInterest(poi, hasDocuments) {
        var pointOfInterest = new PointOfInterest(poi, hasDocuments);

        pointOfInterest.geometry().decimalLatitude.subscribe(self.renderPointsOfInterest);
        pointOfInterest.geometry().decimalLongitude.subscribe(self.renderPointsOfInterest);

        if (Biocollect.MapUtilities.isValidLatLng(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude)) {
            pointOfInterest.marker = ALA.MapUtils.createMarker(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude, pointOfInterest.name, {
                icon: pointOfInterestIcon,
                draggable: true
            });
            pointOfInterest.marker.on("dragend", pointOfInterest.dragEvent);
            pointOfInterestMarkers.addLayer(pointOfInterest.marker);
        }

        self.pointsOfInterest.push(pointOfInterest);
    }

    self.renderPointsOfInterest = function () {
        pointOfInterestMarkers.clearLayers();

        self.pointsOfInterest().forEach(function (pointOfInterest) {
            if (!Biocollect.MapUtilities.isValidLatLng(pointOfInterest.geometry().decimalLatitude(), pointOfInterest.geometry().decimalLongitude())) {
                return;
            }

            var marker  = ALA.MapUtils.createMarker(
                pointOfInterest.geometry().decimalLatitude(),
                pointOfInterest.geometry().decimalLongitude(),
                pointOfInterest.name,
                {icon: pointOfInterestIcon, draggable: true}
            );

            marker.on("dragend", pointOfInterest.dragEvent);

            pointOfInterestMarkers.addLayer(marker);
        });
    };

    self.removePointOfInterest = function (pointOfInterest) {
        if (pointOfInterest.hasPhotoPointDocuments) {
            return;
        }
        self.pointsOfInterest.remove(pointOfInterest);
        self.renderPointsOfInterest();
    };

    self.toJS = function() {
        var js = ko.toJS(self.site);
        var poi = [];
        self.pointsOfInterest().forEach(function (item) {
            poi.push(item.toJSON());
        });
        var payload = Biocollect.MapUtilities.sitePayloadForSave(self.originalSite, featuresFromEditorMap(), poi, self.geometryDirty);
        js.extent = payload.extent;
        if (payload.features) {
            js.features = payload.features;
        } else {
            delete js.features;
        }
        js.poi = payload.poi;
        if (self.originalVisibility) {
            js.visibility = self.originalVisibility;
        }

        if (js.extent && js.extent.geometry) {
            var geomObs = self.site().extent().geometry();
            if (self.geometryDirty) {
                ['nrm', 'state', 'lga', 'locality', 'mvg', 'mvs'].forEach(function (name) {
                    var value = geomObs[name] && geomObs[name]();
                    if (value && !js.extent.geometry[name]) {
                        js.extent.geometry[name] = value;
                    }
                });
            }

            // These are edited in the form, so they must be saved even when the geometry itself is unchanged.
            ['uncertainty', 'precision', 'datum'].forEach(function (name) {
                var value = geomObs[name] && geomObs[name]();
                if (value === '' || value == null) {
                    delete js.extent.geometry[name];
                } else {
                    js.extent.geometry[name] = value;
                }
            });
        }

        // An empty site stays empty. Do not invent a geometry from the map centre.
        if (js.extent && js.extent.source == 'none') {
            delete js.extent.geometry;
        }
        if (js.extent && js.extent.geometry && js.extent.geometry.areaKmSq) {
            js.area = js.extent.geometry.areaKmSq;
        }
        js.geoIndex = Biocollect.MapUtilities.constructGeoIndexObject(js);

        return js;
    };

    self.modelAsJSON = function () {
        return JSON.stringify(self.toJS());
    };

    self.saved = function () {
        return self.site().siteId();
    };

    self.isValid = function(mandatory) {
        var valid = true;

        if (mandatory) {
            var js = self.toJS();
            valid = js && js.extent && js.extent.geometry && js.extent.geometry.type && js.extent.geometry.type != null && js.extent.geometry.type != "";
        }

        return valid;
    };

    function initialiseViewModel() {
        var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
        var options =  {
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            maxZoom: 20,
            wmsLayerUrl: mapOptions.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: mapOptions.featureService + "?featureId=",
            drawOptions: mapOptions.drawOptions,
            showReset: false,
            baseLayer: baseLayersAndOverlays.baseLayer,
            otherLayers: baseLayersAndOverlays.otherLayers,
            overlays: baseLayersAndOverlays.overlays,
            overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault
        };

        for (var option in mapOptions) {
            if (mapOptions.hasOwnProperty(option)){
                options[option] = mapOptions[option];
            }
        }

        if(mapOptions.readonly){
            var readonlyProps = {
                drawControl: false,
                singleMarker: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                draggableMarkers: false,
                showReset: false,
                addGeometryFromLocalFile: false
            };
            for(var prop in readonlyProps){
                options[prop] = readonlyProps[prop]
            }
        } else {
            options.drawControl = true;
            options.singleDraw = false;
            options.singleMarker = false;
            options.markerOrShapeNotBoth = false;
            options.drawOptions = {
                polyline: true,
                polygon: true,
                rectangle: true,
                circle: true,
                marker: true,
                circlemarker: false,
                edit: true
            };
            options.addGeometryFromLocalFile = true;
            options.simplifyImportedShapes = true;
            options.flattenMultiGeometries = true;
            options.addAllFeaturesFromFile = true;
            options.assignNameEnabled = true;
        }

        self.map = new ALA.Map(mapContainerId, options);

        if(!mapOptions.readonly){
            var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(self.map, mapOptions.featuresService, mapOptions.regionListUrl);
            self.map.addControl(regionSelector);
        }

        self.map.addButton("<span class='fa fa-undo reset-map' title='Reset map'></span>", function () {
            self.suppressDirty = true;
            self.map.resetMap();
            self.loadMapFromSite(self.loadedSite || {});
            if (self.loadedSite && self.loadedSite.extent && self.loadedSite.extent.geometry) {
                self.loadGeometry(self.loadedSite.extent.geometry, true);
            }
            self.geometryDirty = false;
            self.suppressDirty = false;
        }, "bottomright");

        self.map.subscribe(onMapChanged);
        self.map.registerListener("ala-map:create", onMapChanged);
        self.map.registerListener("pm:update", onMapChanged);

        // We'll track the points of interest as a separate feature group manually attached to the underlying map
        // implementation so that we can take advantage of the single-layer controls provided by ALA.Map to control the
        // site region.
        self.map.getMapImpl().addLayer(pointOfInterestMarkers);

        self.loadSite(site);
    }

    function pidFromLayer(layer) {
        if (!layer || !layer.options) {
            return null;
        }
        if (layer.options.pid) {
            return layer.options.pid;
        }
        var viewparams = layer.wmsParams && layer.wmsParams.viewparams;
        if (viewparams && String(viewparams).indexOf('s:') === 0) {
            return String(viewparams).substring(2);
        }
        return null;
    }

    function featuresFromEditorMap() {
        var geoJson = self.map && self.map.getGeoJSON ? self.map.getGeoJSON() : null;
        var features = (geoJson && geoJson.features ? geoJson.features : []).filter(function (feature) {
            return !(feature.properties && feature.properties.type === 'poi');
        });
        var knownPids = {};
        features.forEach(function (feature) {
            if (feature.properties && feature.properties.pid) {
                knownPids[feature.properties.pid] = true;
            }
        });
        if (self.map && self.map.getMapImpl) {
            self.map.getMapImpl().eachLayer(function (layer) {
                var pid = pidFromLayer(layer);
                if (pid && !knownPids[pid]) {
                    knownPids[pid] = true;
                    features.push(Biocollect.MapUtilities.pidFeatureFromLayer(layer, pid));
                }
            });
        }
        return features;
    }

    function setLatLngQuiet(lat, lng) {
        if (latSubscriber) {
            latSubscriber.dispose();
        }
        if (lngSubscriber) {
            lngSubscriber.dispose();
        }
        var geometry = self.site().extent().geometry();
        geometry.decimalLatitude(lat);
        geometry.decimalLongitude(lng);
        if (lat != null && lng != null) {
            geometry.coordinates([Number(lng), Number(lat)]);
            geometry.centre([Number(lng), Number(lat)]);
        }
        latSubscriber = geometry.decimalLatitude.subscribe(updateSiteMarkerPosition);
        lngSubscriber = geometry.decimalLongitude.subscribe(updateSiteMarkerPosition);
    }

    function applyFeaturesToPanel(features) {
        self.refreshGeometrySummaries(features);
        if (!features.length) {
            return;
        }
        if (features.length > 1) {
            var payload = Biocollect.MapUtilities.sitePayloadForSave({extent: {source: 'none'}, poi: []}, features, [], true);
            var summary = payload.extent && payload.extent.geometry;
            if (summary) {
                self.site().extent().source('drawn');
                self.site().extent().geometry().type(summary.type);
                self.site().extent().geometry().coordinates(summary.coordinates);
                self.site().extent().geometry().centre(summary.centre);
                self.site().extent().geometry().areaKmSq(summary.areaKmSq);
                self.site().area(summary.areaKmSq);
            }
            self.showPointAttributes(false);
            return;
        }

        var feature = features[0];
        var described = Biocollect.MapUtilities.describeFeature(feature);
        var kind = described.type;
        var centre = feature.geometry && feature.geometry.coordinates && typeof feature.geometry.coordinates[0] === 'number' ? feature.geometry.coordinates : null;
        self.site().extent().geometry().type(kind === 'Circle' ? 'Circle' : kind);
        self.site().extent().geometry().radius(described.radius);
        self.site().extent().geometry().areaKmSq(described.areaKmSq);
        self.site().area(described.areaKmSq);
        if (feature.properties) {
            self.site().extent().geometry().pid(feature.properties.pid);
            self.site().extent().geometry().name(feature.properties.name);
            self.site().extent().geometry().bbox(feature.properties.bbox);
            self.site().extent().geometry().fid(feature.properties.fid);
            self.site().extent().geometry().layerName(feature.properties.fieldname || feature.properties.layerName);
        }
        if (kind === 'Point' && centre) {
            self.site().extent().source('point');
            setLatLngQuiet(centre[1], centre[0]);
            self.showPointAttributes(true);
            loadGazetteInformation(centre[1], centre[0]);
        } else if (kind === 'Circle' && centre) {
            self.site().extent().source('drawn');
            self.site().extent().geometry().coordinates(centre);
            self.site().extent().geometry().centre(centre);
            self.showPointAttributes(false);
            loadGazetteInformation(centre[1], centre[0]);
        } else if (kind === 'pid') {
            self.site().extent().source('pid');
            self.site().extent().geometry().type('pid');
            self.showPointAttributes(false);
        } else {
            self.site().extent().source('drawn');
            self.site().extent().geometry().coordinates(feature.geometry && feature.geometry.coordinates);
            self.showPointAttributes(false);
            if (centre) {
                loadGazetteInformation(centre[1], centre[0]);
            }
        }
    }

    function clearGeometryObservables() {
        self.loadGeometry({}, true);
        self.site().extent().source('none');
        self.geometrySummaries([]);
    }

    function onMapChanged() {
        if (self.suppressDirty) {
            return;
        }
        var features = featuresFromEditorMap();
        var matches = Biocollect.MapUtilities.featuresMatchSite(self.originalSite, features);
        self.geometryDirty = !matches;
        if (matches) {
            self.refreshGeometrySummaries(features.length ? features : Biocollect.MapUtilities.featuresForSite(self.originalSite));
            return;
        }
        if (features.length) {
            applyFeaturesToPanel(features);
        } else {
            clearGeometryObservables();
        }
    }

    self.refreshGeometrySummaries = function (features) {
        var summaries = (features || []).map(function (feature) {
            var described = Biocollect.MapUtilities.describeFeature(feature);
            var areaLabel = described.areaKmSq || described.areaKmSq === 0 ? convertKMSqToReadableUnit(described.areaKmSq) : '';
            return {
                type: described.type,
                radius: described.radius,
                areaKmSq: described.areaKmSq,
                areaLabel: areaLabel
            };
        });
        self.geometrySummaries(summaries);
        if (summaries.length > 1) {
            var total = 0, any = false;
            summaries.forEach(function (summary) {
                if (summary.areaKmSq || summary.areaKmSq === 0) {
                    total += Number(summary.areaKmSq);
                    any = true;
                }
            });
            if (any) {
                self.site().area(total);
                self.site().extent().geometry().areaKmSq(total);
            }
        }
    };

    function updateSiteMarkerPosition() {
        var geometry = self.site().extent().geometry();
        if (!Biocollect.MapUtilities.isValidLatLng(geometry.decimalLatitude(), geometry.decimalLongitude()) || !self.showPointAttributes()) {
            return;
        }
        geometry.coordinates([Number(geometry.decimalLongitude()), Number(geometry.decimalLatitude())]);
        geometry.centre([Number(geometry.decimalLongitude()), Number(geometry.decimalLatitude())]);
        self.geometryDirty = true;
        var markers = self.map.getAllMarkers();
        if (markers.length === 1 && markers[0].setLatLng) {
            markers[0].setLatLng([geometry.decimalLatitude(), geometry.decimalLongitude()]);
        } else {
            self.map.clearMarkers();
            self.map.addMarker(geometry.decimalLatitude(), geometry.decimalLongitude());
        }
        loadGazetteInformation(geometry.decimalLatitude(), geometry.decimalLongitude());
    }

    function loadGazetteInformation(lat, lng) {
        if (!_.isUndefined(lat) && lat && !_.isUndefined(lng) && lng) {
            self.transients.loadingGazette(true);
            $.ajax({
                url: fcConfig.siteMetaDataUrl + "?lat=" + lat + "&lon=" + lng,
                dataType: "json"
            }).done(function (data) {
                self.site().extent().geometry().nrm(exists(data, 'nrm'));
                self.site().extent().geometry().state(exists(data, 'state'));
                self.site().extent().geometry().lga(exists(data, 'lga'));
                self.site().extent().geometry().locality(exists(data, 'locality'));
                self.site().extent().geometry().mvg(exists(data, 'mvg'));
                self.site().extent().geometry().mvs(exists(data, 'mvs'));
            }).always(function (data) {
                self.transients.loadingGazette(false);
            });
        }
    }

    initialiseViewModel();
};

var PointOfInterest = function (data, hasDocuments) {
    var self = this;

    self.marker = null;
    self.poiId = ko.observable(exists(data, 'poiId'));
    self.name = ko.observable(exists(data, 'name'));
    self.type = ko.observable(exists(data, 'type'));
    self.description = ko.observable(exists(data, 'description'));

    if (!_.isUndefined(data.geometry)) {
        self.geometry = ko.observable({
            type: ALA.MapConstants.DRAW_TYPE.POINT_TYPE,
            decimalLatitude: ko.observable(exists(data.geometry, 'decimalLatitude')),
            decimalLongitude: ko.observable(exists(data.geometry, 'decimalLongitude')),
            uncertainty: ko.observable(exists(data.geometry, 'uncertainty')),
            precision: ko.observable(exists(data.geometry, 'precision')),
            datum: ko.observable(exists(data.geometry, 'datum')),
            bearing: ko.observable(exists(data.geometry, 'bearing'))
        });
    }
    self.hasPhotoPointDocuments = hasDocuments;

    self.dragEvent = function (event) {
        var lat = event.target.getLatLng().lat;
        var lng = event.target.getLatLng().lng;
        self.geometry().decimalLatitude(lat);
        self.geometry().decimalLongitude(lng);
    };

    self.hasCoordinate = function () {
        return !isNaN(self.geometry().decimalLatitude()) && !isNaN(self.geometry().decimalLongitude());
    };

    self.toJSON = function () {
        var js = {
            poiId: self.poiId(),
            name: self.name(),
            type: self.type(),
            description: self.description(),
            geometry: ko.toJS(self.geometry)
        };

        if (self.hasCoordinate()) {
            js.geometry.coordinates = [js.geometry.decimalLatitude, js.geometry.decimalLongitude];
        }
        return js;
    };
};



var SitesViewModel =  function(sites, map, mapFeatures, isUserEditor, projectId, projectDefaultZoomArea) {

    var self = this;
    var poiLayer = null;
    var poiIcon = L.icon({
        iconUrl: 'https://maps.google.com/mapfiles/marker_yellow.png',
        iconSize: [20, 34],
        iconAnchor: [10, 34],
        popupAnchor: [0, -34]
    });

    function escapeHtml(value) {
        return String(value == null ? '' : value).replace(/[&<>"']/g, function (character) {
            return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[character];
        });
    }

    function ensurePoiLayer() {
        if (!poiLayer && map && map.getMapImpl) {
            poiLayer = L.featureGroup().addTo(map.getMapImpl());
        }
        return poiLayer;
    }

    self.sites = $.map(sites || [], function (site, index) {
        site.feature = Biocollect.MapUtilities.featuresForSite(site);
        if ((!site.feature || !site.feature.length) && mapFeatures && mapFeatures.features && mapFeatures.features[index]) {
            var converted = Biocollect.MapUtilities.featureToValidGeoJson(mapFeatures.features[index]);
            if (converted && converted.type === 'FeatureCollection') {
                site.feature = converted.features || [];
            } else if (converted) {
                site.feature = [converted];
            }
        }
        site.selected = ko.observable(false);
        site.selected.subscribe(function (selected) {
            if (selected) {
                self.showSite(site);
            } else {
                self.hideSite(site);
            }
        });
        return site;
    });
    self.selectedSiteIds = ko.computed(function() {
        var siteIds = [];
        $.each(self.sites, function(i, site) {
            if (site.selected()) {
                siteIds.push(site.siteId);
            }
        });
        return siteIds;
    });
    self.sitesFilter = ko.observable("");
    self.throttledFilter = ko.computed(self.sitesFilter).extend({throttle: 400});
    self.filteredSites = ko.observableArray(self.sites);
    self.displayedSites = ko.observableArray();
    self.selectAll = ko.pureComputed({
        read: function () {
            var page = self.displayedSites();
            return page.length > 0 && page.every(function (site) { return site.selected(); });
        },
        write: function (value) {
            self.displayedSites().forEach(function (site) { site.selected(!!value); });
        }
    });
    self.offset = ko.observable(0);
    self.pageSize = 10;
    self.isUserEditor = ko.observable(isUserEditor);
    self.getSiteName = function (siteId) {
        var site;
        if (siteId !== undefined && siteId !== '') {
            site = $.grep(self.sites, function (obj, i) {
                return (obj.siteId === siteId);
            });
            if (site.length > 0) {
                return site[0].name();
            }
        }
        return '';
    };
    // Animation callbacks for the lists
    self.showElement = function (elem) {
        if (elem.nodeType === 1) $(elem).hide().slideDown()
    };
    self.hideElement = function (elem) {
        if (elem.nodeType === 1) $(elem).slideUp(function () {
            $(elem).remove();
        })
    };

    var previousIndicies = [];
    function compareIndicies(indicies1, indicies2) {

        if (indicies1 == indicies2) {
            return true;
        }

        if (indicies1.length != indicies2.length) {
            return false;
        }
        for (var i=0; i<indicies1.length; i++) {
            if (indicies1[i] != indicies2[i]) {
                return false;
            }
        }
        return true;
    }
    /** Callback from datatables event listener so we can keep the map in sync with the table filter / pagination */
    self.sitesFiltered = function(indicies) {
        if (compareIndicies(indicies || [], previousIndicies)) {
            return;
        }
        self.displayedSites([]);
        if (indicies) {
            for (var i=0; i<indicies.length; i++) {
                self.displayedSites.push(self.sites[indicies[i]]);
            }
        }
        self.selectAll(true);
        self.displaySites();
        previousIndicies.splice(0, previousIndicies.length);
        Array.prototype.push.apply(previousIndicies, indicies);

    };

    self.displayAllSites = function () {
        var indicies = [];
        for (var i = 0; i < self.sites.length; i++) {
            indicies.push(i);
        }
        self.sitesFiltered(indicies);
    };

    self.hideSite = function (site) {
        if (!map || !map.findLayersByProperty) {
            return;
        }
        map.findLayersByProperty('siteId', site.siteId).forEach(function (layer) {
            map.hideLayer(layer);
        });
    };

    self.showSite = function (site) {
        if (!map || !map.findLayersByProperty) {
            return;
        }
        map.findLayersByProperty('siteId', site.siteId).forEach(function (layer) {
            map.showLayer(layer);
        });
    };

    self.highlightSite = function(index) {
        var site = self.sites[index];
        if (site && site.selected() && map && map.highlightFeaturesByProperty) {
            map.highlightFeaturesByProperty('siteId', site.siteId);
        }
    };

    self.unHighlightSite = function(index) {
        var site = self.sites[index];
        if (site && map && map.unHighlightFeaturesByProperty) {
            map.unHighlightFeaturesByProperty('siteId', site.siteId);
        }
    };

    self.displaySites = function () {
        if (!map || !map.setGeoJSON) {
            return;
        }
        var previousZoom = map.getZoomToObject ? map.getZoomToObject() : false;
        if (map.setZoomToObject) {
            map.setZoomToObject(false);
        }
        map.clearLayers();
        if (map.clearMarkers) {
            map.clearMarkers();
        }
        self.removeMarkers();

        var features = [];
        $.each(self.displayedSites(), function (i, site) {
            var sourceFeatures = (site.feature && site.feature.length) ? site.feature : Biocollect.MapUtilities.featuresForSite(site);
            sourceFeatures.forEach(function (feature) {
                var copy = JSON.parse(JSON.stringify(feature));
                copy.properties = copy.properties || {};
                copy.properties.siteId = site.siteId;
                copy.properties.id = site.siteId;
                copy.properties.popupContent = escapeHtml(site.name);
                features.push(copy);
            });
        });
        if (features.length) {
            map.setGeoJSON({type: 'FeatureCollection', features: features});
            if (map.fitBounds) {
                map.fitBounds();
            }
        } else if (projectDefaultZoomArea && map.fitToBoundsOf) {
            map.fitToBoundsOf(projectDefaultZoomArea);
        }
        if (map.setZoomToObject) {
            map.setZoomToObject(previousZoom);
        }

        $.each(self.displayedSites(), function(i, site) {
            if (site.poi) {
                $.each(site.poi, function(j, poi) {
                    if (poi.geometry && poi.geometry.decimalLatitude != null && poi.geometry.decimalLongitude != null) {
                        self.addMarker(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude, poi.name);
                    }
                });
            }
            if (!site.selected()) {
                self.hideSite(site);
            }
        });
    };

    self.addMarker = function(lat, lng, name) {
        var layer = ensurePoiLayer();
        if (!layer || !Biocollect.MapUtilities.isValidLatLng(lat, lng)) {
            return;
        }
        var marker = L.marker([lat, lng], {icon: poiIcon, draggable: false});
        marker.bindPopup('<span class="poiMarkerPopup">' + escapeHtml(name) + '</span>');
        layer.addLayer(marker);
    };

    self.removeMarkers = function() {
        if (poiLayer) {
            poiLayer.clearLayers();
        }
    };


    this.removeSelectedSites = function () {
        bootbox.confirm("Are you sure you want to remove these sites?", function (result) {
            if (result) {
                var siteIds = self.selectedSiteIds();

                $.ajax({
                    url: fcConfig.sitesDeleteUrl,
                    type: 'POST',
                    data: JSON.stringify({siteIds:siteIds}),
                    contentType: 'application/json'
                }).done(function(data) {
                    if (data.warnings && data.warnings.length) {
                        bootbox.alert("Not all sites were able to be deleted.  Sites associated with an activity were not deleted.", function() {
                            document.location.href = here;
                        });
                    }
                    else {
                        document.location.href = here;
                    }
                }).fail(function(data) {
                    bootbox.alert("An error occurred while deleting the sites.  Please contact support if the problem persists.", function() {
                        document.location.href = here;
                    })
                });
            }
        });
    };
    this.editSite = function (site) {
        var url = fcConfig.siteEditUrl + '/' + site.siteId + '?returnTo=' + encodeURIComponent(fcConfig.returnTo);
        document.location.href = url;
    };
    this.deleteSite = function (site) {
        bootbox.confirm("Are you sure you want to remove this site from this project?", function (result) {
            if (result) {

                $.get(fcConfig.siteDeleteUrl + '?siteId=' + site.siteId, function (data) {
                    if (data.warnings && data.warnings.length) {
                        bootbox.alert("The site could not be deleted as it is used by a project activity.");
                    }
                    else {
                        document.location.href = here;
                    }
                });

            }
        });
    };
    this.viewSite = function (site) {
        var url = fcConfig.siteViewUrl + '/' + site.siteId + '?returnTo=' + encodeURIComponent(fcConfig.returnTo);
        if (projectId) {
            url += '&projectId='+projectId;
        }
        document.location.href = url;
    };
    this.addSite = function () {
        document.location.href = fcConfig.siteCreateUrl;
    };
    this.addExistingSite = function () {
        document.location.href = fcConfig.siteSelectUrl;
    };
    this.uploadShapefile = function () {
        document.location.href = fcConfig.siteUploadUrl;
    };
    this.bulkCreateSites = function () {
        document.location.href = fcConfig.siteUploadUrl;
    };
    function downloadSelected(format) {
        var ids = self.selectedSiteIds();
        if (!ids.length || !fcConfig.shapefileDownloadUrl) {
            return;
        }
        var url = fcConfig.shapefileDownloadUrl;
        var join = url.indexOf('?') >= 0 ? '&' : '?';
        window.open(url + join + 'format=' + encodeURIComponent(format) + '&siteIds=' + encodeURIComponent(ids.join(',')), '_blank');
    }
    this.downloadShapefile = function() {
        downloadSelected('shp');
    };
    this.downloadGeoJSON = function() {
        downloadSelected('geojson');
    };
    self.triggerGeocoding = function () {
        if (!map || !map.getAddressById) {
            return;
        }
        ko.utils.arrayForEach(self.sites, function (site) {
            map.getAddressById(site.name(), site.setAddress);
        });
    };
};

/**
 * Draw or import many geometries, then create one site per draft or one merged site.
 * Drafts are local only. Each create posts the existing ajaxUpdate payload.
 */
var BulkCreateSiteViewModel = function (config) {
    var self = this;
    config = config || {};
    self.projectId = config.projectId || (typeof fcConfig !== 'undefined' ? fcConfig.projectId : null);
    self.returnTo = config.returnTo || (typeof fcConfig !== 'undefined' ? fcConfig.returnTo : '');
    self.defaultSiteType = config.siteType || 'surveyArea';
    self.pActivityId = config.pActivityId || '';
    self.drafts = ko.observableArray([]);
    self.processing = ko.observable(false);
    self.progress = ko.observable(0);
    self.progressTotal = ko.observable(0);
    self.statusMessage = ko.observable('');
    self.finished = ko.observable(false);
    self.errorMessage = ko.observable('');
    self.suppressSync = false;

    self.progressPercent = ko.pureComputed(function () {
        var total = self.progressTotal();
        if (!total) {
            return 0;
        }
        return Math.round(100 * self.progress() / total);
    });

    self.projectUrl = ko.pureComputed(function () {
        var url = self.returnTo || '';
        if (url && url.indexOf('tab=') < 0) {
            url += (url.indexOf('?') >= 0 ? '&' : '?') + 'tab=site';
        }
        return url;
    });

    self.hasSelection = ko.pureComputed(function () {
        return self.drafts().some(function (draft) {
            return draft.selected() && !draft.siteCreated();
        });
    });

    function newTempId() {
        if (typeof UUID !== 'undefined' && UUID.generate) {
            return UUID.generate();
        }
        return 'draft-' + Math.random().toString(36).slice(2) + Date.now();
    }

    function isPidLayer(layer) {
        if (!layer) {
            return false;
        }
        if (layer.options && layer.options.pid) {
            return true;
        }
        var viewparams = layer.wmsParams && layer.wmsParams.viewparams;
        return !!(viewparams && String(viewparams).indexOf('s:') === 0);
    }

    function pidOf(layer) {
        if (layer.options && layer.options.pid) {
            return layer.options.pid;
        }
        var viewparams = layer.wmsParams && layer.wmsParams.viewparams;
        if (viewparams && String(viewparams).indexOf('s:') === 0) {
            return String(viewparams).substring(2);
        }
        return null;
    }

    function ensureFeature(layer) {
        if (!layer.feature) {
            layer.feature = {type: 'Feature', properties: {}};
        }
        if (!layer.feature.properties) {
            layer.feature.properties = {};
        }
        if (!layer.feature.properties.tempSiteId) {
            layer.feature.properties.tempSiteId = newTempId();
        }
        return layer.feature.properties;
    }

    function eachSiteLayer(callback) {
        if (!self.map || !self.map.getMapImpl) {
            return;
        }
        self.map.getMapImpl().eachLayer(function (layer) {
            if (isPidLayer(layer) || (layer.feature && typeof layer.toGeoJSON === 'function')) {
                callback(layer);
            }
        });
    }

    function featureIsValid(feature) {
        if (!feature || !feature.geometry || !feature.geometry.type) {
            return false;
        }
        var props = feature.properties || {};
        if (props.pid || props.type === 'pid') {
            return !!props.pid;
        }
        var coordinates = feature.geometry.coordinates;
        if (coordinates == null) {
            return false;
        }
        var hasCoordinates = typeof coordinates[0] === 'number' ? coordinates.length >= 2 : coordinates.length > 0;
        return hasCoordinates && (typeof turf === 'undefined' || ALA.MapUtils.validateGeoJSON(feature));
    }

    function DraftSite(tempSiteId, name, features) {
        var draft = this;
        draft.tempSiteId = tempSiteId;
        draft.name = ko.observable(name || 'Site');
        draft.features = ko.observableArray(features || []);
        draft.selected = ko.observable(true);
        draft.siteCreated = ko.observable(false);
        draft.loading = ko.observable(false);
        draft.invalid = ko.observable(!features || !features.length || features.some(function (feature) {
            return !featureIsValid(feature);
        }));
        draft.createdSiteId = ko.observable(null);
        draft.canUnpack = function () {
            var current = draft.features();
            if (current.length !== 1 || !current[0].geometry) {
                return false;
            }
            var type = current[0].geometry.type;
            return type === 'MultiPolygon' || type === 'MultiLineString' || type === 'MultiPoint';
        };
        draft.canUnmerge = function () {
            return draft.features().length > 1 && !draft.siteCreated();
        };
        draft.statusLabel = ko.pureComputed(function () {
            if (draft.siteCreated()) {
                return 'Created';
            }
            if (draft.invalid()) {
                return 'Invalid';
            }
            return 'Draft';
        });
        draft.summary = ko.pureComputed(function () {
            return draft.features().map(function (feature) {
                return Biocollect.MapUtilities.describeFeature(feature).type;
            }).join(', ');
        });
    }

    function collectFeatures() {
        var features = [];
        eachSiteLayer(function (layer) {
            var props = ensureFeature(layer);
            if (isPidLayer(layer)) {
                var pid = pidOf(layer);
                props.type = 'pid';
                props.pid = pid;
                var pidFeature = Biocollect.MapUtilities.pidFeatureFromLayer(layer, pid);
                pidFeature.properties.tempSiteId = props.tempSiteId;
                if (props.name) {
                    pidFeature.properties.name = props.name;
                }
                features.push(pidFeature);
                return;
            }
            var geo = layer.toGeoJSON();
            geo.properties = $.extend({}, props, geo.properties || {});
            geo.properties.tempSiteId = props.tempSiteId;
            if (geo.properties.type === 'poi') {
                return;
            }
            features.push(geo);
        });
        return features;
    }

    self.syncFromMap = function () {
        if (self.suppressSync || self.processing()) {
            return;
        }
        var grouped = {};
        var order = [];
        collectFeatures().forEach(function (feature) {
            var id = feature.properties && feature.properties.tempSiteId;
            if (!id) {
                return;
            }
            if (!grouped[id]) {
                grouped[id] = [];
                order.push(id);
            }
            grouped[id].push(feature);
        });
        var existing = {};
        self.drafts().forEach(function (draft) {
            existing[draft.tempSiteId] = draft;
        });
        var next = [];
        order.forEach(function (id, index) {
            var draft = existing[id];
            var name = (grouped[id][0].properties && grouped[id][0].properties.name) || ('Site ' + (index + 1));
            if (!draft) {
                draft = new DraftSite(id, name, grouped[id]);
            } else {
                draft.features(grouped[id]);
                draft.invalid(!grouped[id].length || grouped[id].some(function (feature) {
                    return !featureIsValid(feature);
                }));
            }
            next.push(draft);
        });
        self.drafts().forEach(function (draft) {
            if (draft.siteCreated() && !grouped[draft.tempSiteId]) {
                next.push(draft);
            }
        });
        self.drafts(next);
    };

    function scheduleSync() {
        if (self.suppressSync) {
            return;
        }
        if (self.syncTimer) {
            clearTimeout(self.syncTimer);
        }
        self.syncTimer = setTimeout(self.syncFromMap, 50);
    }

    self.initialiseMap = function () {
        if (typeof ALA === 'undefined' || !document.getElementById('bulkCreateMap')) {
            return;
        }
        if (fcConfig.leafletAssetURL && window.L && L.Icon && L.Icon.Default) {
            L.Icon.Default.imagePath = fcConfig.leafletAssetURL;
        }
        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
        var overlayConfig = Biocollect.MapUtilities.getOverlayConfig();
        self.map = new ALA.Map('bulkCreateMap', {
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            drawControl: true,
            singleDraw: false,
            singleMarker: false,
            markerOrShapeNotBoth: false,
            showReset: false,
            zoomToObject: false,
            maxZoom: 20,
            useMyLocation: true,
            allowSearchLocationByAddress: true,
            allowSearchRegionByAddress: false,
            drawOptions: {
                polyline: true,
                polygon: true,
                rectangle: true,
                circle: true,
                marker: true,
                circlemarker: false,
                edit: true
            },
            addGeometryFromLocalFile: true,
            simplifyImportedShapes: true,
            flattenMultiGeometries: true,
            addAllFeaturesFromFile: true,
            assignNameEnabled: true,
            baseLayer: baseLayersAndOverlays.baseLayer,
            otherLayers: baseLayersAndOverlays.otherLayers,
            overlays: baseLayersAndOverlays.overlays,
            overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
            wmsLayerUrl: overlayConfig.wmsLayerUrl,
            wmsFeatureUrl: overlayConfig.wmsFeatureUrl
        });
        if (fcConfig.featuresService && fcConfig.regionListUrl) {
            var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(self.map, fcConfig.featuresService, fcConfig.regionListUrl);
            self.map.addControl(regionSelector);
        }
        self.map.subscribe(scheduleSync);
        self.map.registerListener('ala-map:create', scheduleSync);
        self.map.registerListener('pm:update', scheduleSync);
    };

    function layersForDraft(draft) {
        var layers = [];
        eachSiteLayer(function (layer) {
            var props = layer.feature && layer.feature.properties;
            if (props && props.tempSiteId === draft.tempSiteId) {
                layers.push(layer);
            }
        });
        return layers;
    }

    self.zoomToDraft = function (draft) {
        var bounds = null;
        layersForDraft(draft).forEach(function (layer) {
            if (layer.getBounds) {
                bounds = bounds ? bounds.extend(layer.getBounds()) : layer.getBounds();
            } else if (layer.getLatLng) {
                var latLng = layer.getLatLng();
                bounds = bounds ? bounds.extend(latLng) : L.latLngBounds([latLng, latLng]);
            }
        });
        if (bounds && self.map && self.map.getMapImpl) {
            self.map.getMapImpl().fitBounds(bounds);
        }
    };

    self.deleteDraft = function (draft) {
        if (draft.siteCreated()) {
            return;
        }
        self.suppressSync = true;
        layersForDraft(draft).forEach(function (layer) {
            self.map.removeLayer(layer);
        });
        self.suppressSync = false;
        self.drafts.remove(draft);
    };

    self.unpackDraft = function (draft) {
        if (!draft.canUnpack()) {
            return;
        }
        var feature = draft.features()[0];
        var type = feature.geometry.type;
        var simpleType = type.replace('Multi', '');
        var parts = (feature.geometry.coordinates || []).map(function (coordinates, index) {
            return {
                type: 'Feature',
                properties: {name: draft.name() + ' ' + (index + 1)},
                geometry: {type: simpleType, coordinates: coordinates}
            };
        });
        self.suppressSync = true;
        layersForDraft(draft).forEach(function (layer) {
            self.map.removeLayer(layer);
        });
        if (parts.length) {
            self.map.setGeoJSON({type: 'FeatureCollection', features: parts});
        }
        self.suppressSync = false;
        self.syncFromMap();
    };

    self.unmergeDraft = function (draft) {
        if (!draft.canUnmerge()) {
            return;
        }
        var first = true;
        self.suppressSync = true;
        layersForDraft(draft).forEach(function (layer) {
            if (first) {
                first = false;
                return;
            }
            ensureFeature(layer).tempSiteId = newTempId();
        });
        self.suppressSync = false;
        self.syncFromMap();
    };

    self.mergeSelected = function () {
        var selected = self.drafts().filter(function (draft) {
            return draft.selected() && !draft.siteCreated();
        });
        if (selected.length < 2) {
            self.errorMessage('Select at least two drafts to merge.');
            return;
        }
        var keepId = selected[0].tempSiteId;
        var keepName = selected[0].name();
        self.suppressSync = true;
        selected.forEach(function (draft) {
            layersForDraft(draft).forEach(function (layer) {
                var props = ensureFeature(layer);
                props.tempSiteId = keepId;
                props.name = keepName;
            });
        });
        self.suppressSync = false;
        self.errorMessage('');
        self.syncFromMap();
    };

    function featuresForSave(features) {
        return (features || []).map(function (feature) {
            var copy = JSON.parse(JSON.stringify(feature));
            if (copy.properties) {
                delete copy.properties.tempSiteId;
            }
            return copy;
        });
    }

    function siteBody(name, features) {
        var payload = Biocollect.MapUtilities.sitePayloadForSave({extent: {source: 'none'}, poi: []}, featuresForSave(features), [], true);
        var site = {
            name: name,
            type: self.defaultSiteType,
            projects: self.projectId ? [self.projectId] : [],
            description: '',
            extent: payload.extent
        };
        if (payload.features) {
            site.features = payload.features;
        }
        var body = {site: site, projectId: self.projectId};
        if (self.pActivityId) {
            body.pActivityId = self.pActivityId;
        }
        return body;
    }

    function postSite(body) {
        return $.ajax({
            url: fcConfig.ajaxUpdateUrl,
            type: 'POST',
            data: JSON.stringify(body),
            contentType: 'application/json'
        });
    }

    function selectedCreatable() {
        return self.drafts().filter(function (draft) {
            return draft.selected() && !draft.siteCreated() && !draft.invalid();
        });
    }

    function finishCreate(created, failed) {
        self.processing(false);
        self.finished(true);
        var message = created + (created === 1 ? ' site created.' : ' sites created.');
        if (failed) {
            message += ' Some sites could not be created.';
        }
        self.statusMessage(message);
    }

    self.createSelected = function () {
        var queue = selectedCreatable();
        if (!queue.length || self.processing()) {
            self.errorMessage('Select at least one valid draft.');
            return;
        }
        self.errorMessage('');
        self.processing(true);
        self.finished(false);
        self.statusMessage('Processing sites, please wait');
        self.progress(0);
        self.progressTotal(queue.length);
        var created = 0;
        var failed = 0;

        function next(index) {
            if (index >= queue.length) {
                finishCreate(created, failed);
                return;
            }
            var draft = queue[index];
            draft.loading(true);
            postSite(siteBody(draft.name(), draft.features())).done(function (data) {
                if (data && data.id && data.status !== 'error') {
                    draft.siteCreated(true);
                    draft.createdSiteId(data.id);
                    draft.selected(false);
                    created++;
                } else {
                    draft.invalid(true);
                    failed++;
                }
            }).fail(function () {
                draft.invalid(true);
                failed++;
            }).always(function () {
                draft.loading(false);
                self.progress(index + 1);
                next(index + 1);
            });
        }

        next(0);
    };

    self.createAsOneSite = function () {
        var selected = selectedCreatable();
        if (!selected.length || self.processing()) {
            self.errorMessage('Select at least one valid draft.');
            return;
        }
        var features = [];
        selected.forEach(function (draft) {
            features = features.concat(draft.features());
        });
        self.errorMessage('');
        self.processing(true);
        self.finished(false);
        self.statusMessage('Processing sites, please wait');
        self.progress(0);
        self.progressTotal(1);
        postSite(siteBody(selected[0].name(), features)).done(function (data) {
            if (data && data.id && data.status !== 'error') {
                selected.forEach(function (draft) {
                    draft.siteCreated(true);
                    draft.createdSiteId(data.id);
                    draft.selected(false);
                });
                self.progress(1);
                finishCreate(1, 0);
            } else {
                self.progress(1);
                finishCreate(0, selected.length);
            }
        }).fail(function () {
            self.progress(1);
            finishCreate(0, selected.length);
        });
    };

    self.goToProject = function () {
        if (self.projectUrl()) {
            document.location.href = self.projectUrl();
        }
    };

    self.initialiseMap();
};

