'use strict';

var SystematicSiteViewModel = function (mapContainerId, site, mapOptions) {

    var self = $.extend(this, new Documents());
    // var transectFeatureGroup = new L.FeatureGroup();

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
    self.displayAreaInReadableFormat = null; // not needed because the extention is a centroid - a point

    // to edit existing site load saved values
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

        // if transect parts are saved - get them 
        if (!_.isEmpty(site.transectParts)) {
            site.transectParts.forEach(function (transectPart) {
                createTransectPart(transectPart);
                self.renderTransect();
            });
        }
    };

    // load the extent separately as it can be modified

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

        return geometryObservable;
    };

    self.newTransectPart = function () {
        // get features from the map
        getTransectPart();
        self.renderTransect();
    };


    // TODO
    // called both for creating a new transect part and for reading an existing one from the site to be edited 
    function createTransectPart(feature) {

        console.log("feature", feature)
        var transectPart = new TransectPart(feature);
        var geometry = feature.geometry;
        var coordinates = geometry.coordinates;
        var popup = geometry.type + String(feature.name);
        function toLatLng(coordinates) {
            coordinates.map(function(coordPair) {
                let lat = coordPair[1];
                let lng = coordPair[0];
                coordPair[0] = lat;
                coordPair[1] = lng;
            });
            return coordinates;
        }
        if (geometry.type == "LineString"){
            let latLngArray = toLatLng(coordinates);
            transectPart.feature = ALA.MapUtils.createSegment(latLngArray, popup);
        } else if (geometry.type == "Point"){
            transectPart.feature = ALA.MapUtils.createMarker(coordinates[1], coordinates[0], popup, {});
        } else if (geometry.type == "Polygon"){
            let latLngArray = toLatLng(coordinates);
            transectPart.feature = ALA.MapUtils.createPolygon(latLngArray, popup);
        }
        console.log("tra part", transectPart);

        transectPart.feature.on("dragend", transectPart.dragEvent);

        // Add feature to be saved in site collection
        self.transectParts.push(transectPart);
        transectFeatureGroup.addLayer(transectPart.feature);
        console.log("layers of trans feature gr", transectFeatureGroup.getLayers());
        // var geojson = Biocollect.MapUtilities.featureToValidGeoJson(feature.geometry);
        // transectPart.feature = ALA.MapUtils.createFeatureFromGeoJson(geojson, popup);

        // the following line works and adds it to the map but in the wrong order of coordinates (geojson)
        // transectPart.feature.addTo(self.map);
    }

    self.renderTransect = function(){
        self.map.resetMap();
        transectFeatureGroup.eachLayer(function(layer) {
            layer.on("dragend", layer.dragEvent)
        });
        
        self.map.getMapImpl().addLayer(transectFeatureGroup);

        // transectFeatureGroup.addTo(self.map);
        // console.log("added to map", transectFeatureGroup);
    }

    self.removeTransectPart = function (transectPart) {
        self.transectParts.remove(transectPart);
        // self.renderTransectParts();
        self.map.removeLayer(transectPart.feature);
    };

    self.toJS = function() {
        var js = ko.toJS(self.site);

        // legacy support - it was possible to have no extent for a site. This step will delete geometry before saving.
        if(js.extent.source == 'none'){
            delete js.extent.geometry;
        }

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
        };

        for (var option in mapOptions) {
            if (mapOptions.hasOwnProperty(option)){
                options[option] = mapOptions[option];
            }
        }

        if (mapOptions.readonly){
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
            self.transectParts([]);
            self.loadGeometry({});
            self.loadSite(site || {});
        }, "bottomright");

        self.map.registerListener("draw:created", function (event) {
            var geoJson = self.map.getGeoJSON();
            var count = geoJson.features.length;
            var layer = event.layer;
            var geoType = event.layerType;
            if (geoType  == "polyline"){
                geoType = "Line"
            } else if (geoType == "marker") {
                geoType = "Point"
            } else if (geoType == "polygon") {
                geoType = "Area"
            }
            layer.bindPopup(geoType + " " + count);
        });

        self.loadSite(site);

        var layerId = null;
        var editedCoords = null;
        self.map.registerListener(
        "draw:editstop", function (e) {
            console.log("editstop");
            // var newCoords = transectFeatureGroup.getLayer(layerId).getLatLngs();
            // console.log(newCoords);

        });

        self.map.registerListener(
            "draw:edited", function (e) {
                var layers = e.layers;
                layers.eachLayer(function(layer) {
                    layerId = transectFeatureGroup.getLayerId(layer);
                })
            });
    }


    function getTransectPart() {
        // self.map.modifyDrawnItems();
        var geoJson = self.map.getGeoJSON();
        self.map.resetMap();
        var features = geoJson.features;
        if (features && features.length > 0) {
            for (let index in features){
                let name = parseInt(index) + 1;
                createTransectPart({
                    name: name,
                    geometry: {
                        type: features[index].geometry.type,
                        coordinates: features[index].geometry.coordinates
                    }
                });
            }     
        } else {
            // TODO - should be a message in template systematicSiteDefinition.gsp
            return false;
        }
    }
    // self.map.getMapImpl().addLayer(transectFeatureGroup);


    initialiseViewModel();
};

var TransectPart = function (data) {
    var self = this;
    self.feature = null;

    // create attributes that can be assigned to transect part
    self.transectPartId = ko.observable(exists(data, 'transectPartId'));
    self.name = ko.observable(exists(data, 'name'));
    self.type = ko.observable(exists(data, 'type'));
    self.description = ko.observable(exists(data, 'description'));
    self.detailList = ko.observableArray(['choose detaljkoder', 'Kraftledningsgata', 'Grusväg']);
    self.detail = ko.observableArray(exists(data, 'detail'));
    self.detailOther = ko.observableArray();
    // self.detail = ko.observableArray();
    // self.detail = ko.computed(function(){
    //         return self.detailSelected().concat(self.detailOther());
    // });
    self.habitatList = ko.observableArray(['Lövskog', 'Blandskog', 'Barrskog', 'Hygge']);
    self.habitatSelected = ko.observableArray(exists(data, 'habitat'));
    self.habitatOther = ko.observableArray();
    self.habitat = ko.observableArray(exists(data, 'habitat'));
    // self.habitat = ko.computed(function(){
    //     return self.habitatSelected().concat(self.habitatOther());
    // });
    self.length = null;

    // create geometry
    if (!_.isUndefined(data.geometry)) {
        self.geometry = ko.observable({
            type: data.geometry.type,
            decimalLatitude: ko.observable(exists(data.geometry, 'decimalLatitude')),
            decimalLongitude: ko.observable(exists(data.geometry, 'decimalLongitude')),
            coordinates: ko.observable(exists(data.geometry, 'coordinates'))
        });
    };

    self.nameToDisplay = ko.computed(function (){
        var typeToDisplay = 'unknown type';
        if (self.geometry().type == 'LineString') {
            typeToDisplay = 'Line';
        } else if (self.geometry().type == 'Polygon') {
            typeToDisplay = 'Area';
        }
        else if (self.geometry().type == 'Point') {
            typeToDisplay = 'Point';
        }
        var nameToDisplay = typeToDisplay + ' ' + self.name();
        return nameToDisplay;
    });
    
    self.editEvent = function (event) {
        console.log("layer edited");
        // TODO - on edit update coordinates of transectPart.geometry.coordinates 
        console.log("edit", event);
        // console.log("edit layer", event.layer); // undefined
        console.log(self.name(), self.geometry());
        console.log(self.feature);
        self.geometry().coordinates = this.getLatLngs();
        console.log("after", self.geometry());
    }
    self.dragEvent = function (event) {
        console.log("old geometry", self.geometry());

        var lat = event.target.getLatLng().lat;
        var lng = event.target.getLatLng().lng;
        self.geometry().decimalLatitude(lat);
        self.geometry().decimalLongitude(lng);
        self.geometry().coordinates([lng, lat]);
        console.log("new geometry", self.geometry());
    };


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
        return js;
    };
};


