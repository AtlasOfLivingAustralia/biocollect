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

    
    self.addTransectPartFromMap = function () {

        var featuresAreDrawn = getTransectPart();
        var layersCount = self.map.countFeatures();
        var countTransectParts = self.transectParts().length;

        if (featuresAreDrawn && layersCount == countTransectParts){
            self.renderTransect();
        } else if (featuresAreDrawn && layersCount < countTransectParts) {
            self.renderTransect();
        } else {
            alert("Draw on the map first.");
        }

    };


    function createTransectPart(lngLatFeature) {

        var transectPart = new TransectPart(lngLatFeature);
        var geometry = lngLatFeature.geometry;
        var coordinates = geometry.coordinates;
        var popup = transectPart.name();

        /* a geometry to display on leaflet map will be created here so coordinate order needs to be changed
        from [lng, lat] that came from geoJSON to [lat, lng] for any leaflet feature */
        function toLatLng(lngLatcoords) {
            var latLngCoords = [];
            lngLatcoords.forEach(function(lngLat) {
                var lat = lngLat[1];
                var lng = lngLat[0];
                latLngCoords.push([lat, lng]);
            });
            return latLngCoords;
        }
        if (geometry.type == "Point"){
            transectPart.feature = ALA.MapUtils.createMarker(coordinates[1], coordinates[0], popup, {});
        } else if (geometry.type == "LineString"){
            var latLngCoords = toLatLng(coordinates);
            transectPart.feature = ALA.MapUtils.createSegment(latLngCoords, popup);
        } else if (geometry.type == "Polygon"){
            var latLngCoords = toLatLng(coordinates);
            transectPart.feature = ALA.MapUtils.createPolygon(latLngCoords, popup);
        }
        
        transectPart.feature.on("dragend", transectPart.dragEvent);
        transectPart.feature.on("edit", transectPart.editEvent);
        // on hover change line color to be able to distinguish between adjacent lines  
        if (geometry.type == "LineString"){
            transectPart.feature.on("mouseover", transectPart.highlight);
            transectPart.feature.on("mouseout", transectPart.unhighlight);
        }
        // Add feature to be saved in site collection
        self.transectParts.push(transectPart);
        transectFeatureGroup.addLayer(transectPart.feature);
    }

    self.renderTransect = function(){
        self.map.resetMap();
        self.map.getMapImpl();
        self.map.addLayer(transectFeatureGroup);
        self.map.fitBounds();
    }

    self.removeTransectPart = function (transectPart) {
        self.transectParts.remove(transectPart);
        transectFeatureGroup.removeLayer(transectPart.feature);
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
            var geoType = determineGeoType(event.layerType);
            layer.bindPopup(geoType + count);
        });

        self.loadSite(site);
    }

    // convert feature type into more human-friendly
    function determineGeoType (geoType){
        var type = null;
        if (geoType == 'LineString' || geoType == 'polyline') {
            type = 'Line';
        } else if (geoType == 'Polygon' || geoType == 'polygon') {
            type = 'Area';
        }
        else if (geoType == 'Point' || geoType == 'marker') {
            type = 'Point';
        }
        return type;
    }

    // checks if new features have been drawn on the map - if yes creates new transectPart object from each new feature  
    function getTransectPart() {
        var geoJson = self.map.getGeoJSON();
        var features = geoJson.features;
        
        if (features && features.length > 0) {
            var i = self.transectParts().length;
            var index = 0; 
            if (i == 0){
                index  = 0;
            } else if (i > 0){
                index = 1; 
            }
            
            for (index; index < features.length; index++){
                var geoType = features[index].geometry.type;
                var coordinates = features[index].geometry.coordinates;
                var name = self.transectParts().length + 1;

                createTransectPart({
                    name: determineGeoType(geoType) + String(name),
                    geometry: {
                        type: geoType,
                        coordinates: coordinates
                    }
                });
            }
            return true;     
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
    
    self.detailList = ko.observableArray(['D1. Kraftledningsgata', 'D2. Grusväg', 'D3. Asfaltsväg',
        'D4. Aktivt bete', 'D5. Upphörd hävd', 'D6. Glänta', 'D7. Åkerren', 'D8. Skyddat område']);
    self.detail = ko.observableArray(exists(data, 'detail'));
    self.addDetail = function() {
        self.detail.push(this); 
    };
    self.splitDetailStr = function () {
        console.log(typeof self.detail());
        if (typeof self.detail() == 'string'){
            var detailArray = self.detail().split(",");
            self.detail(detailArray);
        }
        console.log(self.detail());
        return self.detail();
    };

    self.habitatList = ko.observableArray(['Lövskog', 'Blandskog', 'Barrskog', 'Hygge', 'Buskmark', 'Alvamark', 
        'Ljunghed', 'Sanddynområde', 'Betesmark', 'Åkermark', 'Kärr', 'Mosse', 'Havsstrandsdäng', 
        'Strandäng vid sjö eller vattendrag', 'Bebyggelse och trädgård', 'Häll- eller blockmark',
        'Fjällterräng']);
    self.habitat = ko.observableArray(exists(data, 'habitat'));
    self.addHabitat = function() {
        self.habitat.push(this); 
    };
    self.splitHabitatStr = function () {
        if (typeof self.habitat() == 'string'){
            var habitatArray = self.habitat().split(",");
            self.habitat(habitatArray);
        }
        console.log(self.habitat());
        return self.habitat();
    };

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
    
    self.editEvent = function (event) {
        var newCoords = this.getLatLngs();
        var coordArray = []; 
        newCoords.forEach(function(coordPair) {
            var lat = coordPair.lat;
            var lng = coordPair.lng;
            coordArray.push([lng, lat])
        });
        self.geometry().coordinates = coordArray;
    }
    self.dragEvent = function (event) {

        var lat = event.target.getLatLng().lat;
        var lng = event.target.getLatLng().lng;
        self.geometry().decimalLatitude(lat);
        self.geometry().decimalLongitude(lng);
        self.geometry().coordinates([lng, lat]);
    };

    self.highlight = function (){
        this.setStyle({
            'color': '#eb6f10',
            'weight': 4,
            'opacity': 1
        });
    };
    self.unhighlight = function (){
        this.setStyle({
            'color': 'blue',
            'weight': 4,
            'opacity': 1
        });
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
