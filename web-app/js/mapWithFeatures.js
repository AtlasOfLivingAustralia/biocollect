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

function MapWithFeatures(options, features) {
    "use strict";
    /*jslint browser: true, vars: false, white: false, maxerr: 50, indent: 4 */
    /*global google, $ */

    var self = this;

    var prevMarker;

    // the DOM container to draw the map in - can be overridden in init options
    self.containerId = options.containerId ? options.containerId : "map-canvas";
    // geocoder instance for address lookups
    self.geocoder = null;
    // whether to zoom to bounds when all features are loaded
    self.zoomToBounds = true;
    // maximum zoom
    self.zoomLimit = 12;
    // whether to highlight features on hover
    self.highlightOnHover = false;
    // the generalised features as passed in
    self.features = {};
    // the created map features (points, polys, etc) indexed by an id
    self.featureIndex = {};
    // a n incremented counter used as id if no id exists in the feature description
    self.currentId = 0;
    //default center
    self.defaultCenter = new google.maps.LatLng(-28.5, 133.5);
    //default center
    self.defaultZoom = 3;
    // default overlay options
    self.overlayOptions = {
        strokeColor: '#BC2B03',
        fillColor: '#DF4A21',
        fillOpacity: 0.3,
        strokeWeight: 1,
        zIndex: 1,
        editable: false
    };
    // keep count of locations as we load them so we know when we've finished
    self.locationsLoaded = 0;
    // keep a running bounds for loaded locations so we can zoom when all are loaded
    self.featureBounds = new google.maps.LatLngBounds();
    // URL to small dot icon
    self.smallDotIcon = "https://maps.gstatic.com/intl/en_us/mapfiles/markers2/measle.png"; // blue: measle_blue.png

    self.allMarkers = [];
    // URL to red google marker icon
    self.redMarkerIcon = "http://www.google.com/intl/en_us/mapfiles/ms/micons/red-dot.png";
    //spatial portal URL
    self.featureService = "http://biocollect.ala.org.au/proxy/feature";
    // WMS server for PID
    self.wmsServer = "http://spatial-dev.ala.org.au/geoserver";
    // Default size (in km2) below which a marker will be added to a polygon to increase it's visibility
    self.polygonMarkerAreaKm2 = 0.01;

    // init map and load features
    function init(options, features) {
        if (typeof options === "undefined") {
            options = {};
        }
        if (typeof features === "undefined") {
            features = {};
        }

        if (options.mapContainer) {
            self.containerId = options.mapContainer;
        }
        if (options.featureService) {
            self.featureService = options.featureService;
        }
        if (options.wmsServer) {
            self.wmsServer = options.wmsServer;
        }
        if (options.polygonMarkerAreaKm2 !== undefined) {
            self.polygonMarkerAreaKm2 = options.polygonMarkerAreaKm2;
        }

        if (features.highlightOnHover) {
            self.highlightOnHover = features.highlightOnHover;
        }

        var mapContainer = document.getElementById(self.containerId);
        if (!mapContainer || typeof mapContainer === "undefined") {
            console.log("No map container found for id " + self.containerId);
            return;
        }

        console.log('Creating map with container id = ' + self.containerId);
        self.map = new google.maps.Map(mapContainer, {
            zoom: options.zoom ? options.zoom : 3,
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

        if (features.zoomToBounds) {
            self.zoomToBounds = features.zoomToBounds;
        }
        if (features.zoomLimit) {
            self.zoomLimit = features.zoomLimit;
        }
        if (features.features !== undefined) {
            self.load(features.features);
        }
    }

    self.toggleMarkerVisibility = function (type, _map) {
        $.each(self.allMarkers, function (idx, marker) {
            if (type == marker["legendName"]) {
                marker.marker.setMap(_map);
            }
        });
    };

    self.reset = function () {
        if (typeof self.map !== "undefined") {
            self.map.setCenter(self.defaultCenter);
            self.map.setZoom(self.defaultZoom);
            self.featureIndex = {};
            self.featureBounds = new google.maps.LatLngBounds();
            self.allMarkers = [];
        }
    };

    self.replaceAllFeatures = function (features) {
        self.features = features;
        self.locationsLoaded = 0;
        self.load(features);
    };

    self.mapSite = function (site) {
        var feature = self.loadFeature(site.extent.geometry);
        if (feature != null) {
            self.allLocationsLoaded();
        }
    };

    self.loadFeature = function (loc, iw) {
        var feature;

        if (loc != null && loc.type != null) {
            if (loc.type.toLowerCase() === 'point') {
                var point = null;
                // assume the center of the map if no other coordinates have been provided
                if (typeof loc.coordinates === "undefined") {
                    point = self.map.getCenter();
                } else {
                    point = new google.maps.LatLng(Number(loc.coordinates[1]), Number(loc.coordinates[0]));
                }

                feature = new google.maps.Marker({
                    map: self.map,
                    position: point,
                    title: loc.name,
                    draggable: loc.draggable
                });

                self.featureBounds.extend(point);
                self.addFeature(feature, loc);
            } else if (loc.type === 'dot') {
                var marker = map.smallDotIcon;

                if (loc.color != "-1") {
                    // strokeColor is resource hungry. google maps performs well with encoded image data.
                    marker = {
                        url: "data:image/gif;base64,R0lGODlhAQABAPAAA" + encodeHex(loc.color) + "///yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==",
                        scaledSize: new google.maps.Size(5, 5)
                    };
                }

                var ll = new google.maps.LatLng(Number(loc.latitude), Number(loc.longitude));
                feature = new google.maps.Marker({
                    map: self.map,
                    position: ll,
                    title: loc.name,
                    icon: marker
                });

                if (loc.color != "-1") {
                    var markerMap = {};
                    markerMap["legendName"] = loc.legendName;
                    markerMap["marker"] = feature;
                    self.allMarkers.push(markerMap);
                }

                self.featureBounds.extend(ll);
                self.addFeature(feature, loc, iw);

            } else if (loc.type.toLowerCase() === 'circle') {
                var ll = new google.maps.LatLng(loc.coordinates[1], loc.coordinates[0]);
                feature = new google.maps.Circle({
                    center: ll,
                    radius: loc.radius,
                    map: self.map,
                    editable: false
                });
                //set the extend of the map
                self.featureBounds.extend(feature.getBounds().getNorthEast());
                self.featureBounds.extend(feature.getBounds().getSouthWest());
                self.addFeature(feature, loc, iw);

            } else if (loc.type.toLowerCase() === 'polygon') {
                var points;
                var paths = geojsonToPaths(loc.coordinates[0]);
                feature = new google.maps.Polygon({
                    paths: paths,
                    map: self.map,
                    title: 'polygon name',
                    editable: false
                });
                feature.setOptions(self.overlayOptions);
                // flatten arrays to array of points
                points = [].concat.apply([], paths);
                // extend bounds by each point
                $.each(points, function (i, obj) {
                    self.featureBounds.extend(obj);
                });
                self.addFeature(feature, loc, iw);

            } else if (loc.type.toLowerCase() === 'pid') {
                //load the overlay instead
                var pid = loc.pid;

                feature = new PIDLayer(pid, this.wmsServer, loc.style);
                map.map.overlayMapTypes.push(feature);

                $.ajax({
                    url: this.featureService + '?featureId=' + pid,
                    dataType: 'json'
                }).done(function (data) {
                    if (data !== undefined && data !== null && data.bbox !== undefined && !loc.excludeBounds) {
                        var coords = data.bbox.replace(/POLYGON|LINESTRING/g, "").replace(/[\\(|\\)]/g, "");
                        var pointArray = coords.split(",");
                        if (pointArray.length == 2) {
                            // The bounding box of a point is a linestring with two points
                            pointArray = [pointArray[0], pointArray[1], pointArray[0], pointArray[1]];
                        }
                        self.featureBounds.extend(new google.maps.LatLng(pointArray[1].split(" ")[1], pointArray[1].split(" ")[0]));
                        self.featureBounds.extend(new google.maps.LatLng(pointArray[3].split(" ")[1], pointArray[3].split(" ")[0]));
                        if (!loc.areaKmSq) {
                            loc.areaKmSq = data.area_km ? data.area_km : 0;
                        }
                    }

                    self.addFeature(feature, loc);
                });
            } else {
                // count the location as loaded even if we didn't
                console.log('Feature type not supported: ' + loc.type);
            }
            return feature;
        }
    };

    // loads the features
    self.load = function (features) {
        if (features === undefined || features.length == 0) {
            return;
        }

        var iw = new google.maps.InfoWindow({maxWidth: 360});

        $.each(features, function (i, loc) {
            if (loc != null) {
                self.loadFeature(loc, iw);
            }
        });

        self.allLocationsLoaded();
    };

    self.addFeature = function (feature, loc, iw) {
        if (self.highlightOnHover) {
            google.maps.event.addListener(feature, 'mouseover', function () {
                self.highlightFeature(this);
            });
            google.maps.event.addListener(feature, 'mouseout', function () {
                self.unHighlightFeature(this);
            });
        }

        if (loc.popup && iw) {
            // add infoWindow popu
            google.maps.event.addListener(feature, 'click', function (event) {
                iw.setContent(loc.popup);
                iw.open(self.map, feature);
            });

            google.maps.event.addListener(iw, 'closeclick', function () {
                // catch the close infoWindow event
                if (prevMarker) prevMarker.setIcon(map.smallDotIcon);
            });
        }

        // Add a marker at the centroid of the polygon for small polygons so they are visible despite the zoom level.
        if (loc.type.toLowerCase() !== 'point' && loc.type.toLowerCase() !== 'dot' && loc.areaKmSq < self.polygonMarkerAreaKm2) {
            if (loc.centre) {
                var latLng = new google.maps.LatLng(loc.centre[1], loc.centre[0]);
                loc.marker = new google.maps.Marker({
                    position: latLng,
                    map: self.map,
                    title: ""
                });
            }

        }
        self.indexFeature(feature, loc);
        self.locationLoaded();
    };

    self.indexFeature = function (feature, loc) {
        var id;
        if (loc.id === undefined) {
            id = self.currentId++;
        } else {
            id = loc.id;
        }
        if (self.featureIndex[id] === undefined) {
            self.featureIndex[id] = [];
        }
        self.featureIndex[id].push(feature);
        if (loc.marker) {
            self.featureIndex[id].push(loc.marker);
        }
    };

    // increments the count of loaded locations - zooms map when all are loaded
    self.locationLoaded = function () {
        self.locationsLoaded++;
        if (self.locationsLoaded === self.features.length) {
            // all loaded
            self.allLocationsLoaded();
        }
    };
    
    // zoom map to show features - but not higher than zoom = 12
    self.allLocationsLoaded = function () {
        if (self.zoomToBounds) {
            self.map.fitBounds(self.featureBounds);  // this happens asynchronously so need to wait for bounds to change
        }
    };

    self.highlightFeatureById = function (id) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                self.highlightFeature(feature);
            });
        }
    };

    self.unHighlightFeatureById = function (id) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                self.unHighlightFeature(feature);
            });
        }
    };

    self.highlightFeature = function (feature) {
        if (!feature) {
            return;
        }
        if (feature instanceof google.maps.Marker) {
            feature.setOptions({icon: 'http://collections.ala.org.au/images/map/orange-dot.png'});
        } else if (feature instanceof google.maps.Polygon) {
            feature.setOptions({
                strokeColor: '#BC2B03',
                fillColor: '#DF4A21'
            });
        }
    };

    self.unHighlightFeature = function (feature) {
        if (!feature) {
            return;
        }
        if (feature instanceof google.maps.Marker) {
            feature.setOptions({icon: null});
        } else if (feature instanceof google.maps.Polygon) {
            feature.setOptions({
                strokeColor: '#202020',
                fillColor: '#eeeeee'
            });
        }
    };

    self.animateFeatureById = function (id) {
        var features = self.featureIndex[id];
        var returnVal = false;
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                self.animateFeature(feature);
            });
            returnVal = true;
        }
        return returnVal;
    };

    self.unAnimateFeatureById = function (id) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                self.unAnimateFeature(feature);
            });
        }
    };

    self.animateFeature = function (feature) {
        if (!feature) {
            return;
        }
        if (feature instanceof google.maps.Marker) {
            feature.setIcon(map.redMarkerIcon);
        }
    };

    self.unAnimateFeature = function (feature) {
        if (!feature) {
            return;
        }
        if (feature instanceof google.maps.Marker) {
            feature.setIcon(map.smallDotIcon);
        }
    };

    self.getExtentByFeatureId = function (id) {
        var features = self.featureIndex[id];

        if (features) {
            var bounds = new google.maps.LatLngBounds();
            $.each(features, function (i, feature) {
                bounds.extend(feature.position);
            });
            return bounds;
        }
    };

    self.hideFeatureById = function (id) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                feature.setVisible(false);
            });
        }
    };

    self.showFeatureById = function (id) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                feature.setVisible(true);
            });
        }
    };

    self.showAllfeatures = function () {
        $.each(self.featureIndex, function (i, obj) {
            $.each(obj, function (j, feature) {
                feature.setVisible(true);
            });
        });
    };

    self.getAddressById = function (id, callback) {
        var features = self.featureIndex[id];
        if (features) {
            $.each(self.featureIndex[id], function (i, feature) {
                if (feature instanceof google.maps.Marker) {
                    if (!self.geocoder) {
                        self.geocoder = new google.maps.Geocoder()
                    }
                    self.geocoder.geocode({location: feature.getPosition()},
                        function (results, status) {
                            if (status == google.maps.GeocoderStatus.OK) {
                                callback(results[0].formatted_address);
                            }
                        });
                }
            });
        }
    };

    self.clearFeatures = function () {
        var overlaysToRemove = [];
        //clear map of features
        $.each(self.featureIndex, function (i, obj) {
            $.each(obj, function (j, feature) {
                if (feature.setMap !== undefined) {
                    feature.setMap(null);
                }
                else {
                    self.map.overlayMapTypes.forEach(function (obj, i) {
                        if (obj == feature) {
                            overlaysToRemove.push(i);
                        }
                    });
                }
            });
        });

        // Sort in reverse numeric order so the indexes remain stable as we remove items from the array.
        overlaysToRemove.sort(function (a, b) {
            return b - a;
        });
        $.each(overlaysToRemove, function (i, index) {
            self.map.overlayMapTypes.removeAt(index);
        });

        self.reset();
    };

    self.getCenter = function () {
        return self.map.getCenter();
    };

    function geojsonToPaths(obj) {
        return gjToLatLngs(obj);
    }

    function gjToLatLngs(arr) {
        var i, len = arr.length;
        for (i = 0; i < len; i++) {
            if (isCoord(arr[i])) {
                arr[i] = new google.maps.LatLng(arr[i][1], arr[i][0]);
            } else if ($.isArray(arr[[i]])) {
                arr[i] = gjToLatLngs(arr[i]);
            }
        }
        return arr;
    }

    function isCoord(arr) {
        return arr.length === 2 && !isNaN(arr[0]) && !isNaN(arr[1]);
    }

    function encodeHex(s) {
        s = s.substring(1, 7);
        if (s.length < 6) {
            s = s[0] + s[0] + s[1] + s[1] + s[2] + s[2];
        }
        return encodeRGB(parseInt(s[0] + s[1], 16), parseInt(s[2] + s[3], 16), parseInt(s[4] + s[5], 16));
    }

    function encodeRGB(r, g, b) {
        var k = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        return k.charAt(((0 & 3) << 4) | (r >> 4)) + k.charAt(((r & 15) << 2) | (g >> 6)) +
            k.charAt(g & 63) + k.charAt(b >> 2) + k.charAt(((b & 3) << 4) | (255 >> 4))
    }

    init(options, features);
}