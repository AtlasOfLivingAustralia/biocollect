'use strict';

var SystematicSiteViewModel = function (mapContainerId, site, mapOptions) {

    var self = $.extend(this, new Documents());

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
    self.displayAreaInReadableFormat = null; //because the extention is a centroid - a point

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
            console.log("check for transect");
            site.transectParts.forEach(function (transectPart) {
                createTransectPart(transectPart);
                var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(transectPart.geometry);
                self.map.setGeoJSON(validGeoJson);
                // self.showPointAttributes(geometry.type == "Point");
            });
            // self.renderTransectParts(transectParts);

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

        if (!_.isEmpty(geometry) && self.site().extent().source() != 'none') {
            var validGeoJson = Biocollect.MapUtilities.featureToValidGeoJson(geometry);
            self.map.setGeoJSON(validGeoJson);
            self.showPointAttributes(geometry.type == "Point");
        }

        return geometryObservable;
    };

    self.newTransectPart = function () {
        // get features drawn on the map
        getTransectPart();

        // iterate on features and add them to map individually 
        // transectFeatureGroup.eachLayer(function(e) { 
        //     console.log(typeof e);
        //     let layer = e.target;
        //     layer.bindPopup('popup');
        //     layer.bindTooltip('label') 
        //     return layer  
        //     })
        // transectFeatureGroup.addTo(self.map);
    };

    // TODO a function to check whether features are drawn on map
    // displays prompt to draw on map first 
    self.noFeaturesAreDrawn = function () {
        var featuresAreDrawn = false;
        var geoJson = self.map.getGeoJSON();
        if (geoJson.features.length < 1){
            featuresAreDrawn = true;
        }
        return featuresAreDrawn;
    }

    // TODO
    // called both for creating a new transect part and for reading an existing one from the site to be edited 
    function createTransectPart(feature) {
        console.log("feature", feature)

        console.log("recreate parts")
        var transectPart = new TransectPart(feature);
        var label = transectPart.name();
        if (feature.geometry.type == "LineString"){
            transectPart.feature = ALA.MapUtils.createSegment(feature.geometry.coordinates, label);
        } else if (feature.geometry.type == "Point"){
            transectPart.feature = ALA.MapUtils.createMarker(feature.geometry.coordinates[1],feature.geometry.coordinates[0], label, {});
        } else if (feature.geometry.type == "Polygon"){
            transectPart.feature = ALA.MapUtils.createPolygon(feature.geometry.coordinates,label);
        }
        console.log("tra part", transectPart);
        // transectPart.feature.on("click", transectPart.editEvent);
        // Add feature to the FeatureGroup that displays on map
        // var layer = transectPart.feature;
        // console.log(typeof layer);
        // transectFeatureGroup.addLayer(layer);
        // Add feature to be saved in site collection
        self.transectParts.push(transectPart);
    }

    self.renderTransectParts = function () { 
        console.log("rendering");
        // transectFeatureGroup.clearLayers();
        // TODO remove the layer or call mapimpl to nullify everything
        // console.log(transectParts);
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
            console.log(typeof feature);
            // feature.on("click", transectPart.editEvent);

            // transectFeatureGroup.addLayer(feature);
            // console.log('featuregroup',transectFeatureGroup);
            self.map.addLayer(feature.layer);
        });
        
    };

    self.removeTransectPart = function (transectPart) {
        self.transectParts.remove(transectPart);
        self.renderTransectParts();
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

        self.map.subscribe(listenToSiteChanges);
    }

    function listenToSiteChanges () {
        console.log("site changes");
    }


    function getTransectPart() {
        // self.map.modifyDrawnItems();
        var geoJson = self.map.getGeoJSON();
        console.log("geojson", geoJson);
        var features = geoJson.features;
        console.log("features from map:", features);

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
    self.detailSelected = ko.observableArray();
    self.detailOther = ko.observableArray();
    self.detail = ko.computed(function(){
            return self.detailSelected().concat(self.detailOther());
    });
    self.habitatList = ko.observableArray(['Lövskog', 'Blandskog', 'Barrskog', 'Hygge']);
    self.habitatSelected = ko.observableArray();
    self.habitatOther = ko.observableArray();
    self.habitat = ko.computed(function(){
        return self.habitatSelected().concat(self.habitatOther());
    });
    self.length = null;

    // create geometry
    if (!_.isUndefined(data.geometry)) {
        var geoType = data.geometry.type;
        self.geometry = ko.observable({
            type: geoType,
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


