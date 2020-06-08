'use strict';

var SystematicSiteViewModel = function (mapContainerId, site, mapOptions) {
    var self = $.extend(this, new Documents());

    // var pointOfInterestIcon = ALA.MapUtils.createIcon("https://maps.google.com/mapfiles/marker_yellow.png");
    // var pointOfInterestMarkers = new L.FeatureGroup();
    var transectFeatureGroup = new L.FeatureGroup();
    var latSubscriber = null;
    var lngSubscriber = null;
    var coordSubscriber = null;
    self.transients = {
        loadingGazette: ko.observable(false)
    };

    // create model for a new site
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
    self.transectParts = ko.observableArray();
    self.showPointAttributes = ko.observable(false);
    self.allowPointsOfInterest = ko.observable(mapOptions.allowPointsOfInterest || false);
    // self.displayAreaInReadableFormat = null;

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
            self.loadGeometry(site.extent.geometry || {});
        } else {
            self.site().extent().source('');
            self.loadGeometry({});
        }

        // if(self.site().extent().geometry().areaKmSq()){
        //     self.site().area(self.site().extent().geometry().areaKmSq())
        // }

        // if (!_.isEmpty(site.poi)) {
        //     site.poi.forEach(function (poi) {
        //         createPointOfInterest(poi, self.hasPhotoPointDocuments(poi))
        //     });
        // }

        if (!_.isEmpty(site.transectParts)) {
            site.transectParts.forEach(function (transectPart) {
                createTransectPart(transectPart, false)
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

        // latSubscriber = geometryObservable.decimalLatitude.subscribe(updateSiteMarkerPosition);
        // lngSubscriber = geometryObservable.decimalLongitude.subscribe(updateSiteMarkerPosition);

        if (!_.isEmpty(geometry) && self.site().extent().source() != 'none') {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            self.map.setGeoJSON(validGeoJson);
            self.showPointAttributes(geometry.type == "Point");
        }
        // loadGazetteInformation(geometryObservable.decimalLatitude(), geometryObservable.decimalLongitude());

        return geometryObservable;
    };

    self.newTransectPart = function () {
        var drawnItem = getTransectPart();
        createTransectPart({
            name: "S" + (drawnItem.properties.name + 1),
            geometry: {
                type: drawnItem.geometry.type,
                coordinates: drawnItem.geometry.coordinates
            }
        }, false);
    };

    self.refreshCoordinates = function () {
        updateSiteMarkerPosition();
    };

    // TODO
    // called both for creating a new transect part and for reading an existing one from the site to be edited 
    // so be mindful of how the feature is saved should work with this too 
    function createTransectPart(feature, hasDocuments) {
        var transectPart = new TransectPart(feature, hasDocuments);
        console.log("part created", transectPart);
        transectPart.geometry().coordinates.subscribe(self.renderTransectParts);

        if (feature.geometry.type == "LineString"){
            transectPart.feature = ALA.MapUtils.createSegment(feature.geometry.coordinates, transectPart.name);
        } else if (feature.geometry.type == "Point"){
            transectPart.feature = ALA.MapUtils.createMarker(feature.geometry.coordinates[1],feature.geometry.coordinates[0], transectPart.name);
        } else if (feature.geometry.type == "Polygon"){
            transectPart.feature = ALA.MapUtils.createPolygon(feature.geometry.coordinates, transectPart.name);
        }
        // console.log("part after coords", transectPart.feature.getLatLngs());
        console.log("part after", transectPart);

        transectPart.feature.on("click", transectPart.editEvent);
        // Add feature to the FeatureGroup that displays on map
        transectFeatureGroup.addLayer(transectPart.feature)

        // Add feature to be saved in site collection
        self.transectParts.push(transectPart);
    }

    self.renderTransectParts = function () { 
        transectFeatureGroup.clearLayers();
        // TODO remove the layer or call mapimpl to nullify everything
        console.log(transectParts);
        self.transectParts().forEach(function (transectPart) {
           console.log('tarnsect part', transectPart);
            if (transectPart.geometry().type == "Polygon"){
                var feature = ALA.MapUtils.createPolygon(
                    transectPart.geometry().coordinates(), 
                    transectPart.name);
            } else if (transectPart.geometry().type == "LineString"){
                console.log(transectPart.geometry().type);
                var feature = ALA.MapUtils.createSegment(
                    transectPart.geometry().coordinates(), 
                    transectPart.name);
            } else if (transectPart.geometry().type == "Point"){
                var feature = ALA.MapUtils.createMarker(
                    transectPart.geometry().coordinates()[1],
                    transectPart.geometry().coordinates()[0], 
                    transectPart.name);
            }
            console.log('feature', feature);
            feature.on("click", transectPart.editEvent);

            transectFeatureGroup.addLayer(feature);
            console.log('featuregroup',transectFeatureGroup);
        });
        
    };

    self.removeTransectPart = function (transectPart) {
        if (transectPart.hasPhotoPointDocuments) {
            return;
        }
        self.transectParts.remove(transectPart);
        console.log(transectParts)
        self.renderTransectParts();
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

        js.transectParts = [];
        self.transectParts().forEach(function (transectPart) {
            js.transectParts.push(transectPart.toJSON())
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
        var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);
        var options =  {
            autoZIndex: false,
            preserveZIndex: true,
            addLayersControlHeading: true,
            maxZoom: 20,
            wmsLayerUrl: mapOptions.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: mapOptions.featureService + "?featureId=",
            drawOptions: mapOptions.drawOptions,
            singleDraw: mapOptions.singleDraw,
            markerOrShapeNotBoth: mapOptions.markerOrShapeNotBoth,
            singleMarker: mapOptions.singleMarker,
            showReset: false,
            baseLayer: baseLayersAndOverlays.baseLayer,
            otherLayers: baseLayersAndOverlays.otherLayers
            // ,
            // overlays: baseLayersAndOverlays.overlays,
            // overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault
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
                markerOrShapeNotBoth: false,
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
            // pointOfInterestMarkers.clearLayers();
            self.pointsOfInterest([]);
            self.transectParts([]);
            self.loadGeometry({});
            self.loadSite(site || {});
        }, "bottomright");

        self.map.registerListener("draw:edited", function (event) {
            console.log("event", event);
            console.log("event target: ", event.target);
            console.log("event layer: ", event.layers);
        });

        self.map.registerListener("draw:created", function (event) {
            if (event.layerType == ALA.MapConstants.LAYER_TYPE.MARKER) {
                // updatePointLatLng(event.layer.getLatLng().lat, event.layer.getLatLng().lng);
            }
        });

        // We'll track the points of interest as a separate feature group manually attached to the underlying map
        // implementation so that we can take advantage of the single-layer controls provided by ALA.Map to control the
        // site region.
        self.map.getMapImpl().addLayer(transectFeatureGroup);

        self.loadSite(site);

        // self.map.subscribe(listenToSiteChanges);
    }

    // function getSiteMarker() {
    //     return self.map.getAllMarkers().length == 1 ? self.map.getAllMarkers()[0] : null;
    // }

    // function updatePointLatLng(lat, lng) {
    //     latSubscriber.dispose();
    //     lngSubscriber.dispose();
    //     if (self.site() && self.site().extent) {
    //         self.site().extent().geometry().decimalLatitude(lat);
    //         self.site().extent().geometry().decimalLongitude(lng);
    //         latSubscriber = self.site().extent().geometry().decimalLatitude.subscribe(updateSiteMarkerPosition);
    //         lngSubscriber = self.site().extent().geometry().decimalLongitude.subscribe(updateSiteMarkerPosition);
    //     }
    // }

    // function updateSiteMarkerPosition() {
    //     var siteMarker = getSiteMarker();

    //     var geometry = self.site().extent().geometry();
    //     if (siteMarker && geometry.decimalLatitude() && geometry.decimalLongitude()) {
    //         siteMarker.setLatLng(new L.LatLng(geometry.decimalLatitude(), geometry.decimalLongitude()));
    //         self.map.fitBounds();
    //         loadGazetteInformation(geometry.decimalLatitude(), geometry.decimalLongitude());
    //     }
    // }

    // function loadGazetteInformation(lat, lng) {
    //     if (!_.isUndefined(lat) && lat && !_.isUndefined(lng) && lng) {
    //         self.transients.loadingGazette(true);
    //         $.ajax({
    //             url: fcConfig.siteMetaDataUrl + "?lat=" + lat + "&lon=" + lng,
    //             dataType: "json"
    //         }).done(function (data) {
    //             self.site().extent().geometry().nrm(exists(data, 'nrm'));
    //             self.site().extent().geometry().state(exists(data, 'state'));
    //             self.site().extent().geometry().lga(exists(data, 'lga'));
    //             self.site().extent().geometry().locality(exists(data, 'locality'));
    //             self.site().extent().geometry().mvg(exists(data, 'mvg'));
    //             self.site().extent().geometry().mvs(exists(data, 'mvs'));
    //         }).always(function (data) {
    //             self.transients.loadingGazette(false);
    //         });
    //     }
    // }

    function getTransectPart() {
        var geoJson = self.map.getGeoJSON();
        console.log("features from map:", geoJson.features);
        if (geoJson && geoJson.features && geoJson.features.length > 0) {
            var feature = geoJson.features[geoJson.features.length-1];
            feature.properties.name = geoJson.features.length-1;
            // TODO attach onclick/ onchange event to trigger change in transectParts to modify coordinates
        } else {
            // self.loadGeometry({});
            // TODO - should be a message in template systematicSiteDefinition.gsp
            alert("Draw a feature first");
        }
        return feature;
    }

    initialiseViewModel();
};

// var PointOfInterest = function (data, hasDocuments) {
//     var self = this;

//     self.marker = null;
//     self.poiId = ko.observable(exists(data, 'poiId'));
//     self.name = ko.observable(exists(data, 'name'));
//     self.type = ko.observable(exists(data, 'type'));
//     self.description = ko.observable(exists(data, 'description'));

//     if (!_.isUndefined(data.geometry)) {
//         self.geometry = ko.observable({
//             type: ALA.MapConstants.DRAW_TYPE.POINT_TYPE,
//             decimalLatitude: ko.observable(exists(data.geometry, 'decimalLatitude')),
//             decimalLongitude: ko.observable(exists(data.geometry, 'decimalLongitude')),
//             uncertainty: ko.observable(exists(data.geometry, 'uncertainty')),
//             precision: ko.observable(exists(data.geometry, 'precision')),
//             datum: ko.observable(exists(data.geometry, 'datum')),
//             bearing: ko.observable(exists(data.geometry, 'bearing'))
//         });
//     }
//     self.hasPhotoPointDocuments = hasDocuments;

//     self.dragEvent = function (event) {
//         var lat = event.target.getLatLng().lat;
//         var lng = event.target.getLatLng().lng;
//         self.geometry().decimalLatitude(lat);
//         self.geometry().decimalLongitude(lng);
//     };

//     self.hasCoordinate = function () {
//         return !isNaN(self.geometry().decimalLatitude()) && !isNaN(self.geometry().decimalLongitude());
//     };

//     self.toJSON = function () {
//         var js = {
//             poiId: self.poiId(),
//             name: self.name(),
//             type: self.type(),
//             description: self.description(),
//             geometry: ko.toJS(self.geometry)
//         };

//         if (self.hasCoordinate()) {
//             js.geometry.coordinates = [js.geometry.decimalLatitude, js.geometry.decimalLongitude];
//         }
//         return js;
//     };
// };

var TransectPart = function (data, hasDocuments) {
    var self = this;
    self.feature = null;

    self.transectPartId = ko.observable(exists(data, 'transectPartId'));
    self.name = ko.observable(exists(data, 'name'));
    self.type = ko.observable(exists(data, 'type'));
    self.description = ko.observable(exists(data, 'description'));
    self.detailList = ko.observableArray(['choose detaljkoder', 'Kraftledningsgata', 'Grusväg', 'other']);
    self.detailSelected = ko.observableArray();
    self.detailOther = ko.observableArray();
    self.detail = ko.computed(function(){
            return self.detailSelected().concat(self.detailOther());
    });
    self.habitatList = ko.observableArray(['choose habitat type', 'Lövskog', 'Blandskog', 'Barrskog', 'Hygge', 'other']);
    self.habitatSelected = ko.observableArray();
    self.habitatOther = ko.observableArray();
    self.habitat = ko.computed(function(){
        return self.habitatSelected().concat(self.habitatOther());
    });
    self.length = null;

    if (!_.isUndefined(data.geometry)) {
        var geoType = data.geometry.type;
        self.geometry = ko.observable({
            type: geoType,
            decimalLatitude: ko.observable(exists(data.geometry, 'decimalLatitude')),
            decimalLongitude: ko.observable(exists(data.geometry, 'decimalLongitude')),
            coordinates: ko.observable(exists(data.geometry, 'coordinates'))
        });
    }
    self.hasPhotoPointDocuments = hasDocuments;

    // TODO - will this work for all types of geometry? 
    self.editEvent = function (event) {
        console.log("edited tp");        
        self.geometry().coordinates(event.target.getLatLng())
    };

    // self.hasCoordinate = function () {
    //     return !isNaN(self.geometry().coordinates());
    // };

    self.toJSON = function () {
        var js = {
            transectPartId: self.transectPartId(),
            name: self.name(),
            type: self.type(),
            habitat: self.habitat(),
            detail: self.detail(),
            description: self.description(),
            geometry: ko.toJS(self.geometry)
        };

        // if (self.hasCoordinate()) {
        //     js.geometry.coordinates = [js.geometry.decimalLatitude, js.geometry.decimalLongitude];
        // }
        return js;
    };
};


