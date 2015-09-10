/*
 * Copyright (C) 2015 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

/*  Global var GSP_VARS required to be set in calling page */

var map, geocoding, marker, circle, radius, initalBounds, bookmarks, geocoder;

$(document).ready(function() {
    if (typeof GSP_VARS == 'undefined') {
        alert('GSP_VARS not set in page - required for map widget JS');
    }

    // initialise Google Geocoder - requires google API imports in calling page
    geocoder = new google.maps.Geocoder();

    var osm = L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
            '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
            'Imagery © <a href="http://mapbox.com">Mapbox</a>',
        id: 'nickdos.kf2g7gpb'  // TODO: we should get an ALA account for mapbox.com
    });

    // in case mapbox images start failing... fall back to plain OSM
    var osm1 = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a>'
    });
    // OR
    var OpenMapSurfer_Roads = L.tileLayer('http://openmapsurfer.uni-hd.de/tiles/roads/x={x}&y={y}&z={z}', {
        minZoom: 0,
        maxZoom: 20,
        attribution: 'Imagery from <a href="http://giscience.uni-hd.de/">GIScience Research Group @ University of Heidelberg</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    });

    var gmap_road = new L.Google('ROADMAP', {maxZoom: 21}); // requires Google.js plugin
    var gmap_sat = new L.Google('HYBRID', {maxZoom: 21}); // requires Google.js plugin
    var gmap_ter = new L.Google('TERRAIN', {maxZoom: 15}); // requires Google.js plugin. Note: maxZoom of 15 is Google hard coded limit

    var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        maxZoom: 17
    });

    map = L.map('map', {
        center: [-28, 134],
        zoom: 3,
        scrollWheelZoom: false,
        worldCopyJump: true
        //layers: [osm, MapQuestOpen_Aerial]
        });

    initalBounds = map.getBounds().toBBoxString(); // save for geocoding lookups

    var baseLayers = {
        "Street": gmap_road,
        "Satellite": gmap_sat,
        //"Terrain": gmap_ter,
        //"Street": osm,
        //"Satellite": Esri_WorldImagery
    };

    map.addLayer(gmap_road);

    L.control.layers(baseLayers).addTo(map);

    marker = L.marker(null, {draggable: true}).on('dragend', function() {
        updateLocation(this.getLatLng().wrap(), true);
        //console.log('position', map.latLngToLayerPoint(marker.getLatLng()));
    });

    radius = $('#coordinateUncertaintyInMeters').val();
    circle = L.circle(null, radius,  {color: '#df4a21'});

    L.Icon.Default.imagePath = GSP_VARS.leafletImagesDir; ;

    var popup1 = L.popup().setContent('<p>Hello world!<br />This is a nice popup.</p>');

    map.on('locationfound', function(e) {
        // create a marker at the users "latlng" and add it to the map
        marker.setLatLng(e.latlng).addTo(map);
        updateLocation(e.latlng);
    }).on('locationerror', function(e){
        //console.log(e);
        alert("Location could not be determined. Try entering an address instead.");
    }).on('contextmenu',function(e){
        //alert('right click');
        popup1.openOn(map);
    }); // triggered from map.locate()


    $('#geocodeinput').on('keydown', function(e) {
        if (e.keyCode == 13 ) {
            e.preventDefault();
            //geocodeAddress($(this).val());
            googleGeocodeAddress($('#geocodeinput').val());
        }
    });

    $('#geocodebutton').click(function(e) {
        e.preventDefault();
        //geocodeAddress($('#geocodeinput').val());
        googleGeocodeAddress($('#geocodeinput').val());
    });

    $('#useMyLocation').click(function(e) {
        e.preventDefault();
        geolocate();
    });

    // detect change event on #decimalLongitude - update map
    $('#decimalLongitude').change(function(e) {
        var lat = $('#decimalLatitude').val();
        var lng = $('#decimalLongitude').val();

        if (lat && lng) {
            //updateMapWithLocation(lat, lng);
            updateLocation(new L.LatLng(lat, lng));
        }
    });

    $('#coordinateUncertaintyInMeters').change(function() {
        updateLocation(marker.getLatLng());
    })

    loadBookmarks();

    // Save current location
    $('#bookmarkLocation').click(function(e) {
        var bookmark = {
            locality: $('#locality').val(),
            userId: GSP_VARS.user.userId,
            decimalLatitude: Number($('#decimalLatitude').val()),
            decimalLongitude: Number($('#decimalLongitude').val())
        };
        $.ajax({
            url: GSP_VARS.saveBookmarksUrl,
            dataType: 'json',
            type: 'POST',
            data:  JSON.stringify(bookmark),
            contentType: 'application/json; charset=utf-8'
        }).done(function (data) {
            if (data.error) {
                alert("Location could not be saved - " + data.error, 'Error');
            } else {
                // reload bookmarks
                alert("Location was saved");
                loadBookmarks();
                //$('#bookmarkedLocations option').eq(0).after('<option value="' + bookmark.decimalLatitude + ',' + bookmark.decimalLongitude + '">' + bookmark.locality + '</option>');
            }
        }).fail(function( jqXHR, textStatus, errorThrown ) {
            alert("Error: " + textStatus + " - " + errorThrown);
        });
    });

    // Trigger loading of bookmark on select change
    $('#bookmarkedLocations').change(function(e) {
        e.preventDefault();
        var location;
        var id = $(this).find("option:selected").val();

        if (id && id != 'error') {
            $.each(bookmarks, function(i, el) {
                if (id == el.locationId) {
                    location = el;
                }
            });

            if (location) {
                var latlng =  new L.LatLng(location.decimalLatitude, location.decimalLongitude);
                updateLocation(latlng);
                //geocodeAddress(location.locality);
            } else {
                alert("Error: bookmark could not be loaded.");
            }
        } else if (id == 'error') {
            loadBookmarks();
        }
    });

    // draggable marker icon handler
    $(".drag").udraggable({
        containment: 'parent',
        stop: function(evt, el) {
            //console.log("transformMarker", el);
            var x = el.offset.left + 12;
            var y = el.offset.top + 40;
            marker.setLatLng(map.containerPointToLatLng([x, y])).addTo(map);
            updateLocation(marker.getLatLng(), true);
            $(this).hide();
        }
    });

    // handler for zoom in button on Marler popup
    $('#location').on('click', '#zoomMarker', function(e) {
        e.preventDefault();
        map.setView(marker.getLatLng(), 16);
    });

    // update map in edit mode
    if (GSP_VARS.sightingBean && GSP_VARS.sightingBean.decimalLatitude && GSP_VARS.sightingBean.decimalLongitude) {
        $('#decimalLongitude').change();
    }

}); // end document load function

function loadBookmarks() {
    $.ajax({
        url: GSP_VARS.bookmarksUrl,
        dataType: 'json',
    }).done(function (data) {
        if (data.error) {
            bootbox.alert("Bookmark could not be loaded - " + data.error, 'Error');
        } else {
            // reload bookmarks
            bookmarks = data; // cache json
            // inject values into select widget
            $('#bookmarkedLocations option[value != ""]').remove(); // clear list if already loaded
            $.each(data, function(i, el) {
                $('#bookmarkedLocations').append('<option value="' + el.locationId + '">' + el.locality + '</option>');
            });
        }
    }).fail(function( jqXHR, textStatus, errorThrown ) {
        //alert("Error: " + textStatus + " - " + errorThrown);
        bootbox.alert("Error: bookmarks could not be loaded at this time. " + textStatus + " - " + errorThrown);
        $('#bookmarkedLocations').append('<option value="error">Error: bookmarks could not be loaded at this time. Select to retry.</option>');
    });
}

function geocodeAddress(query) {
    $.ajax({
        // https://api.opencagedata.com/geocode/v1/json?q=Canberra,+ACT&key=577ca677f86a3a4589b17814ec399112
        url : 'https://api.opencagedata.com/geocode/v1/json',
        dataType : 'jsonp',
        jsonp : 'callback',
        data : {
            'q' : query,
            'key': '577ca677f86a3a4589b17814ec399112', // key for username 'nickdos' with pw 'ac..on',
            'bounds': initalBounds // restricts search to initla map view
        }
    })
    .done(function(data){
        //console.log("geonames", data);
        if (data.results.length > 0) {
            var res = data.results[0];
            var latlng, bounds;

            if (res.geometry) {
                latlng = new L.LatLng(res.geometry.lat, res.geometry.lng);
                updateLocation(latlng);
                marker.setPopupContent(res.formatted + " - " + latlng.toString());
            } else {
                bootbox.alert("Location coordinates were found, please try a different address");
            }

            if (res.bounds && res.bounds.southwest && res.bounds.northeast) {
                bounds = new L.LatLngBounds([res.bounds.southwest.lat, res.bounds.southwest.lng], [res.bounds.northeast.lat, res.bounds.northeast.lng]);
                map.fitBounds(bounds);
            }
        } else {
            bootbox.alert('location was not found, try a different address or place name');
        }
    })
    .fail(function( jqXHR, textStatus, errorThrown ) {
        bootbox.alert("Error: " + textStatus + " - " + errorThrown);
    })
    .always(function() {  $('.spinner').hide(); });
}

/**
 * Get lat/lng for a given address via Google geocode API
 *
 * @param address
 */
function googleGeocodeAddress(address) {
    if (geocoder && address) {
        geocoder.geocode( {'address': address, region: 'AU'}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                // geocode was successful
                var latlng = new L.LatLng(results[0].geometry.location.k, results[0].geometry.location.D); //results[0].geometry.location;
                updateLocation(latlng);
            } else {
                bootbox.alert("Location coordinates were not found, please try a different address - " + status);
            }
        });
    }
}

function geolocate() {
    // this triggers a 'locationfound' event, which is registered further up in code.
    $('.spinner0').show();
    map.locate({setView: true, maxZoom: 16}).on('locationfound', function(e){
        $('.spinner0').hide();
    }).on('locationerror', function(e){
        $('.spinner0').hide();
        bootbox.alert("Location failed: " + e.message);
    });
}

function updateLocation(latlng, keepView) {
    //console.log("Marker moved to: "+latlng.toString());
    if (latlng) {
        $('.spinner1').removeClass('hide');
        $('.drag').hide();
        $('#decimalLatitude').val(latlng.lat);
        $('#decimalLongitude').val(latlng.lng);
        marker.setLatLng(latlng).bindPopup('<div>Sighting location</div><button class="btn btn-small" id="zoomMarker">Zoom in</button>', { maxWidth:250 }).addTo(map);
        circle.setLatLng(latlng).setRadius($('#coordinateUncertaintyInMeters').val()).addTo(map);
        if (!keepView) {
            map.setView(latlng, 16);
        }
        $('#georeferenceProtocol').val('Google maps');
        $('#bookmarkLocation').removeClass('disabled').removeAttr('disabled'); // activate button
        reverseGeocodeGoogle(latlng.lat, latlng.lng);
        var sciName = $('#scientificName').val();
        if (latlng.lat > 0 || latlng.lng < 100) {
            bootbox.alert("Coordinates are not in the Australasia region. Are you sure this location is correct?");
        } else if (sciName) {
            // do habitat vlaidation check
            var params = {
                decimalLatitude: latlng.lat,
                decimalLongitude: latlng.lng,
                scientificName: sciName
            }
            $.ajax({
                url: GSP_VARS.validateUrl,
                data: JSON.stringify(params),
                contentType: 'application/json',
                type: 'POST',
                dataType: 'json'
            }).done(function(data){
                var messages = [];
                if (data.habitatMismatch && data.habitatMismatchDetail) {
                    messages.push("Habitat mismatch: " + data.habitatMismatchDetail);
                }
                if (data.outlierForExpertDistribution) {
                    messages.push("Record location falls outside expert distribution");
                }
                if (data.sensitive) {
                    messages.push("Record location/identification is flagged as SENSITIVE, publicly visible coordinates may be altered.");
                }

                if (messages.length > 0) {
                    var html = '<h4>Identification/Location pre-submission check</h4><ul><li>' + messages.join('</li><li>') +
                        '</li></ul><div>You may wish to reconsider the identification or location based on this check.</div>';
                    bootbox.alert(html);
                }
            }).fail(function( jqXHR, textStatus, errorThrown ) {
                bootbox.alert("Error: " + textStatus + " - " + errorThrown);
            })
        } else {
            // highlight no sciname set
        }
    }
}

/**
 * Get address for a given lat/lng using OpenStreetMap API
 * @deprecated - use Google implementation
 * @param lat
 * @param lng
 */
function reverseGeocode(lat, lng) {
    // http://nominatim.openstreetmap.org/reverse?format=json&lat=-30.1484782&lon=153.1961178&zoom=18&addressdetails=1&accept-language=en&json_callback=foo123
    //console.log("lat lng", lat, lng);
    if (lat && lng) {
        $('#locality').val('');
        var url = "http://nominatim.openstreetmap.org/reverse?format=json&lat="+lat+
            "&lon="+lng+"&zoom=18&addressdetails=1&accept-language=en&json_callback=?";
        $.getJSON(url).done(function(data){
            if (data && !data.error) {
                $('#locality').val(data.display_name);
            }
        }).fail(function( jqXHR, textStatus, errorThrown ) {
            bootbox.alert("Error: " + textStatus + " - " + errorThrown);
        }).always(function() {  //
            // $('.spinner').hide();
        });
    }

}

/**
 * Get address for a given lat/lng using Google geocode API
 */
function reverseGeocodeGoogle(lat, lng) {
    var pos = new google.maps.LatLng(lat, lng);
    if (pos) {
        geocoder.geocode({
            latLng: pos
        }, function(responses) {
            if (responses && responses.length > 0) {
                //console.log("geocoded position", responses[0]);
                var address = responses[0].formatted_address;
                $('#locality').val(address);
            } else {
                $('#locality').val('Error: cannot determine address for this location.');
            }
        });
    }
}