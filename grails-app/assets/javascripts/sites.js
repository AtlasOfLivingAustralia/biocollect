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

    self.site().extent().geometry().areaKmSq.subscribe(function(val){
        self.site().area(val)
    });

    self.loadSite = function (site) {
        var siteModel = self.site();
        siteModel.name(exists(site, "name"));
        siteModel.siteId(exists(site, "siteId"));
        siteModel.externalId(exists(site, "externalId"));
        siteModel.type(exists(site, "type"));
        siteModel.area(exists(site, "area"));
        siteModel.description(exists(site, "description"));
        siteModel.notes(exists(site, "notes"));
        siteModel.projects(site.projects || []);

        if (site.extent) {
            self.site().extent().source(exists(site.extent, "source"));
            self.loadGeometry(site.extent.geometry || {});
        } else {
            self.site().extent().source('');
            self.loadGeometry({});
        }

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

    self.loadGeometry = function (geometry) {
        var geometryObservable = self.site().extent().geometry();
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

        if (!_.isEmpty(geometry) && self.site().extent().source() != 'none') {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            self.map.setGeoJSON(validGeoJson);
            self.showPointAttributes(geometry.type == "Point");
        }
        loadGazetteInformation(geometryObservable.decimalLatitude(), geometryObservable.decimalLongitude());

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

        // legacy support - it was possible to have no extent for a site. This step will delete geometry before saving.
        if(js.extent.source == 'none'){
            delete js.extent.geometry;
        }

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
        var options =  {
            maxZoom: 20,
            wmsLayerUrl: mapOptions.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: mapOptions.featureService + "?featureId=",
            drawOptions: mapOptions.drawOptions,
            showReset: false
        };

        if(mapOptions.readonly){
            var readonlyProps = {
                drawControl: false,
                singleMarker: false,
                useMyLocation: false,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                draggableMarkers: false,
                showReset: false
            };
            for(var prop in readonlyProps){
                options[prop] = readonlyProps[prop]
            }
        }

        self.map = new ALA.Map(mapContainerId, options);

        if(!mapOptions.readonly){
            var regionSelector = Biocollect.MapUtilities.createKnownShapeMapControl(self.map, mapOptions.featuresService, mapOptions.regionListUrl);
            self.map.addControl(regionSelector);
        }

        self.map.addButton("<span class='fa fa-undo reset-map' title='Reset map'></span>", function () {
            self.map.resetMap();
            pointOfInterestMarkers.clearLayers();
            self.pointsOfInterest([]);
            self.loadGeometry({});
            self.loadSite(site || {});
        }, "bottomleft");



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
        if (self.site() && self.site().extent) {
            self.site().extent().geometry().decimalLatitude(lat);
            self.site().extent().geometry().decimalLongitude(lng);
            latSubscriber = self.site().extent().geometry().decimalLatitude.subscribe(updateSiteMarkerPosition);
            lngSubscriber = self.site().extent().geometry().decimalLongitude.subscribe(updateSiteMarkerPosition);
        }
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
        } else if (geoJsonFeature.geometry.type == ALA.MapConstants.DRAW_TYPE.LINE_TYPE) {
            type = geoJsonFeature.geometry.type
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



var SitesViewModel =  function(sites, map, mapFeatures, isUserEditor, projectId, projectDefaultZoomArea) {

    var self = this;
    // sites
    var features = [];
    if (mapFeatures.features) {
        features = mapFeatures.features;
    }

    self.sites = $.map(sites, function (site, i) {
        var feature = features[i] || site.extent ? site.extent.geometry : null;
        site.feature = feature;
        site.selected = ko.observable(false);
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
        self.displaySites();
        previousIndicies.splice(0, previousIndicies.length);
        Array.prototype.push.apply(previousIndicies, indicies);

    };

    self.highlightSite = function(index) {
        map.highlightFeatureById(self.sites[index].siteId);
    };

    self.unHighlightSite = function(index) {
        map.unHighlightFeatureById(self.sites[index].siteId);
    };

    self.displaySites = function () {
        map.clearFeatures();

        var features = $.map(self.displayedSites(), function (obj, i) {
            var f = obj.feature;
            if (f) {
                f.popup = obj.name;
                f.id = obj.siteId;
            }
            return f;
        });
        map.defaultZoomArea = projectDefaultZoomArea;
        map.replaceAllFeatures(features);
        self.removeMarkers();

        $.each(self.displayedSites(), function(i, site) {
            if (site.poi) {
                $.each(site.poi, function(j, poi) {
                    if (poi.geometry) {
                        self.addMarker(poi.geometry.decimalLatitude, poi.geometry.decimalLongitude, poi.name);
                    }

                });
            }
        });

    };

    var markersArray = [];

    self.addMarker = function(lat, lng, name) {

        var infowindow = new google.maps.InfoWindow({
            content: '<span class="poiMarkerPopup">' + name +'</span>'
        });

        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(lat,lng),
            title:name,
            draggable:false,
            map:map.map
        });

        marker.setIcon('https://maps.google.com/mapfiles/marker_yellow.png');

        google.maps.event.addListener(marker, 'click', function() {
            infowindow.open(map.map, marker);
        });

        markersArray.push(marker);
    };

    self.removeMarkers = function() {
        if (markersArray) {
            for (var i in markersArray) {
                markersArray[i].setMap(null);
            }
        }
        markersArray = [];
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
    this.downloadShapefile = function() {
        window.open(fcConfig.shapefileDownloadUrl, '_blank');
    };
    self.triggerGeocoding = function () {
        ko.utils.arrayForEach(self.sites, function (site) {
            map.getAddressById(site.name(), site.setAddress);
        });
    };

    self.displaySites();
};

