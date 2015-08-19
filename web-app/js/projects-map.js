/*
* Handles the front page map that shows all projects.
*/

function initMap (featureSelector, initCallback, siteData) {
    var map;
    // create the map
    $("#map").gmap3({
        map: {
            options: {
                zoom: 4,
                center: [-28.5, 133.5],
                panControl: false,
                streetViewControl: false,
                zoomControlOptions: {
                    style: 'DEFAULT'
                }
            },
            callback: function () {
                map = $("#map").gmap3("get");
                //google.maps.event.addListenerOnce(map, 'idle', function () {
                    // initialise sites representation on the map
                    sites.init(map, featureSelector, siteData);
                    // enable zoom by dragging while holding shift
                    map.enableKeyDragZoom();
                    // execute callback
                    initCallback.call();
                //});
            }
        }
    });

}

function initMapForProjects() {
    // wire accordion to map
    $('.accordion-group').on('show', function () {
        sites.highlightSite($(this).attr('data-pid'));
    });
    $('.accordion-group').on('hide', function () {
        sites.unHighlightSite($(this).attr('data-pid'));
    });
}

function initMapForSites() {
    $('li.siteInstance a').hover(
        function () {
            sites.highlightMarker(sites.markers[$(this).html()]);
        },
        function () {
            sites.unHighlightMarker(sites.markers[$(this).html()]);
        }
    );
}

var sites = {
    map: null,  // initialised after the map is created
    list: {}, // all the sites that have non-marker geometry
    markers: {},
    markersAdded: false,
    init: function (map, featureSelector, siteData) {
        var pid, lat, lng, name, that = this, boundsListener;
        this.map = map;

        // add features
        $.each(siteData, function (i, site) {
            if (site.location) {
                $.each(site.location, function (k,location) {
                    if (location.type === 'locationTypePoint') {
                        that.addSiteAsPoint(location.data.decimalLatitude, location.data.decimalLongitude, site.name);
                    } else if (location.type === 'locationTypePid') {
                        that.addSiteAsGeoJson(location.data.pid);
                    }
                });
            }
        });
        /*$(featureSelector).each(function () {
            pid = $(this).attr('data-pid');
            lat = $(this).attr('data-latitude');
            lng = $(this).attr('data-longitude');
            name = $(this).find('a').html();
            if (pid) {
                that.addSiteAsGeoJson(pid);
            } else if (lat && lng) {
                that.addSiteAsPoint(lat, lng, name);
            }
        });*/

        // adjust zoom to show features if more than 1 added
        if (this.markersAdded) {
            this.map.fitBounds(this.featureBounds);  // this happens asynchronously so need to wait for bounds to change
            // to sanity-check the zoom level
            boundsListener = google.maps.event.addListener(this.map, 'bounds_changed', function(event) {
                if (this.getZoom() > 9){
                    this.setZoom(9);
                }
                google.maps.event.removeListener(boundsListener);
            });
        }
    },
    featureBounds: new google.maps.LatLngBounds(),
    addSiteAsPoint: function (lat, lng, name) {
        var mk;
        if (lat == 0 && lng == 0) { return }
        var pt = new google.maps.LatLng(lat, lng);
        mk = new google.maps.Marker({
            map: this.map,
            position: pt,
            title: name
        });
        this.markers[name] = mk;
        this.markersAdded = true;
        this.featureBounds.extend(pt);
    },
    addSiteAsGeoJson: function (pid) {
        var coords, geom = [], points, that = this;
        $.ajax({
            url: 'http://devt.ala.org.au:8087/proxy/geojsonFromPid?pid=' + pid,
            dataType: 'json',
            success: function (data) {
                if (data === undefined) { return; }  // pid doesn't exist
                coords = data.coordinates;
                $.each(coords, function(j, polygon) {
                    points = [];
                    $.each(polygon[0], function(i, point) {
                        points.push(new google.maps.LatLng(point[1],point[0]));
                    });
                    geom.push(points);
                });
                that.list[pid] = new google.maps.Polygon({
                    strokeColor:'#202020',
                    fillColor:'#eeeeee',
                    fillOpacity: 0.5,
                    strokeWeight: 1,
                    paths: geom,
                    map: that.map
                });
            }
        });
    },
    highlightMarker: function (marker) {
        if (marker !== undefined) {
            marker.setOptions({icon: 'http://collections.ala.org.au/images/map/orange-dot.png'});
        }
    },
    unHighlightMarker: function (marker) {
        if (marker !== undefined) {
            marker.setOptions({icon: null});
        }
    },
    highlightSite: function (pid) {
        var geom = this.list[pid];
        if (geom) {
            geom.setOptions({
                strokeColor:'#BC2B03',
                fillColor:'#DF4A21'
            });
        }
    },
    unHighlightSite: function (pid) {
        var geom = this.list[pid];
        if (geom) {
            geom.setOptions({
                strokeColor:'#202020',
                fillColor:'#eeeeee'
            });
        }
    },
    markerClicked: function (event) {

    }
};

/*var projectOverlays = {
    map: null,  // initialised after the map is created
    list: {}, // all the project overlays
    init: function (map) {
        this.map = map;
        //this.addRegion('ger_border_ranges');
        this.addRegion('ger_slopes_to_summit');
        this.addRegion('ger_kosciuszko_to_coast');
    },
    addRegion: function (name) {
        var overlay = this.createOverlay(name, false);
        this.list[name] = {idx: this.map.overlayMapTypes.push(overlay) - 1, overlay: overlay};
    },
    highlightRegion: function (name) {
        var ovObj = this.list[name], map = this.map, overlay, that = this;
        if (ovObj) {
            if (ovObj.hlOverlay === undefined) {
                ovObj.hlOverlay = that.createOverlay(name, true);
            }
            map.overlayMapTypes.setAt(ovObj.idx, ovObj.hlOverlay);
        }
    },
    unHighlightRegion: function (name) {
        var ovObj = this.list[name], map = this.map, overlay, that = this;
        if (ovObj) {
            map.overlayMapTypes.setAt(ovObj.idx, ovObj.overlay);
        }
    },
    createOverlay: function (name, highlight) {
        //
        var layerParams = [
            "format=image/png",
            "layers=ALA:" + name,
            highlight ? "sld=" + fcConfig.sldPolgonHighlightUrl : "sld=" + fcConfig.sldPolgonDefaultUrl,
            "styles="//polygon"
        ];
        return new WMSTileLayer(name,
            fcConfig.spatialWmsUrl,
            layerParams,
            function () {},
            0.6);
    }

};*/

