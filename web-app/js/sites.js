
var SiteViewModel = function (site, feature) {
    var self = $.extend(this, new Documents());

    self.site = null;

    self.loadExtent = function(){
        if(self.site && self.site.extent) {
            var extent = self.site.extent;
            switch (extent.source) {
                case 'point':   self.extent(new PointLocation(extent.geometry)); break;
                case 'pid':     self.extent(new PidLocation(extent.geometry)); break;
                case 'upload':  self.extent(new UploadLocation()); break;
                case 'drawn':   self.extent(new DrawnLocation(extent.geometry)); break;
            }
        } else {
            self.extent(new EmptyLocation());
        }
    };

    self.updateExtent = function(source){
        switch (source) {
            case 'point':
                if(site && site.extent) {
                    self.extent(new PointLocation(site.extent.geometry));
                } else {
                    self.extent(new PointLocation({}));
                }
                break;
            case 'pid':
                if(site && site.extent) {
                    self.extent(new PidLocation(site.extent.geometry));
                } else {
                    self.extent(new PidLocation({}));
                }
                break;
            case 'upload': self.extent(new UploadLocation({})); break;
            case 'drawn':
                //breaks the edits....
                self.extent(new DrawnLocation({}));
                break;
            default: self.extent(new EmptyLocation());
        }
    };

    self.loadSite = function(site) {
        self.site = site;
        self.siteId = site.siteId;
        self.name = ko.observable(site.name);
        self.externalId = ko.observable(site.externalId);
        self.type = ko.observable(site.type);
        self.area = ko.observable(site.area);
        self.description = ko.observable(site.description);
        self.notes = ko.observable(site.notes);
        self.extent = ko.observable(new EmptyLocation());
        self.state = ko.observable('');
        self.nrm = ko.observable('');
        self.address = ko.observable("");
        self.feature = feature;
        self.projects = site.projects || [];
        self.extentSource = ko.computed({
            read: function() {
                if (self.extent()) {
                    return self.extent().source();
                }
                return 'none'
            },
            write: function(value) {
                self.updateExtent(value);
            }
        });
        if (site && site.extent) {
            self.extentSource(site.extent.source);
        }
    };

    self.loadSite(site);

    self.setAddress = function (address) {
        if (address.indexOf(', Australia') === address.length - 11) {
            address = address.substr(0, address.length - 11);
        }
        self.address(address);
    };
    self.poi = ko.observableArray();

    self.addPOI = function(poi) {
        self.poi.push(poi);

    };
    self.removePOI = function(poi){
        if (poi.hasPhotoPointDocuments) {
            return;
        }
        self.poi.remove(poi);
    };
    self.toJS = function(){
        var js = ko.mapping.toJS(self, {ignore:self.ignore});
        js.extent = self.extent().toJS();
        js.geoIndex = constructGeoIndexObject(js);

        delete js.extentSource;
        delete js.extentGeometryWatcher;
        delete js.isValid;
        return js;
    };

    // This object is used specifically to create a geospatial index to allow searching by geographic points/regions/bounding boxes.
    // Known regions (e.g. states/territories, etc) are treated as Polygons for the purposes of searching.
    // The structure of the resulting 'geoIndex' object is designed to suit Elastic Search's geo_shape mappings.
    // See https://www.elastic.co/guide/en/elasticsearch/reference/1.7/mapping-geo-shape-type.html for more info
    function constructGeoIndexObject(site) {
        var geoIndex = {};

        if (site && site.extent && site.extent && site.extent.geometry) {
            var geometry = site.extent.geometry;

            if (geometry.type == "Point") {
                geoIndex = {
                    type: geometry.type,
                    coordinates: [geometry.decimalLongitude, geometry.decimalLatitude]
                };
            } else if (geometry.type == "Circle") {
                geoIndex = {
                    type: geometry.type,
                    coordinates: geometry.coordinates,
                    radius: geometry.radius
                };
            } else if (geometry.type == "pid" || geometry.type == "Polygon") {
                geoIndex = {
                    type: "Polygon",
                    coordinates: geometry.type == "pid" ? regionToCoordinatesArray(geometry.bbox) : geometry.coordinates
                };
            }
        }

        return geoIndex;
    }

    function regionToCoordinatesArray(boundingBox) {

        var coordinates = [];

        var pairs = boundingBox.replace(/POLYGON|LINESTRING/g,"").replace(/[\\(|\\)]/g, "").split(",");

        for (var i = 0; i < pairs.length; i++) {
            coordinates.push(pairs[i].split(" "))
        }

        // A polygon is a list of coordinates (i.e. a list of 2 dimensional arrays].
        // The elastic search index requires an array of polygons, so we need an array of arrays of coordinates.
        // e.g.[ [ [ lat1, lon1 ], [ lat2, lon2 ], ... ] ]
        return [coordinates];
    }

    self.modelAsJSON = function() {
        var js = self.toJS();
        return JSON.stringify(js);
    };

    /** Check if the supplied POI has any photos attached to it */
    self.hasPhotoPointDocuments = function(poi) {
        if (!self.site.documents) {
            return;
        }
        var hasDoc = false;
        $.each(self.site.documents, function(i, doc) {
            if (doc.poiId === poi.poiId) {
                hasDoc = true;
                return false;
            }
        });
        return hasDoc;
    };

    self.saved = function(){
        return self.siteId;
    };

    self.loadPOI = function (pois) {
        if (!pois) {
            return;
        }
        $.each(pois, function (i, poi) {
            self.poi.push(new POI(poi, self.hasPhotoPointDocuments(poi)));
        });
    };

    self.refreshGazInfo = function() {

        var geom = self.extent().geometry();
        var lat, lng;
        if (geom.type === 'Point') {
            lat = self.extent().geometry().decimalLatitude();
            lng = self.extent().geometry().decimalLongitude();
        }
        else if (geom.centre !== undefined) {
            lat = self.extent().geometry().centre()[1];
            lng = self.extent().geometry().centre()[0];
        }
        else {
            // No coordinates we can use for the lookup.
            return;
        }

        $.ajax({
            url: fcConfig.siteMetaDataUrl + "?lat=" + lat + "&lon=" + lng,
            dataType: "json"
        })
            .done(function (data) {
                var geom = self.extent().geometry();
                for (var name in data) {
                    if (data.hasOwnProperty(name) && geom.hasOwnProperty(name)) {
                        geom[name](data[name]);
                    }
                }
            });

        //do the google geocode lookup
        $.ajax({
            url: fcConfig.geocodeUrl + "latlng=" + lat + "," + lng,
            async: false
        }).done(function (data) {
            if (data && data.results && data.results.length > 0) {
                self.extent().geometry().locality(data.results[0].formatted_address);
            }
        });
    };

    self.isValid = ko.pureComputed(function() {
        return self.extent() && self.extent().isValid();
    });

    self.loadPOI(site.poi);

    self.loadExtent(site.extent);

    // Watch for changes to the extent content and notify subscribers when they do.
    self.extentGeometryWatcher = ko.pureComputed(function() {
        // We care about changes to either the geometry coordinates or the PID in the case of known shape.
        var result = {};
        if (self.extent()) {
            var geom = self.extent().geometry();
            if (geom) {
                if (geom.decimalLatitude) result.decimalLatitude = ko.utils.unwrapObservable(geom.decimalLatitude);
                if (geom.decimalLongitude) result.decimalLongitude = ko.utils.unwrapObservable(geom.decimalLongitude);
                if (geom.coordinates) result.coordinates = ko.utils.unwrapObservable(geom.coordinates);
                if (geom.pid) result.pid = ko.utils.unwrapObservable(geom.pid);
                if (geom.fid) result.fid = ko.utils.unwrapObservable(geom.fid);
            }
        }

        return result;
    });
};

var POI = function (l, hasDocuments) {
    var self = this;
    self.poiId = ko.observable(exists(l, 'poiId'));
    self.name = ko.observable(exists(l,'name'));
    self.type = ko.observable(exists(l,'type'));
    self.hasPhotoPointDocuments = hasDocuments;
    var storedGeom;
    if(l !== undefined){
        storedGeom = l.geometry;
    }
    self.dragEvent = function(lat,lng){
        self.geometry().decimalLatitude(lat);
        self.geometry().decimalLongitude(lng);
    };
    self.description = ko.observable(exists(l,'description'));
    self.geometry = ko.observable({
        type: "Point",
        decimalLatitude: ko.observable(exists(storedGeom,'decimalLatitude')),
        decimalLongitude: ko.observable(exists(storedGeom,'decimalLongitude')),
        uncertainty: ko.observable(exists(storedGeom,'uncertainty')),
        precision: ko.observable(exists(storedGeom,'precision')),
        datum: ko.observable(exists(storedGeom,'datum')),
        bearing: ko.observable(exists(storedGeom,'bearing'))
    });
    self.hasCoordinate = function () {
        var hasCoordinate = self.geometry().decimalLatitude() !== undefined
            && self.geometry().decimalLatitude() !== ''
            && self.geometry().decimalLongitude() !== undefined
            && self.geometry().decimalLongitude() !== '';

        return hasCoordinate;
    };
    self.toJSON = function(){
        var js = ko.toJS(self);
        delete js.hasPhotoPointDocuments;
        if(js.geometry.decimalLatitude !== undefined
            && js.geometry.decimalLatitude !== ''
            && js.geometry.decimalLongitude !== undefined
            && js.geometry.decimalLongitude !== ''){
            js.geometry.coordinates = [js.geometry.decimalLongitude, js.geometry.decimalLatitude]
        }
        return js;
    }
};

var EmptyLocation = function () {
    this.source = ko.observable('none');
    this.geometry = ko.observable({type:'empty'});
    this.isValid = function() {
        return false;
    };
    this.toJS = function() {
        return {};
    };
};
var PointLocation = function (l) {
    var self = this;
    self.transients = {};
    self.transients.geocodeAddress = ko.observable();

    self.source = ko.observable('point');
    self.geometry = ko.observable({
        type: "Point",
        decimalLatitude: ko.observable(exists(l,'decimalLatitude')),
        decimalLongitude: ko.observable(exists(l,'decimalLongitude')),
        uncertainty: ko.observable(exists(l,'uncertainty')),
        precision: ko.observable(exists(l,'precision')),
        datum: ko.observable('WGS84'), // only supporting WGS84 at the moment.
        nrm: ko.observable(exists(l,'nrm')),
        state: ko.observable(exists(l,'state')),
        lga: ko.observable(exists(l,'lga')),
        locality: ko.observable(exists(l,'locality')),
        mvg: ko.observable(exists(l,'mvg')),
        mvs: ko.observable(exists(l,'mvs'))
    });

    self.hasCoordinate = function () {
        var hasCoordinate = self.geometry().decimalLatitude() !== undefined
            && self.geometry().decimalLatitude() !== ''
            && self.geometry().decimalLongitude() !== undefined
            && self.geometry().decimalLongitude() !== '';
        return hasCoordinate;
    };
    self.geometry.coordinates = ko.pureComputed(function() {
        if (self.hasCoordinate()) {
            return [self.geometry().decimalLongitude(), self.geometry().decimalLatitude()];
        }
        return undefined;
    });

    /**
     * This is called only from a map drag event so we clear uncertaintly, precision and intercept data.
     * The intercept data will be updated once the drag event ends
     */
    self.updateGeometry = function(latlng) {
        var geom = self.geometry();
        geom.decimalLatitude(latlng.lat());
        geom.decimalLongitude(latlng.lng());
        geom.uncertainty('');
        geom.precision('');
        self.clearGazInfo();
    };
    self.clearGazInfo = function() {
        var geom = self.geometry();
        geom.nrm('');
        geom.state('');
        geom.lga('');
        geom.locality('');
        geom.mvg('');
        geom.mvs('');
    };

    self.isValid = function() {
        return self.hasCoordinate();
    };

    self.toJS = function(){
        var js = ko.toJS(self);
        if(js.geometry.decimalLatitude !== undefined
            && js.geometry.decimalLatitude !== ''
            && js.geometry.decimalLongitude !== undefined
            && js.geometry.decimalLongitude !== '') {
            js.geometry.centre = [js.geometry.decimalLongitude, js.geometry.decimalLatitude];
            js.geometry.coordinates = [js.geometry.decimalLongitude, js.geometry.decimalLatitude];
        }
        return js;
    };

    self.useMyLocation = function() {
        navigator.geolocation.getCurrentPosition(function(position) {
            self.geometry().decimalLatitude(position.coords.latitude);
            self.geometry().decimalLongitude(position.coords.longitude);
            self.transients.geocodeAddress(null);
        });
    };

    self.geocodeAddress = function() {
        $.ajax({
            url: fcConfig.geocodeUrl,
            data: {
                'address': self.transients.geocodeAddress(),
                'bounds': getMapBounds
            }
        }).done(function (data) {
            if (data.results.length > 0) {
                var res = data.results[0];

                if (res.geometry) {
                    self.geometry().decimalLatitude(res.geometry.location.lat);
                    self.geometry().decimalLongitude(res.geometry.location.lng);
                } else {
                    bootbox.alert("Location coordinates were found, please try a different address");
                }
            } else {
                bootbox.alert('location was not found, try a different address or place name');
            }
        }).fail(function (jqXHR, textStatus, errorThrown) {
            bootbox.alert("Error: " + textStatus + " - " + errorThrown);
        })
    };
};

var DrawnLocation = function (l) {
    var self = this;
    self.source = ko.observable('drawn');
    self.geometry = ko.observable({
        type: ko.observable(exists(l,'type')),
        centre: ko.observable(exists(l,'centre')),
        radius: ko.observable(exists(l,'radius')),
        lga: ko.observable(exists(l,'lga')),
        state: ko.observable(exists(l,'state')),
        locality: ko.observable(exists(l,'locality')),
        nrm: ko.observable(exists(l,'nrm')),
        mvg: ko.observable(exists(l,'mvg')),
        mvs: ko.observable(exists(l,'mvs')),
        areaKmSq: ko.observable(exists(l,'areaKmSq')),
        coordinates: ko.observable(exists(l,'coordinates')),
        bbox: ko.observable(exists(l,'bbox'))
    });
    self.updateGeom = function(l){
        self.geometry().type(exists(l,'type'));
        self.geometry().centre(exists(l,'centre'));
        self.geometry().lga(exists(l,'lga'));
        self.geometry().nrm(exists(l,'nrm'));
        self.geometry().radius(exists(l,'radius'));
        self.geometry().state(exists(l,'state'));
        self.geometry().locality(exists(l,'locality'));
        self.geometry().mvg(exists(l,'mvg'));
        self.geometry().mvs(exists(l,'mvs'));
        self.geometry().areaKmSq(exists(l,'areaKmSq'));
        self.geometry().coordinates(exists(l,'coordinates'));
        self.geometry().bbox(exists(l,'bbox'));
    };
    self.toJS= function() {
        return ko.toJS(self);
    };
    self.isValid = function() {
        return self.geometry().coordinates();
    };
};

var PidLocation = function (l) {
    // These layers are treated specially.
    var USER_UPLOAD_FID = 'c11083';
    var OLD_NRM_LAYER_FID = 'cl916';
    var self = this;
    self.source = ko.observable('pid');
    self.geometry = ko.observable({
        type : "pid",
        pid : ko.observable(exists(l,'pid')),
        name : ko.observable(exists(l,'name')),
        fid : ko.observable(exists(l,'fid')),
        layerName : ko.observable(exists(l,'layerName')),
        area : ko.observable(exists(l,'area')),
        nrm: ko.observable(exists(l,'nrm')),
        state: ko.observable(exists(l,'state')),
        lga: ko.observable(exists(l,'lga')),
        locality: ko.observable(exists(l,'locality')),
        bbox: ko.observable(exists(l, 'bbox')),
        centre:[]
    });
    self.refreshObjectList = function(){
        self.layerObjects([]);
        self.layerObject(undefined);

        if(self.chosenLayer() !== undefined){
            if (self.chosenLayer() != USER_UPLOAD_FID) {
                $.ajax({
                    url: fcConfig.featuresService + '?layerId=' +self.chosenLayer(),
                    dataType:'json'
                }).done(function(data) {
                    self.layerObjects(data);
                    // During initialisation of the object list, any existing value for the chosen layer will have
                    // been set to undefined because it can't match a value in the list.
                    if (l.pid) {
                        self.layerObject(l.pid);
                    }
                });
            }
            else {
                self.layerObjects([{name:'User Uploaded', pid:self.geometry().pid()}]);
                if (l.pid) {
                    self.layerObject(l.pid);
                }
            }
        }
    }
    //TODO load this from config
    self.layers = ko.observable([
        {id:'cl2111', name:'NRM'},
        {id:'cl1048', name:'IBRA 7 Regions'},
        {id:'cl1049', name:'IBRA 7 Subregions'},
        {id:'cl22',name:'Australian states'},
        {id:'cl959', name:'Local Gov. Areas'}
    ]);
    // These layers aren't selectable unless the site is already using them.  This is to support user uploaded
    // shapes and the previous version of the NRM layer.
    if (l.fid == USER_UPLOAD_FID) {
        self.layers().push({id:USER_UPLOAD_FID, name:'User Uploaded'});
    }
    else if (l.fid == OLD_NRM_LAYER_FID) {
        self.layers().push({id:OLD_NRM_LAYER_FID, name:'NRM Regions - pre 2014'});
    }
    self.chosenLayer = ko.observable(exists(l,'fid'));
    self.layerObjects = ko.observable([]);
    self.layerObject = ko.observable(exists(l,'pid'));

    self.updateSelectedPid = function(elements){
        if(self.layerObject() !== undefined){
            self.geometry().pid(self.layerObject());
            self.geometry().fid(self.chosenLayer());

            //additional metadata required from service layer
            $.ajax({
                url: fcConfig.featureService + '?featureId=' + self.layerObject(),
                dataType:'json'
            }).done(function(data) {
                self.geometry().name(data.name);
                self.geometry().layerName(data.fieldname);
                self.geometry().bbox(data.bbox);
                if(data.area_km !== undefined){
                    self.geometry().area(data.area_km)
                }

            });
        }
    };

    self.toJS = function(){
        var js = ko.toJS(self);
        delete js.layers;
        delete js.layerObjects;
        delete js.layerObject;
        delete js.chosenLayer;
        delete js.type;
        return js;
    };

    self.isValid = function() {
        return self.geometry().fid() && self.geometry().pid() && self.chosenLayer() && self.layerObject();
    };
    self.chosenLayer.subscribe(function() {
        self.refreshObjectList();
    });
    self.layerObject.subscribe(function() {
        self.updateSelectedPid();
    });
    if (exists(l,'fid')) {
        self.refreshObjectList();
    }
    else {
        // Uploaded shapes are created without a field id - assign it the correct FID.
        if (exists(l, 'pid')) {
            self.layers().push({id:USER_UPLOAD_FID, name:'User Uploaded'});
            self.chosenLayer(USER_UPLOAD_FID);

        }
    }
};

function SiteViewModelWithMapIntegration (siteData, options) {
    options = populateMissingOptions(options);

    var self = this;
    SiteViewModel.apply(self, [siteData]);
    self.transients = {
        map: null
    };

    self.renderPOIs = function(){
        removeMarkers();
        for(var i=0; i<self.poi().length; i++){
            addMarker(self.poi()[i].geometry().decimalLatitude(), self.poi()[i].geometry().decimalLongitude(), self.poi()[i].name(), self.poi()[i].dragEvent)
        }
    };

    self.newPOI = function(){
        //get the center of the map
        var lngLat = getMapCentre();
        var randomBit = (self.poi().length + 1) /1000;
        var poi = new POI({name:'Point of interest #' + (self.poi().length + 1) , geometry:{decimalLongitude:lngLat[0] - (0.001+randomBit),decimalLatitude:lngLat[1] - (0.001+randomBit)}}, false);
        self.addPOI(poi);
        self.watchPOIGeometryChanges(poi);

    };

    self.notImplemented = function () {
        alert("Not implemented yet.")
    };

    self.watchPOIGeometryChanges = function(poi) {
        poi.geometry().decimalLatitude.subscribe(self.renderPOIs);
        poi.geometry().decimalLongitude.subscribe(self.renderPOIs);
    };

    self.poi.subscribe(self.renderPOIs);

    $.each(self.poi(), function(i, poi) {
        self.watchPOIGeometryChanges(poi);
    });

    self.renderOnMap = function(){
        var currentDrawnShape = ko.toJS(self.extent().geometry);
        //retrieve the current shape if exists
        if(currentDrawnShape !== undefined){
            if(currentDrawnShape.type == 'Polygon'){
                showOnMap('polygon', geoJsonToPath(currentDrawnShape));
                zoomToShapeBounds();
            } else if(currentDrawnShape.type == 'Circle'){
                showOnMap('circle', currentDrawnShape.coordinates[1],currentDrawnShape.coordinates[0],currentDrawnShape.radius);
                zoomToShapeBounds();
            } else if(currentDrawnShape.type == 'Rectangle'){
                var shapeBounds = new google.maps.LatLngBounds(
                    new google.maps.LatLng(currentDrawnShape.minLat,currentDrawnShape.minLon),
                    new google.maps.LatLng(currentDrawnShape.maxLat,currentDrawnShape.maxLon)
                );
                //render on the map
                showOnMap('rectangle', shapeBounds);
                zoomToShapeBounds();
            } else if(currentDrawnShape.type == 'pid'){
                showObjectOnMap(currentDrawnShape.pid);
                //self.extent().setCurrentPID();
            } else if(currentDrawnShape.type == 'Point'){
                showOnMap('point', currentDrawnShape.decimalLatitude, currentDrawnShape.decimalLongitude,'site name');
                if (options.zoomToPoint) {
                    zoomToShapeBounds();
                }
                if (options.showSatelliteOnPoint) {
                    showSatellite();
                }
            }
        }
    };

    self.updateExtent = function(source){
        switch (source) {
            case 'point':
                if(siteData && siteData.extent && siteData.extent.source == source) {
                    self.extent(new PointLocation(siteData.extent.geometry));
                } else {
                    var centre = getMapCentre();
                    self.extent(new PointLocation({decimalLatitude:centre[1], decimalLongitude:centre[0]}));
                }
                break;
            case 'pid':
                if(siteData && siteData.extent && siteData.extent.source == source) {
                    self.extent(new PidLocation(siteData.extent.geometry));
                } else {
                    self.extent(new PidLocation({}));
                }
                break;
            case 'upload':
                self.extent(new UploadLocation({}));
                break;
            case 'drawn':
                if (siteData && siteData.extent && siteData.extent.source == source) {

                }
                else {
                    self.extent(new DrawnLocation({}));
                }
                break;
            default: self.extent(new EmptyLocation());
        }
    };

    self.shapeDrawn = function(source, type, shape) {
        var drawnShape;
        if (source === 'clear') {
            drawnShape = null;

        } else {

            switch (type) {
                case google.maps.drawing.OverlayType.CIRCLE:
                    /*// don't show or set circle props if source is a locality
                     if (source === "user-drawn") {*/
                    var center = shape.getCenter();
                    // set coord display

                    var calcAreaKm = ((3.14 * shape.getRadius() * shape.getRadius())/1000)/1000;

                    //calculate the area
                    drawnShape = {
                        type:'Circle',
                        userDrawn: 'Circle',
                        coordinates:[center.lng(), center.lat()],
                        centre: [center.lng(), center.lat()],
                        radius: shape.getRadius(),
                        areaKmSq:calcAreaKm
                    };
                    break;
                case google.maps.drawing.OverlayType.RECTANGLE:
                    var bounds = shape.getBounds(),
                        sw = bounds.getSouthWest(),
                        ne = bounds.getNorthEast();

                    //calculate the area
                    var mvcArray = new google.maps.MVCArray();
                    mvcArray.push(new google.maps.LatLng(sw.lat(), sw.lng()));
                    mvcArray.push(new google.maps.LatLng(ne.lat(), sw.lng()));
                    mvcArray.push(new google.maps.LatLng(ne.lat(), ne.lng()));
                    mvcArray.push(new google.maps.LatLng(sw.lat(), ne.lng()));
                    mvcArray.push(new google.maps.LatLng(sw.lat(), sw.lng()));

                    var calculatedArea = google.maps.geometry.spherical.computeArea(mvcArray);
                    var calcAreaKm = ((calculatedArea)/1000)/1000;

                    var centreY = (sw.lat() + ne.lat())/2;
                    var centreX =  (sw.lng() + ne.lng())/2;

                    drawnShape = {
                        type: 'Polygon',
                        userDrawn: 'Rectangle',
                        coordinates:[[
                            [sw.lng(),sw.lat()],
                            [sw.lng(),ne.lat()],
                            [ne.lng(),ne.lat()],
                            [ne.lng(),sw.lat()],
                            [sw.lng(),sw.lat()]
                        ]],
                        bbox:[sw.lat(),sw.lng(),ne.lat(),ne.lng()],
                        areaKmSq:calcAreaKm,
                        centre: [centreX,centreY]
                    };
                    break;
                case google.maps.drawing.OverlayType.POLYGON:
                    /*
                     * Note that the path received from the drawing manager does not end by repeating the starting
                     * point (number coords = number vertices). However the path derived from a WKT does repeat
                     * (num coords = num vertices + 1). So we need to check whether the last coord is the same as the
                     * first and if so ignore it.
                     */
                    var path;

                    if(shape.getPath()){
                        path = shape.getPath();
                    } else {
                        path = shape;
                    }

                    //calculate the area
                    var calculatedAreaInSqM = google.maps.geometry.spherical.computeArea(path);
                    var calcAreaKm = ((calculatedAreaInSqM)/1000)/1000;


                    //get the centre point of a polygon ??
                    var minLat=90,
                        minLng=180,
                        maxLat=-90,
                        maxLng=-180;

                    // There appears to have been an API change here - this is required locally but it
                    // still works without this change in test and prod.
                    var pathArray = path;
                    if (typeof(path.getArray) === 'function') {
                        pathArray = path.getArray();
                    }
                    $.each(pathArray, function(i){
                        var coord = path.getAt(i);
                        if(coord.lat()>maxLat) maxLat = coord.lat();
                        if(coord.lat()<minLat) minLat = coord.lat();
                        if(coord.lng()>maxLng) maxLng = coord.lng();
                        if(coord.lng()<minLng) minLng = coord.lng();
                    });
                    var centreX = minLng + ((maxLng - minLng) / 2);
                    var centreY = minLat + ((maxLat - minLat) / 2);

                    var polygonCoords = polygonToGeoJson(path);

                    drawnShape = {
                        type:'Polygon',
                        userDrawn: 'Polygon',
                        coordinates: polygonCoords,
                        bbox: polygonCoords,
                        areaKmSq: calcAreaKm,
                        centre: [centreX,centreY]
                    };
                    break;
                case google.maps.drawing.OverlayType.MARKER:

                    // Updating the point coordinates refreshes the map so don't do so until the drag is finished.
                    if (!shape.dragging) {
                        self.extent().updateGeometry(shape.getPosition());
                        self.refreshGazInfo();
                    }

                    break;
            }

        }
        //set the drawn shape
        if(drawnShape != null && type !== google.maps.drawing.OverlayType.MARKER){
            self.extent().updateGeom(drawnShape);
            self.refreshGazInfo();
        }
    };

    self.setMap = function(map) {
        self.transients.map = map;
    };

    self.initialiseMap = function(SERVER_CONF) {
        var map = init_map({
            spatialService: SERVER_CONF.spatialService,
            spatialWms: SERVER_CONF.spatialWms,
            mapContainer: 'mapForExtent'
        });

        var updating = false;
        self.setMap(map);
        self.renderPOIs();
        self.renderOnMap();
        var clearAndRedraw = function() {
            if (!updating) {
                updating = true;
                setTimeout(function () {
                    clearObjectsAndShapes();
                    self.renderOnMap();
                    updating = false;
                }, 500);
            }
        };
        setCurrentShapeCallback(self.shapeDrawn);
        self.extent.subscribe(function(newExtent) {
            clearAndRedraw();
        });
        self.extentGeometryWatcher.subscribe(function() {
            clearAndRedraw();
        });

    };

    /**
     * Allows the jquery-validation-engine to respond to changes to the validity of a site extent.
     * This function returns a function that can be attached to an element via the funcCall[] validation method.
     */
    self.attachExtentValidation = function(fieldSelector, message) {
        // Expose the siteViewModel validate function in global scope so the validation engine can use it.
        var validateSiteExtent = function() {
            var result = self.isValid();
            if (!result) {
                return message || 'Please define the site extent';
            }
        };
        self.isValid.subscribe(function() {
            $(fieldSelector).validationEngine('validate');
        });
        return validateSiteExtent;
    };

    function populateMissingOptions(options) {
        if (!options) {
            options = {
                zoomToPoint: true,
                showSatelliteOnPoint: true
            };
        }

        if (typeof options.showSatelliteOnPoint === 'undefined') {
            options.showSatelliteOnPoint = true;
        }

        if (typeof options.zoomToPoint === 'undefined') {
            options.zoomToPoint = true;
        }

        return options;
    }
};


var SitesViewModel =  function(sites, map, mapFeatures, isUserEditor) {

    var self = this;
    // sites
    var features = [];
    if (mapFeatures.features) {
        features = mapFeatures.features;
    }
    self.sites = $.map(sites, function (site, i) {
        var feature = features[i] || site.extent ? site.extent.geometry : null;
        site.feature = feature;
        return site;
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
    self.clearSiteFilter = function () {
        self.sitesFilter("");
    };
    self.nextPage = function () {
        self.offset(self.offset() + self.pageSize);
        self.displaySites();
    };
    self.prevPage = function () {
        self.offset(self.offset() - self.pageSize);
        self.displaySites();
    };
    self.displaySites = function () {
        map.clearFeatures();

        self.displayedSites(self.filteredSites.slice(self.offset(), self.offset() + self.pageSize));

        var features = $.map(self.displayedSites(), function (obj, i) {
            return obj.feature;
        });
        map.replaceAllFeatures(features);

    };

    self.throttledFilter.subscribe(function (val) {
        self.offset(0);

        self.filterSites(val);
    });

    self.filterSites = function (filter) {
        if (filter) {
            var regex = new RegExp('\\b' + filter, 'i');

            self.filteredSites([]);
            $.each(self.sites, function (i, site) {
                if (regex.test(ko.utils.unwrapObservable(site.name))) {
                    self.filteredSites.push(site);
                }
            });
            self.displaySites();
        }
        else {
            self.filteredSites(self.sites);
            self.displaySites();
        }
    };
    self.clearFilter = function (model, event) {

        self.sitesFilter("");
    };

    this.highlight = function () {
        map.highlightFeatureById(ko.utils.unwrapObservable(this.name));
    };
    this.unhighlight = function () {
        map.unHighlightFeatureById(ko.utils.unwrapObservable(this.name));
    };
    this.removeAllSites = function () {
        bootbox.confirm("Are you sure you want to remove these sites? This will remove the links to this project but will NOT remove the sites from the site.", function (result) {
            if (result) {
                var that = this;
                $.get(fcConfig.sitesDeleteUrl, function (data) {
                    if (data.status === 'deleted') {
                        //self.sites.remove(that);
                    }
                    //FIXME - currently doing a page reload, not nice
                    document.location.href = here;
                });
            }
        });
    };
    this.editSite = function (site) {
        var url = fcConfig.siteEditUrl + '/' + site.siteId + '?returnTo=' + fcConfig.returnTo;
        document.location.href = url;
    };
    this.deleteSite = function (site) {
        bootbox.confirm("Are you sure you want to remove this site from this project?", function (result) {
            if (result) {

                $.get(fcConfig.siteDeleteUrl + '?siteId=' + site.siteId, function (data) {
                    $.each(self.sites, function (i, tmpSite) {
                        if (site.siteId === tmpSite.siteId) {
                            self.sites.splice(i, 1);
                            return false;
                        }
                    });
                    self.filterSites(self.sitesFilter());
                });

            }
        });
    };
    this.viewSite = function (site) {
        var url = fcConfig.siteViewUrl + '/' + site.siteId + '?returnTo=' + fcConfig.returnTo;
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
    self.triggerGeocoding = function () {
        ko.utils.arrayForEach(self.sites, function (site) {
            map.getAddressById(site.name(), site.setAddress);
        });
    };

    self.displaySites();
};

function geoJsonToPath(geojson){
    var coords = geojson.coordinates[0];
    return coordArrayToPath(geojson.coordinates[0]);
}

function coordArrayToPath(coords){
    var path = [];
    for(var i = 0; i<coords.length; i++){
        path.push(new google.maps.LatLng(coords[i][1],coords[i][0]));
    }
    return path;
}

/**
 * Returns a GeoJson coordinate array for the polygon
 */
function polygonToGeoJson(path){
    var firstPoint = path.getAt(0),
        points = [];
    path.forEach(function (obj, i) {
        points.push([obj.lng(),obj.lat()]);
    });
    // a polygon array from the drawingManager will not have a closing point
    // but one that has been drawn from a wkt will have - so only add closing
    // point if the first and last don't match
    if (!firstPoint.equals(path.getAt(path.length -1))) {
        // add first points at end
        points.push([firstPoint.lng(),firstPoint.lat()]);
    }
    var coordinates =  [points];
    return coordinates;
}

function round(number, places) {
    var p = places || 4;
    return places === 0 ? number.toFixed() : number.toFixed(p);
}

function representsRectangle(path) {
    // must have 5 points
    if (path.getLength() !== 5) {
        return false;
    }
    var arr = path.getArray();
    if ($.isArray(arr[0])) {
        return false;
    }  // must be multipolygon (array of arrays)
    if (arr[0].lng() != arr[1].lng()) {
        return false;
    }
    if (arr[2].lng() != arr[3].lng()) {
        return false;
    }
    if (arr[0].lat() != arr[3].lat()) {
        return false;
    }
    if (arr[1].lat() != arr[2].lat()) {
        return false;
    }
    return true
}