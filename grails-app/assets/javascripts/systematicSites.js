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



    self.addTransectPartFromMap = function () {

        var featuresAreDrawn = getTransectPart();
        var layersCount = self.map.countFeatures();
        console.log("layers", layersCount);
        var countTransectParts = self.transectParts().length;
        console.log("transect parts", countTransectParts);

        if (featuresAreDrawn && layersCount == countTransectParts){
            console.log("add first sites");
            self.renderTransect();
        } else if (featuresAreDrawn && layersCount < countTransectParts) {
            console.log("add the newly drawn sites");
            self.renderTransect();
        } else {
            alert("Draw on the map first.");
        }

    };

    function createTransectPart(lngLatFeature) {

        var transectPart = new TransectPart(lngLatFeature);
        var geometry = lngLatFeature.geometry;
        var coordinates = geometry.coordinates;

        var typeToDisplay = "unknown type";
        if (geometry.type == 'LineString') {
            typeToDisplay = 'Line';
        } else if (geometry.type == 'Polygon') {
            typeToDisplay = 'Area';
        }
        else if (geometry.type == 'Point') {
            typeToDisplay = 'Point';
        }
        var popup = typeToDisplay + String(lngLatFeature.name);

        /* a geometry to display on leaflet map will be created here so coordinate order needs to be changed
        from [lng, lat] to [lat, lng] */
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
        transectPart.feature.on("mouseover", transectPart.select);
        transectPart.feature.on("mouseout", transectPart.deselect);

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

        transectFeatureGroup.eachLayer(function(layer) {
            layer.on("dragend", layer.dragEvent);
            layer.on("edit", layer.editEvent)
        });

        self.map.getMapImpl();
        self.map.addLayer(transectFeatureGroup);
        self.map.fitBounds();
    }

    self.removeTransectPart = function (transectPart) {
        self.transectParts.remove(transectPart);
        transectFeatureGroup.removeLayer(transectPart.feature);
        // self.renderTransectParts();
        // self.map.removeLayer(transectPart.feature);
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

        // self.map.registerListener(
        // "draw:editstop", function (e) {
        //     console.log("editstop");
        // });

        // self.map.registerListener(
        //     "draw:edited", function (e) {
        //         var layers = e.layers;
        //         layers.eachLayer(function(layer) {
        //             layerId = transectFeatureGroup.getLayerId(layer);
        //         })
        //     });
    }


    function getTransectPart() {
        var geoJson = self.map.getGeoJSON();
        // TODO don't get all features but only ones that were added after the button was clicked
        // self.map.resetMap();
        
        var features = geoJson.features;
        console.log(features);
        
        if (features && features.length > 0) {
            var i = self.transectParts().length;
            var index = 0; 
            if (i == 0){
                index  = 0;
            } else if (i > 0){
                index = 1; 
            }
            for (index; index < features.length; index++){
                var name = self.transectParts().length + 1;
                createTransectPart({
                    name: name,
                    geometry: {
                        type: features[index].geometry.type,
                        coordinates: features[index].geometry.coordinates
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
    self.detailAddedByUser = ko.observableArray("");
    self.addDetail = function() {
        if (self.detailAddedByUser() != "") {
            self.detail.push(self.detailAddedByUser()); // Adds the item. 
            self.detailAddedByUser(""); // Clears the text box, because it's bound to the "detailAddedByUser" observable
        }
    };
    self.removeDetail = function() {
        self.detail.remove(this);    
    }
    self.habitatList = ko.observableArray(['Lövskog', 'Blandskog', 'Barrskog', 'Hygge', 'Buskmark', 'Alvamark', 
        'Ljunghed', 'Sanddynområde', 'Betesmark', 'Åkermark', 'Kärr', 'Mosse', 'Havsstrandsdäng', 
        'Strandäng vid sjö eller vattendrag', 'Bebyggelse och trädgård', 'Häll- eller blockmark',
        'Fjällterräng']);
    self.habitat = ko.observableArray(exists(data, 'habitat'));
    self.habitatAddedByUser = ko.observableArray("");
    self.addHabitat = function() {
        if (self.habitatAddedByUser() != "") {
            self.habitat.push(self.habitatAddedByUser()); 
            self.habitatAddedByUser(""); // Clears the text box
        }
    };
    // self.habitatList = ko.observableArray(['Lövskog', 'Blandskog', 'Barrskog', 'Hygge']);
    // self.habitat = ko.observableArray([
    //     { fromList: ko.observableArray(exists(data.habitat, 'fromList')), 
    //     userGenerated: ko.observableArray(exists(data.habitat, 'userGenerated')) }
    // ]);
    // self.habitatOther = ko.observableArray();
    // self.habitat = ko.observableArray(exists(data, 'habitat'));
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
        var newCoords = this.getLatLngs();
        var coordArray = []; 
        newCoords.forEach(function(coordPair) {
            var lat = coordPair.lat;
            var lng = coordPair.lng;
            coordArray.push([lng, lat])
        });
        console.log(newCoords);
        console.log(coordArray);
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
    self.borderColor = ko.observable('');
    self.select = function() {
        self.borderColor('solid red')
    };
    self.deselect = function() {
        self.borderColor('')
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

// TODO - figure out what happens below!!! 

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
