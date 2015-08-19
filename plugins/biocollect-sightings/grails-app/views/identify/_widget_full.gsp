%{--
  - Copyright (C) 2015 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<div class="boxed-heading" id="location" data-content="1. Specify a location">
    <div class="row">
        <div class="span5">
            <p>Where did you see the species of interest?</p>
            <button class="btn" id="useMyLocation1"><i class="fa fa-location-arrow fa-lg" style="margin-left:-2px;margin-right:3px;"></i> Use my location</button>
            <r:img uri="/images/spinner.gif" class="spinner0 hide" style="height: 30px;"/>
            <div style="margin: 10px 0;"><span class="label label-info">OR</span></div>
            <div class="hide">Enter an address, location or coordinates</div>
            <div class="input-append">
                <input class="span4" id="geocodeinput" type="text" placeholder="Enter an address, location or lat/lng">
                <button id="geocodebutton" class="btn" onclick="geocode()">Lookup</button>
            </div>
            <div>Show known species in a
            <g:select name="radius" id="radius" class="select-mini" from="${[1,2,5,10,20]}" value="${defaultRadius?:5}"/>
            km area surrounding this location</div>
            <div id="locationLatLng"><span></span></div>
        </div>
        <div class="span6">
            <div id="map1" style="width: 100%; height: 280px"></div>
            <div class="" id="mapTips">Tip: drag the marker to fine-tune your location</div>
        </div>
    </div>
</div>

<div class="boxed-heading" id="species_group" data-content="2. Narrow to a species group">
    <p>Select the group and subgroup (optional) that best fits the species (if unsuccessful try different groups or increase the "surrounding area" size - drop-down above)</p>
    <div id="speciesGroup"><span>[Specify a location first]</span></div>
    <r:img uri="/images/spinner.gif" class="spinner1 hide"/>
    <p class="hide">Select a species sub-group (optional)</p>
    <div id="speciesSubGroup"></div>
    <div class="clearfix"></div>
</div>

<div class="boxed-heading" id="browse_species_images" data-content="3. Browse species images">
    <p>
        Look for images that match the species you are trying to identify. Click the image for more example images of that species and finally click the "select this image" button.
        <br><g:checkBox name="toggleNoImages" id="toggleNoImages" class="" value="${true}"/> hide species without images
    </p>
    <div id="speciesImages">
        <span>[Specify a location first]</span>
    </div>
    <r:img uri="/images/spinner.gif" class="spinner2 hide"/>
</div>

<!-- Modal -->
<div id="imgModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="imgModalLabel" aria-hidden="true">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
        <h3 id="imgModalLabel"></h3>
    </div>
    <div class="modal-body">
        <r:img uri="/images/spinner.gif" id="spinner3" class="spinner "/>
        <div class="" id="singleSpeciesImages"></div>
        <div id="imgConClone" class="imgCon hide">
            <a href="#" class="cbLink thumbImage tooltips" rel="thumbs">
                <img src="" alt="species thumbnail" onerror="imgError(this);"/>
                <div class="meta brief"></div>
                <div class="meta detail hide"><span class="scientificName"></span><br><span class="commonName"></span></div>
            </a>
        </div>
    </div>
    <div class="modal-footer">
        <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        <button class="btn btn-primary pull-left" id="selectedSpeciesBtn">Select this species</button>
    </div>
</div>

<r:script disposition="head">
    var map1, geocoding, marker, circle, radius, initalBounds;
    var biocacheBaseUrl = "${grailsApplication.config.biocache.baseURL + "/ws"}";

    $(document).ready(function() {

        var osm = L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
            maxZoom: 18,
            attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                'Imagery © <a href="http://mapbox.com">Mapbox</a>',
            id: 'nickdos.kf2g7gpb'
        });
        <%--
        var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
        });

        var MapQuestOpen_OSM = L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpeg', {
            attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
            subdomains: '1234'
        });

        var MapQuestOpen_Aerial = L.tileLayer('http://oatile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg', {
            attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Portions Courtesy NASA/JPL-Caltech and U.S. Depart. of Agriculture, Farm Service Agency',
            subdomains: '1234'
        });
        --%>

        var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
            maxZoom: 17
        });

        map1 = L.map('map1', {
            center: [-28, 134],
            zoom: 3//,
            //layers: [osm, MapQuestOpen_Aerial]
        });

        initalBounds = map1.getBounds().toBBoxString(); // save for geocoding lookups

        var baseLayers = {
            "Street": osm,
            "Satellite": Esri_WorldImagery
        };

        map1.addLayer(osm);

        L.control.layers(baseLayers).addTo(map1);

        marker = L.marker(null, {draggable: true}).on('dragend', function() {
            updateLocation(this.getLatLng());
        });

        radius = $('#radius').val();
        circle = L.circle(null, radius * 1000,  {color: '#df4a21'}); // #bada55

        L.Icon.Default.imagePath = "${g.createLink(uri:'/vendor/leaflet-0.7.3/images')}";

        map1.on('locationfound', onLocationFound);

        function onLocationFound(e) {
            // create a marker at the users "latlng" and add it to the map
            marker.setLatLng(e.latlng).addTo(map1);
            updateLocation(e.latlng);
        }

        $('#useMyLocation1').click(function(e) {
            e.preventDefault();
            geolocate();
        });

        $('#geocodeinput').on('keydown', function(e) {
            if (e.keyCode == 13 ) {
                e.preventDefault();
                geocodeAddress();
            }
        });


        %{--console.log('largeimageurl', this, $(img).data('largeimageurl'));--}%
        %{--var smallImgUrl = $(img).attr('src'); // keep a copy--}%
        %{--var largeImgUrl = $(img).data('largeimageurl');--}%
        %{--$(img).data('smallimageurl', smallImgUrl);--}%
        %{--$(img).attr('src', largeImgUrl);--}%
    });

    $('#selectedSpeciesBtn').click(function() {
        var returnUrl = $.url().param("returnUrl");
        var lsid = $('#imgModal').data('lsid');

        if (!returnUrl) {
           returnUrl =  "${g.createLink(uri:'/', absolute: true)}";
                    }

                    var queryStr = "";
                    if (groupSelected || subgroupSelected) {
                        var paramsList = [];
                        if (groupSelected) {
                            paramsList.push("tags=" + groupSelected);
                        }
                        if (subgroupSelected) {
                            paramsList.push("tags=" + subgroupSelected);
                        }
                        queryStr = "?" + paramsList.join("&");
                    }

                    window.location = returnUrl + "/" + lsid + queryStr;
                });


            }); // end document load

            function imgError(image){
                image.onerror = "";
                image.src = "${createLink(uri: "/images/noImage.jpg")}";

                //console.log("img", $(image).parents('.imgCon').html());
                //$(image).parents('.imgCon').addClass('hide');// hides species without images
                var hide = ($('#toggleNoImages').is(':checked')) ? 'hide' : '';
                $(image).parents('.imgCon').addClass('noImage ' + hide);// hides species without images
                return true;
            }

            function geolocate() {
                $('.spinner0').show();

                map1.locate({setView: true, maxZoom: 16}).on('locationfound', function(e){
                    $('.spinner0').hide();
                }).on('locationerror', function(e){
                    $('.spinner0').hide();
                    alert("Location failed: " + e.message);
                });
            }

            function geocode() {
                geocodeAddress();
            }



            function updateLocation(latlng) {
                //console.log("Marker moved to: "+latlng.toString());
                if (latlng) {
                    $('#speciesGroup span, #speciesImages span').hide();
                    $('.spinner1').removeClass('hide');
                    clearGroupsAndImages();
                    $('#locationLatLng span').html(latlng.toString());
                    $('#locationLatLng span').data('latlng', latlng);
                    marker.setLatLng(latlng).bindPopup('your location', { maxWidth:250 }).addTo(map1);
                    circle.setLatLng(latlng).setRadius($('#radius').val() * 1000).addTo(map1);
                    map1.fitBounds(circle.getBounds());
                    //updateSpeciesGroups()
                    updateSubGroups();
                    //console.log("zoom", map1.getZoom());
                }
            }

            function geocodeAddress() {
                var query = $('#geocodeinput').val();
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
                        var latlng = new L.LatLng(res.geometry.lat, res.geometry.lng);
                        var bounds = new L.LatLngBounds([res.bounds.southwest.lat, res.bounds.southwest.lng], [res.bounds.northeast.lat, res.bounds.northeast.lng]);
                        map1.fitBounds(bounds);
                        updateLocation(latlng);
                        marker.setPopupContent(res.formatted + " - " + latlng.toString());
                        //marker = L.marker(latlng, {draggable: true}).addTo(map1);
                        //marker.setLatLng(latlng).addTo(map1);
                    } else {
                        alert('location was not found, try a different address or place name');
                    }
                })
                .fail(function( jqXHR, textStatus, errorThrown ) {
                    alert("Error: " + textStatus + " - " + errorThrown);
                })
                .always(function() {  $('.spinner').hide(); });
            }


</r:script>