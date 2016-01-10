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
    self.site = null;
    self.pointsOfInterest = ko.observableArray();
    self.showPointAttributes = ko.observable(false);
    self.allowPointsOfInterest = ko.observable(mapOptions.allowPointsOfInterest || false);

    self.loadSite = function (site) {
        self.site = ko.observable({
            name: ko.observable(exists(site, "name")),
            siteId: ko.observable(exists(site, "siteId")),
            externalId: ko.observable(exists(site, "externalId")),
            type: ko.observable(exists(site, "type")),
            area: ko.observable(exists(site, "area")),
            description: ko.observable(exists(site, "description")),
            notes: ko.observable(exists(site, "notes")),
            projects: ko.observableArray(site.projects || [])
        });

        if (site.extent) {
            self.site().extent = ko.observable({
                source: ko.observable(exists(site.extent, "source")),
                geometry: self.loadGeometry(site.extent.geometry || {})
            });
        } else {
            self.site().extent = ko.observable({
                source: ko.observable(),
                geometry: self.loadGeometry({})
            });
        }

        if (!_.isEmpty(site.poi)) {
            site.poi.forEach(function (poi) {
                createPointOfInterest(poi, self.hasPhotoPointDocuments(poi))
            });
        }
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

    self.loadGeometry = function (geometry) {
        var geometryObservable = ko.observable({
            decimalLatitude: ko.observable(exists(geometry, 'decimalLatitude')),
            decimalLongitude: ko.observable(exists(geometry, 'decimalLongitude')),
            uncertainty: ko.observable(exists(geometry, 'uncertainty')),
            precision: ko.observable(exists(geometry, 'precision')),
            datum: ko.observable(exists(geometry, 'datum')),

            type: ko.observable(exists(geometry, 'type')),
            nrm: ko.observable(exists(geometry, 'nrm')),
            state: ko.observable(exists(geometry, 'state')),
            lga: ko.observable(exists(geometry, 'lga')),
            locality: ko.observable(exists(geometry, 'locality')),
            mvg: ko.observable(exists(geometry, 'mvg')),
            mvs: ko.observable(exists(geometry, 'mvs')),

            radius: ko.observable(exists(geometry, 'radius')),
            areaKmSq: ko.observable(exists(geometry, 'areaKmSq')),
            coordinates: ko.observable(exists(geometry, 'coordinates')),
            centre: ko.observable(exists(geometry, 'centre')),

            bbox: ko.observable(exists(geometry, 'bbox')),
            pid: ko.observable(exists(geometry, 'pid')),
            name: ko.observable(exists(geometry, 'name')),
            fid: ko.observable(exists(geometry, 'fid')),
            layerName: ko.observable(exists(geometry, 'layerName'))
        });

        latSubscriber = geometryObservable().decimalLatitude.subscribe(updateSiteMarkerPosition);
        lngSubscriber = geometryObservable().decimalLongitude.subscribe(updateSiteMarkerPosition);

        if (!_.isEmpty(geometry)) {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            self.map.setGeoJSON(validGeoJson);
            self.showPointAttributes(geometry.type == "Point");
        }
        loadGazetteInformation(geometryObservable().decimalLatitude(), geometryObservable().decimalLongitude());

        return geometryObservable;
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

    function createPointOfInterest(poi, hasDocuments) {
        var pointOfInterest = new PointOfInterest(poi, hasDocuments);

        pointOfInterest.geometry().decimalLatitude.subscribe(self.renderPointsOfInterest);
        pointOfInterest.geometry().decimalLongitude.subscribe(self.renderPointsOfInterest);

        pointOfInterest.marker = ALA.MapUtils.createMarker(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude, pointOfInterest.name, {
            icon: pointOfInterestIcon,
            draggable: true
        });
        pointOfInterest.marker.on("dragend", pointOfInterest.dragEvent);
        pointOfInterestMarkers.addLayer(pointOfInterest.marker);

        self.pointsOfInterest.push(pointOfInterest);
    }

    self.renderPointsOfInterest = function () {
        pointOfInterestMarkers.clearLayers();

        self.pointsOfInterest().forEach(function (pointOfInterest) {
            var marker = marker = ALA.MapUtils.createMarker(
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

        js.poi = [];
        self.pointsOfInterest().forEach(function (poi) {
            js.poi.push(poi.toJSON())
        });
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
        self.map = new ALA.Map(mapContainerId, {
            maxZoom: 9,
            wmsLayerUrl: mapOptions.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: mapOptions.featureService + "?featureId=",
            showReset: false
        });

        var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(self.map, mapOptions.featuresService);

        self.map.addButton("<span class='fa fa-refresh reset-map' title='Reset map'></span>", function () {
            self.map.resetMap();
            pointOfInterestMarkers.clearLayers();
            self.pointsOfInterest([]);
            self.loadGeometry({});
            self.loadSite(site || {});
        }, "bottomleft");

        self.map.addControl(regionSelector);

        self.map.registerListener("draw:created", function (event) {
            if (event.layerType == ALA.MapConstants.LAYER_TYPE.MARKER) {
                updatePointLatLng(event.layer.getLatLng().lat, event.layer.getLatLng().lng);
            }
        });

        // We'll track the points of interest as a separate feature group manually attached to the underlying map
        // implementation so that we can take advantage of the single-layer controls provided by ALA.Map to control the
        // site region.
        self.map.getMapImpl().addLayer(pointOfInterestMarkers);

        self.loadSite(site);

        self.map.subscribe(listenToSiteChanges);
    }

    function getSiteMarker() {
        return self.map.getAllMarkers().length == 1 ? self.map.getAllMarkers()[0] : null;
    }

    function listenToSiteChanges() {
        var siteMarker = getSiteMarker();

        if (siteMarker) {
            siteMarker.bindPopup(self.site().name());
            siteMarker.on("dragend", function (event) {
                updatePointLatLng(event.target.getLatLng().lat, event.target.getLatLng().lng);
            });
            updatePointLatLng(siteMarker.getLatLng().lat, siteMarker.getLatLng().lng);

            self.map.fitBounds();

            self.showPointAttributes(true);
        } else {
            var bounds = self.map.getBounds();
            updatePointLatLng(bounds ? bounds.getCenter().lat : null, bounds ? bounds.getCenter().lng : null);
            self.showPointAttributes(false);
        }

        updateGeometry();
    }

    function updatePointLatLng(lat, lng) {
        latSubscriber.dispose();
        lngSubscriber.dispose();
        self.site().extent().geometry().decimalLatitude(lat);
        self.site().extent().geometry().decimalLongitude(lng);
        latSubscriber = self.site().extent().geometry().decimalLatitude.subscribe(updateSiteMarkerPosition);
        lngSubscriber = self.site().extent().geometry().decimalLongitude.subscribe(updateSiteMarkerPosition);
    }

    function updateSiteMarkerPosition() {
        var siteMarker = getSiteMarker();

        var geometry = self.site().extent().geometry();
        if (siteMarker && geometry.decimalLatitude() && geometry.decimalLongitude()) {
            siteMarker.setLatLng(new L.LatLng(geometry.decimalLatitude(), geometry.decimalLongitude()));
            self.map.fitBounds();
            loadGazetteInformation(geometry.decimalLatitude(), geometry.decimalLongitude());
        }
    }

    function updateGeometry() {
        var geoJson = self.map.getGeoJSON();

        if (geoJson && geoJson.features && geoJson.features.length > 0) {
            var feature = geoJson.features[0];
            var geometryType = feature.geometry.type;
            var latLng = null;
            var lat;
            var lng;
            var bounds = self.map.getBounds();
            if (geometryType === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
                // the ALA Map plugin uses valid GeoJSON, which specifies coordinates as [lng, lat]
                lat = feature.geometry.coordinates[1];
                lng = feature.geometry.coordinates[0];
                self.site().extent().geometry().centre(latLng);
            } else if (bounds) {
                lat = bounds.getCenter().lat;
                lng = bounds.getCenter().lng;
            }

            var geoType = determineExtentType(feature);
            self.site().extent().geometry().type(geoType);
            self.site().extent().source(geoType == "Point" ? "Point" : geoType == "pid" ? "pid" : "drawn");
            self.site().extent().geometry().radius(feature.properties.radius);

            // the feature created by a WMS layer will have the area in the 'area_km' property
            if (feature.properties.area_km) {
                self.site().extent().geometry().areaKmSq(feature.properties.area_km);
            } else {
                self.site().extent().geometry().areaKmSq(ALA.MapUtils.calculateAreaKmSq(feature));
            }
            self.site().extent().geometry().coordinates(feature.geometry.coordinates);

            self.site().extent().geometry().bbox(exists(feature.properties, 'bbox'));
            self.site().extent().geometry().pid(exists(feature.properties, 'pid'));
            self.site().extent().geometry().name(exists(feature.properties, 'name'));
            self.site().extent().geometry().fid(exists(feature.properties, 'fid'));
            self.site().extent().geometry().layerName(exists(feature.properties, 'fieldname'));

            loadGazetteInformation(lat, lng);
        } else {
            self.loadGeometry({});
        }
    }

    function loadGazetteInformation(lat, lng) {
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

    function determineExtentType(geoJsonFeature) {
        var type = null;

        if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POINT_TYPE) {
            if (geoJsonFeature.properties.radius) {
                type = ALA.MapConstants.DRAW_TYPE.CIRCLE_TYPE;
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POINT_TYPE;
            }
        } else if (geoJsonFeature.geometry.type === ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE) {
            if (geoJsonFeature.properties.pid) {
                type = "pid";
            } else {
                type = ALA.MapConstants.DRAW_TYPE.POLYGON_TYPE;
            }
        }

        return type;
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
