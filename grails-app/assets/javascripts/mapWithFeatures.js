/*
 *  Copyright (C) 2013 Atlas of Living Australia
 *  All Rights Reserved.
 *
 *  The contents of this file are subject to the Mozilla Public
 *  License Version 1.1 (the "License"); you may not use this file
 *  except in compliance with the License. You may obtain a copy of
 *  the License at http://www.mozilla.org/MPL/
 *
 *  Software distributed under the License is distributed on an "AS
 *  IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 */
/*
 Javascript to support user selection of areas on a Google map.

 */
(function (windows) {
    "use strict";
    /*jslint browser: true, vars: false, white: false, maxerr: 50, indent: 4 */
    /*global google, $ */

    var
    // represents the map and its associated properties and events
        map, prevMarker,

    //  Urls are injected from config
        config = {};

    /*** map represents the map and its associated properties and events ************************************************/
    map = {
        // the google map object
        map: null,
        // the DOM container to draw the map in - can be overridden in init options
        containerId: "map-canvas",
        // geocoder instance for address lookups
        geocoder: null,
        // whether to zoom to bounds when all features are loaded
        zoomToBounds: true,
        // maximum zoom
        zoomLimit: 12,
        // whether to highlight features on hover
        highlightOnHover: false,
        // the generalised features as passed in
        features: {},
        // the created map features (points, polys, etc) indexed by an id
        featureIndex: {},
        // a n incremented counter used as id if no id exists in the feature description
        currentId: 0,
        //default center
        defaultCenter: new google.maps.LatLng(-28.5, 133.5),
        // default site to zoom
        defaultZoomArea: null,
        //default center
        defaultZoom: 3,
        // default overlay options
        overlayOptions: {strokeColor:'#BC2B03',fillColor:'#DF4A21',fillOpacity:0.3,strokeWeight:1,zIndex:1,editable:false},
        // keep count of locations as we load them so we know when we've finished
        locationsLoaded: 0,
        // keep a running bounds for loaded locations so we can zoom when all are loaded
        featureBounds: new google.maps.LatLngBounds(),
        // URL to small dot icon
        smallDotIcon: "https://maps.gstatic.com/intl/en_us/mapfiles/markers2/measle.png", // blue: measle_blue.png

        allMarkers : [],
        // URL to red google marker icon
        redMarkerIcon: "http://www.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png",
        //spatial portal URL
        featureService: "http://fieldcapture.ala.org.au/proxy/feature",
        //WMS server for PID
        wmsServer: "http://spatial-dev.ala.org.au/geoserver",
        // Default size (in km2) below which a marker will be added to a polygon to increase it's visibility
        polygonMarkerAreaKm2 : 0.01,
        // init map and load features
        init: function (options, features) {
            var self = this;
            this.features = features;
            // handle options
            if (options.mapContainer) {
                this.containerId = options.mapContainer;
            }
            if(options.featureService){
                this.featureService = options.featureService;
            }
            if(options.wmsServer){
                this.wmsServer = options.wmsServer;
            }
            if (features.highlightOnHover) {
                this.highlightOnHover = features.highlightOnHover;
            }
            if (options.polygonMarkerAreaKm2 !== undefined) {
                this.polygonMarkerAreaKm2 = this.polygonMarkerAreaKm2;
            }
            this.map = new google.maps.Map(document.getElementById(this.containerId), {
                zoom: 3,
                center: new google.maps.LatLng(-28.5, 133.5),
                panControl: false,
                streetViewControl: false,
                mapTypeControl: true,
                mapTypeId: google.maps.MapTypeId.TERRAIN,
                scrollwheel: options.scrollwheel,
                zoomControlOptions: {
                    style: 'DEFAULT'
                }
            });
            //console.log('[init] ZoomToBounds: ' + features.zoomToBounds);
            //console.log('[init] ZoomLimit: ' + features.zoomLimit);
            if(features.zoomToBounds){ this.zoomToBounds = features.zoomToBounds; }
            if(features.zoomLimit){ this.zoomLimit = features.zoomLimit; }
            if(features.features !== undefined){
                this.load(features.features);
            }
            return this;
        },

        toggleMarkerVisibility:function(type, _map){
            $.each(this.allMarkers, function(idx, marker){
                if(type == marker["legendName"]){
                    marker.marker.setMap(_map);
                }
            });
        },
        reset:function(){
            var self = this;
            self.map.setCenter(self.defaultCenter);
            self.map.setZoom(self.defaultZoom);
            self.featureIndex = {};
            self.featureBounds =  new google.maps.LatLngBounds();
            self.allMarkers = [];
        },
        replaceAllFeatures: function(features) {
            this.features.features = features;
            this.locationsLoaded = 0;
            this.load(features);
        },
        mapSite: function(site){
            var self = this;
            var loaded = self.loadFeature(site.extent.geometry);
            if(loaded){
                self.allLocationsLoaded();
            }
        },
        loadFeature: function(loc, iw){
            var self = this, f;
            var loaded = false;
            if(loc != null && loc.type != null){
                if (loc.type.toLowerCase() === 'point') {
                    var ll = new google.maps.LatLng(Number(loc.coordinates[1]), Number(loc.coordinates[0]));
                    f = new google.maps.Marker({
                        map: self.map,
                        position: ll,
                        title: loc.name
                    });
                    if (!self.defaultZoomArea || self.defaultZoomArea == loc.id) {
                        self.featureBounds.extend(ll);
                    }
                    self.addFeature(f, loc);
                    loaded = true;
                } else if (loc.type === 'dot') {

                    var marker = map.smallDotIcon;
                    if (loc.color != "-1"){
                        // strokeColor is resource hungry. google maps performs well with encoded image data.
                         marker = {
                            url: "data:image/gif;base64,R0lGODlhAQABAPAAA"+encodeHex(loc.color)+"///yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==",
                            scaledSize: new google.maps.Size(5,5)
                        };
                    }

                    var ll = new google.maps.LatLng(Number(loc.latitude), Number(loc.longitude));
                    f = new google.maps.Marker({
                        map: self.map,
                        position: ll,
                        title: loc.name,
                        icon: marker
                    });

                    if(loc.color != "-1"){
                        var markerMap = {};
                        markerMap["legendName"] = loc.legendName;
                        markerMap["marker"] = f;
                        this.allMarkers.push(markerMap);
                    }

                    if (!self.defaultZoomArea || self.defaultZoomArea == loc.id) {
                        self.featureBounds.extend(ll);
                    }

                    self.addFeature(f, loc, iw);
                    loaded = true;
                } else if (loc.type.toLowerCase() === 'circle') {
                    var ll = new google.maps.LatLng(loc.coordinates[1], loc.coordinates[0]);
                    f = new google.maps.Circle({
                        center: ll,
                        radius: loc.radius,
                        map: self.map,
                        editable: false
                    });
                    //set the extend of the map
                    //console.log("f.getBounds()",f.getBounds());
                    if (!self.defaultZoomArea || self.defaultZoomArea == loc.id) {
                        self.featureBounds.extend(f.getBounds().getNorthEast());
                        self.featureBounds.extend(f.getBounds().getSouthWest());
                    }

                    self.addFeature(f, loc, iw);
                    loaded = true;
                } else if (loc.type.toLowerCase() === 'polygon') {
                    var points;
                    var paths = geojsonToPaths(loc.coordinates[0]);
                    f = new google.maps.Polygon({
                        paths: paths,
                        map: self.map,
                        title: 'polygon name',
                        editable: false
                    });
                    f.setOptions(self.overlayOptions);
                    // flatten arrays to array of points
                    points = [].concat.apply([], paths);
                    // extend bounds by each point
                    if (!self.defaultZoomArea || self.defaultZoomArea == loc.id) {
                        $.each(points, function (i,obj) {self.featureBounds.extend(obj);});
                    }

                    self.addFeature(f, loc, iw);
                    loaded = true;
                } else if (loc.type.toLowerCase() === 'pid') {
                    //load the overlay instead
                    var pid = loc.pid;
                    //console.log('Loading PID: ' + pid);
                    f = new PIDLayer(pid, this.wmsServer, loc.style || 'restricted');
                    map.map.overlayMapTypes.push(f);
                    $.ajax({
                        url: this.featureService+ '?featureId=' + pid,
                        dataType:'json'
                    }).done(function(data) {
                        if(data !== undefined && data !== null && data.bbox !== undefined && !loc.excludeBounds){
                            var coords = data.bbox.replace(/POLYGON|LINESTRING/g,"").replace(/[\\(|\\)]/g, "");
                            var pointArray = coords.split(",");
                            if (pointArray.length == 2) {
                                // The bounding box of a point is a linestring with two points
                                pointArray = [pointArray[0], pointArray[1], pointArray[0], pointArray[1]];
                            }
                            if (!self.defaultZoomArea || self.defaultZoomArea == loc.id) {
                                self.featureBounds.extend(new google.maps.LatLng(pointArray[1].split(" ")[1], pointArray[1].split(" ")[0]));
                                self.featureBounds.extend(new google.maps.LatLng(pointArray[3].split(" ")[1], pointArray[3].split(" ")[0]));
                            }
                            if (!loc.areaKmSq) {
                                loc.areaKmSq = data.area_km ? data.area_km : 0;
                            }
                        } else {
//                           self.featureBounds.extend(new google.maps.LatLng(0,0));
//                           self.featureBounds.extend(new google.maps.LatLng(-90, 180));
                        }
                        self.addFeature(f, loc, iw);
                    });
                    loaded = true;
                } else {
                    // count the location as loaded even if we didn't
                    console.log('Feature type not supported: ' + loc.type);
                }
                return loaded;
            }
        },
        // loads the features
        load: function(features) {

            if(features === undefined || features.length == 0){
                return;
            }

            var self = this, iw;

            if (!iw) {
                iw = new google.maps.InfoWindow({maxWidth: 360});
            }

            $.each(features, function (i,loc) {
                //console.log('Loading feature with type:' + loc.type + "|" + loc.latitude);
                if(loc != null){

                    self.loadFeature(loc, iw);
                    //self.locationLoaded();
                }
            });

            self.allLocationsLoaded();
        },
        addFeature: function (f, loc, iw) {
            var self = this;
            if (this.highlightOnHover) {
                google.maps.event.addListener(f, 'mouseover', function () {
                    self.highlightFeature(this);
                });
                google.maps.event.addListener(f, 'mouseout', function () {
                    self.unHighlightFeature(this);
                });
            }
            if (loc.popup && iw) {
                // add infoWindow popup
                google.maps.event.addListener(f, 'click', function(event) {
                    iw.setContent(loc.popup);
                    iw.setPosition(event.latLng);
                    iw.open(self.map, f);
                });

                google.maps.event.addListener(iw, 'closeclick', function(){
                    // catch the close infoWindow event
                    if (prevMarker) prevMarker.setIcon(map.smallDotIcon);
                });
            }

            // Add a marker at the centroid of the polygon for small polygons so they are visible despite the zoom level.
            if (loc.type.toLowerCase() !== 'point' && loc.type.toLowerCase() !== 'dot' && loc.areaKmSq < self.polygonMarkerAreaKm2) {
                if (loc.centre) {
                    var latLng = new google.maps.LatLng(loc.centre[1], loc.centre[0]);
                    var marker = new google.maps.Marker({
                        position: latLng,
                        map: self.map,
                        title:""
                    });
                    loc.marker = marker;
                }

            }
            this.indexFeature(f, loc);
            this.locationLoaded();
        },
        indexFeature: function (f, loc) {
            var id;
            if (loc.id === undefined) {
                id = this.currentId++;
            } else {
                id = loc.id;
            }
            if (this.featureIndex[id] === undefined) { this.featureIndex[id] = []; }
            this.featureIndex[id].push(f);
            if (loc.marker) {
                this.featureIndex[id].push(loc.marker);
            }
        },
        // increments the count of loaded locations - zooms map when all are loaded
        locationLoaded: function () {

            this.locationsLoaded++;
            //console.log("Locations loaded: "+this.locationsLoaded+", feature count: "+this.features.features.length);
            if (this.locationsLoaded === this.features.features.length) {
                // all loaded
                this.allLocationsLoaded();
            }
        },
        // zoom map to show features - but not higher than zoom = 12
        allLocationsLoaded: function () {
            var self = this;
            //console.log('All locations loaded - this.zoomToBounds - ' + this.zoomToBounds + " - zoom limit - " + self.zoomLimit);
            if (this.zoomToBounds) {
                //console.log("Zooming to bounds");
                //console.log(this.featureBounds);
                this.map.fitBounds(this.featureBounds);  // this happens asynchronously so need to wait for bounds to change
                // to sanity-check the zoom level
//                var boundsListener = google.maps.event.addListener(this.map, 'bounds_changed', function(event) {
//                    if (this.getZoom() >= self.zoomLimit){
//                        this.setZoom(self.zoomLimit);
//                    }
//                    google.maps.event.removeListener(boundsListener);
//                });
                //  } else {
                //    console.log("NOT Zooming to bounds");
            }
        },
        //
        highlightFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(features, function (i,f) {
                    self.highlightFeature(f);
                });
            }
        },
        //
        unHighlightFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    self.unHighlightFeature(f);
                });
            }
        },
        //
        highlightFeature: function (f) {
            if (!f) { return; }

            if (f instanceof google.maps.Marker) {
                f.setOptions({icon: 'http://collections.ala.org.au/images/map/orange-dot.png'});
            } else if (f instanceof google.maps.Polygon || f instanceof google.maps.Circle) {
                f.setOptions({
                    fillOpacity:1
                });
            } else if (f instanceof google.maps.ImageMapType) {
                f.setOpacity(1);
            }
            else {
                console.log(f);
            }
        },
        //
        unHighlightFeature: function (f) {
            if (!f) { return; }
            if (f instanceof google.maps.Marker) {
                f.setOptions({icon: null});
            } else if (f instanceof google.maps.Polygon || f instanceof google.maps.Circle) {
                f.setOptions({
                    fillOpacity:0.5
                });
            } else if (f instanceof google.maps.ImageMapType) {
                f.setOpacity(0.5);
            }
        },
        animateFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            var returnVal = false;
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    self.animateFeature(f);
                });
                returnVal = true;
            }
            return returnVal;
        },
        unAnimateFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    self.unAnimateFeature(f);
                });
            }
        },
        animateFeature: function (f) {
            if (!f) { return; }
            if (f instanceof google.maps.Marker) {
                f.setIcon(map.redMarkerIcon);
            }
        },
        unAnimateFeature: function (f) {
            if (!f) { return; }
            if (f instanceof google.maps.Marker) {
                f.setIcon(map.smallDotIcon);
            }
        },
        getExtentByFeatureId: function(id) {
            var features = this.featureIndex[id];
            //console.log("features", id, features);
            if (features) {
                var bounds = new google.maps.LatLngBounds();
                $.each(features, function (i,f) {
                    bounds.extend(f.position);
                });
                return bounds;
            }
        },
        hideFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    f.setVisible(false);
                });
            }
        },
        showFeatureById: function (id) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    f.setVisible(true);
                });
            }
        },
        showAllfeatures: function () {
            $.each(this.featureIndex, function (i, obj) {
                $.each(obj, function (j, f) {
                    f.setVisible(true);
                });
            });
        },
        getAddressById: function (id, callback) {
            var self = this,
                features = this.featureIndex[id];
            if (features) {
                $.each(this.featureIndex[id], function (i,f) {
                    if (f instanceof google.maps.Marker) {
                        if (!self.geocoder) { self.geocoder = new google.maps.Geocoder() }
                        self.geocoder.geocode({location: f.getPosition()},
                            function (results, status) {
                                if (status == google.maps.GeocoderStatus.OK) {
                                    callback(results[0].formatted_address);
                                }
                            });
                    }
                });
            }
        },
        clearFeatures: function(){
            var self = this;
            var overlaysToRemove = [];
            //clear map of features
            $.each(self.featureIndex, function (i, obj) {

                $.each(obj, function (j, f) {
                    if(f.setMap !== undefined){
                        f.setMap(null);
                    }
                    else {
                        self.map.overlayMapTypes.forEach(function(obj, i) {
                            if (obj == f) {
                                overlaysToRemove.push(i);
                            }
                        });
                    }
                });
            });

            // Sort in reverse numeric order so the indexes remain stable as we remove items from the array.
            overlaysToRemove.sort(function(a,b) {
                return b-a;
            });
            $.each(overlaysToRemove, function(i, index){
                self.map.overlayMapTypes.removeAt(index);
            });

            self.reset();

        },

    };

    /*
     * Initialises everything including the map.
     *
     * @param options object specifier with the following members:
     * - mapContainer: id of the html element to hold the map
     * @param features: js representation of the generalised description of features
     */
    function init (options, features) {
        return map.init(options, features);
    }

    function mapSite(site){
        return map.mapSite(site)
    }

    function clearMap(){
        map.clearFeatures();
    }


    var markersArray = [];

    function addMarker(lat, lng, name, dragEvent){

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
    }

    function removeMarkers(){
        if (markersArray) {
            for (var i in markersArray) {
                markersArray[i].setMap(null);
                //markersArray.removeAt(i);
            }
        }
        markersArray = [];
    }

    // expose these methods to the global scope
    windows.init_map_with_features = init;
    windows.mapSite = mapSite;
    windows.clearMap = clearMap;
    windows.addMarker = addMarker;
    windows.removeMarkers = removeMarkers;
    windows.alaMap = map;



}(this));

function geojsonToPaths(obj) {
    return gjToLatLngs(obj);
}

function gjToLatLngs(arr) {
    var i, len = arr.length;
    for (i = 0; i < len; i++) {
        if (isCoord(arr[i])) {
            arr[i] = new google.maps.LatLng(arr[i][1],arr[i][0]);
        } else if ($.isArray(arr[[i]])){
            arr[i] = gjToLatLngs(arr[i]);
        }
    }
    return arr;
}

function isCoord(arr) {
    return arr.length === 2 && !isNaN(arr[0]) && !isNaN(arr[1]);
}

function initialiseState(state) {
    switch (state) {
        case 'Queensland': return 'QLD'; break;
        case 'Victoria': return 'VIC'; break;
        case 'Tasmania': return 'TAS'; break;
        default:
            var words = state.split(' '), initials = '';
            for(var i=0; i < words.length; i++) {
                initials += words[i][0]
            }
            return initials;
    }
}

function encodeHex(s) {
    s = s.substring(1, 7);
    if (s.length < 6) {
        s = s[0]+s[0]+s[1]+s[1]+s[2]+s[2];
    }
    return encodeRGB(parseInt(s[0]+s[1], 16),parseInt(s[2]+s[3], 16), parseInt(s[4]+s[5], 16));
}

function encodeRGB(r, g, b) {
    var k = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    return k.charAt(((0 & 3) << 4) | (r >> 4)) + k.charAt(((r & 15) << 2) | (g >> 6)) +
        k.charAt(g & 63) + k.charAt(b >> 2) + k.charAt(((b & 3) << 4) | (255 >> 4))
}