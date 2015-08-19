%{--
  - Copyright (C) 2014 Atlas of Living Australia
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
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Identify | Atlas of Living Australia</title>
    <r:require modules="jquery, jquery-ui, pigeonhole, leaflet, inview, purl, fontawesome"/>
    <style type="text/css">
    #locationLatLng {
        color: #DDD;
    }

    .select-mini {
        width: auto !important;
        height: 24px;
        font-size: 12px;
        line-height: 20px;
        margin-bottom: 2px;
    }

    #speciesGroup {
        /*width: 18%;*/
        /*float: left;*/
        margin-bottom: 10px;
    }

    #speciesSubGroup {
        /*width: 80%;*/
        /*float: left;*/
        /*padding-left: 15px;*/
        /*margin-top: 20px;*/
    }

    #speciesSubGroup .btn-group {
        margin-left: 0 !important;
        margin-top: 10px;
    }

    .sub-groups {
        /*display: inline-block;*/
        /*margin-top: 10px;*/
    }

    .sub-groups .btn, #speciesGroup1 .btn {
        margin-bottom: 4px;
        margin-right: 4px;
    }

    .leaflet-popup-content {
        font-size: 11px;
    }

    /* Gallery styling */
    .imgCon {
        display: inline-block;
        /* margin-right: 8px; */
        text-align: center;
        line-height: 1.3em;
        background-color: #DDD;
        color: #DDD;
        font-size: 12px;
        /*text-shadow: 2px 2px 6px rgba(255, 255, 255, 1);*/
        /* padding: 5px; */
        /* margin-bottom: 8px; */
        margin: 2px 4px 2px 0;
        position: relative;
    }

    .imgCon img {
        height: 120px;
        /*min-width: 100px;*/
        max-width: 300px;
    }

    #singleSpeciesImages .imgCon img {
        height: 90px;
        /*min-width: 90px;*/
        max-width: 150px;
        cursor: zoom-in;
    }

    #singleSpeciesImages .imgCon img.zoomed {
        height: 100%;
        min-width: auto;
        max-width: none;
        cursor: zoom-out;
    }

    /*#singleSpeciesImages .imgCon img {*/
    /*-webkit-transition: all 0.5s ease;*/
    /*-moz-transition: all 0.5s ease;*/
    /*-o-transition: all 0.5s ease;*/
    /*transition: all 0.5s ease;*/
    /*}*/
    .imgCon .meta {
        opacity: 0.8;
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        overflow: hidden;
        text-align: left;
        padding: 4px 5px 2px 5px;
    }

    .imgCon .brief {
        color: black;
        background-color: white;
    }

    .imgCon .detail {
        color: white;
        background-color: black;
        opacity: 0.7;
    }

    .imgCon.hide {
        display: none;
    }

    .bieBtn {
        display: inline-block;
        margin-left: 10px;
    }

    .counts {
        font-size: 12px;
        color: #637073;
    }

    .btn-primary .counts {
        color: #fff;
    }

    </style>
    <r:script disposition="head">
        var map, geocoding, marker, circle, radius, initalBounds, groupSelected, subgroupSelected;
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

            map = L.map('map', {
                center: [-28, 134],
                zoom: 3//,
                //layers: [osm, MapQuestOpen_Aerial]
            });

            initalBounds = map.getBounds().toBBoxString(); // save for geocoding lookups

            var baseLayers = {
                "Street": osm,
                "Satellite": Esri_WorldImagery
            };

            map.addLayer(osm);

            L.control.layers(baseLayers).addTo(map);

            marker = L.marker(null, {draggable: true}).on('dragend', function() {
                updateLocation(this.getLatLng());
            });

            radius = $('#radius').val();
            circle = L.circle(null, radius * 1000,  {color: '#df4a21'}); // #bada55

            L.Icon.Default.imagePath = "${g.createLink(uri: '/vendor/leaflet-0.7.3/images')}";

            map.on('locationfound', onLocationFound);

            function onLocationFound(e) {
                // create a marker at the users "latlng" and add it to the map
                marker.setLatLng(e.latlng).addTo(map);
                updateLocation(e.latlng);
            }

            $('#useMyLocation').click(function(e) {
                e.preventDefault();
                geolocate();
            });

            $('#geocodeinput').on('keydown', function(e) {
                if (e.keyCode == 13 ) {
                    e.preventDefault();
                    geocodeAddress();
                }
            });

            $('#radius').change(function() {
                updateLocation(marker.getLatLng());
            });

            $('#speciesGroup').on('click', '.groupBtn', function(e) {
                $('#speciesGroup .btn').removeClass('btn-primary').addClass('btn-default');
                $(this).removeClass('btn-default').addClass('btn-primary');
                var selected = $(this).data('group');

                $('#speciesSubGroup .sub-groups').addClass('hide'); // hide all subgroups
                $('#subgroup_' + selected).removeClass('hide'); // expose requested subgroup
                groupSelected = selected;
                //updateSubGroups($(this).data('group'));
                loadSpeciesGroupImages('species_group:' + unescape(selected), null, $(this).find('.badge').text());
            });

            $('#speciesSubGroup').on('click', '.subGroupBtn', function(e) {
                $('#speciesSubGroup .btn').removeClass('btn-primary').addClass('btn-default');
                $(this).removeClass('btn-default').addClass('btn-primary');
                var selected = $(this).data('group');
                subgroupSelected = selected;
                loadSpeciesGroupImages('species_subgroup:' + unescape(selected), null, $(this).find('.badge').text());
            });

            // mouse over affect on thumbnail images
            $('#speciesImages').on('hover', '.imgCon', function() {
                $(this).find('.brief, .detail').toggleClass('hide');
            });

            $('#speciesImages').on('inview', '#end', function(event, isInView, visiblePartX, visiblePartY) {
                //console.log("inview", isInView, visiblePartX, visiblePartY);
                if (isInView) {
                    //console.log("images bottom in view");
                    var start = $('#speciesImages').data('start');
                    var speciesGroup = $('#speciesImages').data('species_group');
                    loadSpeciesGroupImages(speciesGroup, start)
                }
            });

            $('#toggleNoImages').on('change', function(e) {
                $('.imgCon.noImage').toggleClass('hide');
            });

            $('#speciesImages').on('click', '.imgCon a', function() {
               var lsid = $(this).data('lsid');
               //var name = $(this).find('.brief').html(); // TODO: store info in object and store object in 'data' attribute
               var displayname = $(this).data('displayname');
               loadSpeciesPopup(lsid, displayname);
               return false;
            });

            var prevImgId, prevWidth;
            $('#singleSpeciesImages').on('click', '.imgCon a', function() {
                var img = $(this).find('img');
                var imgId = $(img).attr('id');
                //var thisImgId =  $(img).attr('src');
                //var isZoomed = $(img).hasClass('zoomed');
                //$('#singleSpeciesImages img').removeClass('zoomed');
                //console.log("img clicked!", imgId, prevImgId, prevWidth);

                function shrink(theImg) {
                    $(theImg).animate({
                        width: prevWidth,
                        height: "90"
                    },'fast', function() {
                        //console.log("setting preImg to null",prevImgId);
                        $(theImg).css('maxWidth','150px').css('cursor','zoom-in');
                        prevImgId = null;
                    });
                }

                function enlarge(theImg) {
                    $(theImg).css('maxWidth','none').css('cursor','zoom-out');
                    prevWidth = $(theImg).width();
                    var imageCopy = new Image();
                    imageCopy.src = theImg.attr("src");

                    $(theImg).animate({
                        width: imageCopy.width,
                        height: imageCopy.height
                    },'fast', function() {
                        console.log("setting preImg to img",prevImgId);
                        prevImgId = imgId;
                    });
                }

                if (prevImgId && prevImgId != imgId) {
                    // shrink the prev img and enlarge this img
                    shrink($('#singleSpeciesImages img#' + prevImgId));
                    enlarge(img);
                    //prevImg = img;
                } else if (prevImgId && prevImgId == imgId) {
                    // same img clicked so shrink img
                    shrink(img, null);
                    //prevImg = null;
                } else {
                    // no prev img enlarged
                    enlarge(img);
                    //prevImg = img;
                }
            });

            $('#selectedSpeciesBtn').click(function() {
                var returnUrl = $.url().param("returnUrl");
                var lsid = $('#imgModal').data('lsid');

                if (!returnUrl) {
                   //returnUrl =  "${g.createLink(uri: '/', absolute: true)}";
                   returnUrl =  "${grailsApplication.config.bie.baseURL}/species";
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

            $('#geocodebutton').click(function(e) {
                e.preventDefault();
                geocode();
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

            map.locate({setView: true, maxZoom: 16}).on('locationfound', function(e){
                $('.spinner0').hide();
            }).on('locationerror', function(e){
                $('.spinner0').hide();
                alert("Location failed: " + e.message);
            });
        }

        function geocode() {
            geocodeAddress();
        }

        function updateSubGroups(group) {
            var radius = $('#radius').val();
            var latlng = $('#locationLatLng span').data('latlng');

            $.ajax({
                url : biocacheBaseUrl + '/explore/hierarchy/groups.json'
                    , dataType : 'jsonp'
                    , jsonp : 'callback'
                    , data : {
                        'lat' : latlng.lat
                        , 'lon' : latlng.lng
                        , 'radius' : radius
                        , 'fq' : 'rank_id:[7000 TO *]' // TODO - check this is not being ignored by biocache-service
                        , 'speciesGroup': group
                    }
            })
            .done(function(data){
                var group = "<div id='speciesGroup1' class=''>";
                $('#speciesSubGroup').html('');

                $.each(data, function(index, value){
                    // console.log(index, value);
                    var btn = 'btn-default'; //(index == 0) ? 'btn-primary' : 'btn-default';
                    group += "<div class='btn groupBtn " +  btn + "' data-group='" + escape(value.name) + "'>" + value.name + " <span class='counts'>[" + value.speciesCount + "]</span></div>";

                    if (value.childGroups.length > 0) {
                        var hide = 'hide'; //(index == 0) ? '' : 'hide';
                        var subGroup = "<div id='subgroup_" + value.name + "' class='sub-groups " + hide + "'>";
                        $.each(value.childGroups, function(i, el){
                            subGroup += "<div class='btn btn-default subGroupBtn' data-group='" + escape(el.name) + "'>" + el.name + " <span class='counts'>[" + el.speciesCount + "]</span></div>";
                        });
                        $('#speciesSubGroup').append(subGroup);
                    }
                });

                $('#speciesGroup').html(group);
                $('#species_group p.hide').removeClass('hide');
            })
            .always(function() {
                $('.spinner1').addClass('hide');
            })
            .fail(function( jqXHR, textStatus, errorThrown ) {
                alert("Error: " + textStatus + " - " + errorThrown);
            });
        }

        function loadSpeciesGroupImages(speciesGroup, start) {
            if (!start) {
                start = 0;
                $('#speciesImages').empty();
            } else {
                $( "#end" ).remove(); // remove the trigger element for the inview loading of more images
            }

            var pageSize = 30;
            var radius = $('#radius').val();
            var latlng = $('#locationLatLng span').data('latlng');
            $('.spinner2').removeClass('hide');
            jQuery.ajaxSettings.traditional = true; // so multiple params with same key are formatted right
            //var url = "http://biocache.ala.org.au/ws/occurrences/search?q=species_subgroup:Parrots&fq=geospatial_kosher%3Atrue&fq=multimedia:Image&facets=multimedia&lat=-35.2792511&lon=149.1113017&radius=5"
            $.ajax({
                url : biocacheBaseUrl + '/occurrences/search.json',
                    dataType : 'jsonp',
                    jsonp : 'callback',
                    data : {
                        'q' : '*:*',
                        'fq': [ speciesGroup,
                                'rank_id:[7000 TO *]' // remove higher taxa
                               //'geospatial_kosher:true'],
                               ],
                        //'fq': speciesGroup,
                        'facets': 'common_name_and_lsid',
                        'flimit': pageSize,
                        'foffset': start,
                        'start': 0,
                        'pageSize': 0,
                        'lat' : latlng.lat,
                        'lon' : latlng.lng,
                        'radius' : radius
                    }
            })
            .done(function(data){
                if (data.facetResults && data.facetResults.length > 0 && data.facetResults[0].fieldResult.length > 0) {
                    //console.log(speciesGroup + ': species count = ' + data.facetResults[0].fieldResult.length);
                    var images = "<span id='imagesGrid'>";
                    var newTotal = Number(start);
                    $.each(data.facetResults[0].fieldResult, function(i, el){
                        //if (i >= 30) return false;
                        newTotal++;
                        var parts = el.label.split("|");
                        var nameObj = {
                            sciName: parts[1],
                            commonName: parts[0],
                            lsid: parts[2],
                            shortName: (parts[0]) ? parts[0] : "<i>" + parts[1] + "</i>",
                            fullName1: (parts[0]) ? parts[0] + " &mdash; " + "<i>" + parts[1] + "</i>" : "<i>" + parts[1] + "</i>",
                            fullName2: (parts[0]) ? parts[0] + "<br>" + "<i>" + parts[1] + "</i>" : "<i>" + parts[1] + "</i>"
                        };
                        var displayName = $('<div/>').text(nameObj.fullName1).html(); // use jQuery to escape text
                        var imgUrl = "http://bie.ala.org.au/ws/species/image/small/" + nameObj.lsid; // http://bie.ala.org.au/ws/species/image/thumbnail/urn:lsid:biodiversity.org.au:afd.taxon:aa745ff0-c776-4d0e-851d-369ba0e6f537
                        images += "<div class='imgCon'><a class='cbLink thumbImage tooltips' rel='thumbs' href='http://bie.ala.org.au/species/" +
                                nameObj.lsid + "' target='species' data-lsid='" + nameObj.lsid + "' data-displayname='" + displayName + "'><img src='" + imgUrl +
                                "' alt='species thumbnail' onerror='imgError(this);'/><div class='meta brief'>" +
                                nameObj.shortName + "</div><div class='meta detail hide'>" +
                                nameObj.fullName2 + "<br>Records: " + el.count + "</div></a></div>";
                    });
                    images += "</span>";
                    images += "<div id='end'>&nbsp;</div>";
                    $('#speciesImages').append(images);
                    $('#speciesImages').data('start', start + pageSize);
                    $('#speciesImages').data('species_group', speciesGroup);
                    //$('#speciesImages').data('total', total);
                } else if (!start) {
                    $('#speciesImages').append("No species found.");
                }
            })
            .always(function() {
                $('.spinner2').addClass('hide');
            })
            .fail(function( jqXHR, textStatus, errorThrown ) {
                // alert("Error: " + textStatus + " - " + errorThrown);
                $('#speciesImages').append("Error: " + textStatus + " - " + errorThrown);
            });
        }

        function updateLocation(latlng) {
            //console.log("Marker moved to: "+latlng.toString());
            if (latlng) {
                $('#speciesGroup span, #speciesImages span').hide();
                $('.spinner1').removeClass('hide');
                clearGroupsAndImages();
                $('#locationLatLng span').html(latlng.toString());
                $('#locationLatLng span').data('latlng', latlng);
                marker.setLatLng(latlng).bindPopup('your location', { maxWidth:250 }).addTo(map);
                circle.setLatLng(latlng).setRadius($('#radius').val() * 1000).addTo(map);
                map.fitBounds(circle.getBounds());
                //updateSpeciesGroups()
                updateSubGroups();
                //console.log("zoom", map.getZoom());
            }
        }

        function clearGroupsAndImages() {
            $('#speciesGroup').empty();
            $('#speciesSubGroup').empty();
            $('#speciesImages').empty();
            subgroupSelected = null;
            groupSelected = null;
        }

        function geocodeAddress() {
            $('.spinner0').show();
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
                if (data.results.length > 0) {
                    var res = data.results[0];
                    var latlng = new L.LatLng(res.geometry.lat, res.geometry.lng);

                    //if no bounds supplied use them
                    if(res.bounds){
                        var bounds = new L.LatLngBounds([res.bounds.southwest.lat, res.bounds.southwest.lng],
                        [res.bounds.northeast.lat, res.bounds.northeast.lng]);
                        map.fitBounds(bounds);
                    }

                    updateLocation(latlng);
                    marker.setPopupContent(res.formatted + " - " + latlng.toString());
                    //marker = L.marker(latlng, {draggable: true}).addTo(map);
                    //marker.setLatLng(latlng).addTo(map);
                } else {
                    alert('location was not found, try a different address or place name');
                }
            })
            .fail(function( jqXHR, textStatus, errorThrown ) {
                alert("Error: " + textStatus + " - " + errorThrown);
            })
            .always(function() {  $('.spinner, .spinner0').hide(); });
        }

        function loadSpeciesPopup(lsid, name) {
            $('#imgModalLabel, #speciesDetails, #singleSpeciesImages').empty(); // clear any old values
            $('#imgModalLabel').html(name);
            $('<a class="btn btn-default btn-small bieBtn" href="http://bie.ala.org.au/species/' + lsid +
                    '" target="bie"><i class="icon-info-sign"></i> species page</a>').appendTo($('#imgModalLabel'));
            $('#spinner3').removeClass('hide');
            var start = 0, pageSize = 20;
            $.ajax({
                url : biocacheBaseUrl + '/occurrences/search.json',
                    dataType : 'jsonp',
                    jsonp : 'callback',
                    data : {
                        'q' : 'lsid:' + lsid,
                        'fq': [
                                'multimedia:Image' // images only
                               //'geospatial_kosher:true'],
                               ],
                        'facet': 'off',
                        //'flimit': pageSize,
                        //'foffset': ,
                        'start': start,
                        'pageSize': pageSize
                    }
            })
            .done(function(data){
                if (data.occurrences && data.occurrences.length > 0) {
                    $.each(data.occurrences, function(i, occ){
                        //clone imgCon div and populate with data
                        var $clone = $('#imgConClone').clone();
                        $clone.attr("id",""); // remove the ID
                        $clone.removeClass("hide");
                        $clone.find("img").attr('src', occ.smallImageUrl);
                        $clone.find("img").attr('id', occ.image);
                        $clone.find(".meta").addClass("hide");
                        //console.log('clone', $clone);
                        $('#singleSpeciesImages').append($clone);
                    });
                    $('#imgModal').data('lsid', lsid);
                }
            })
            .fail(function( jqXHR, textStatus, errorThrown ) {
                alert("Error: " + textStatus + " - " + errorThrown);
            })
            .always(function() {  $('#spinner3').addClass('hide'); });

            $('#imgModal').modal(); // trigger modal popup
        }

    </r:script>
</head>

<body class="nav-species">
<h2>Help with species identification</h2>

<div class="row">
    <div class="col-sm-12">
        <div class="boxed-heading" id="location" data-content="1. Specify a location">
            <div class="row">
                <div class="col-sm-5">
                    <p>Where did you see the species of interest?</p>
                    <button class="btn btn-default" id="useMyLocation"><i class="fa fa-location-arrow fa-lg" style="margin-left:-2px;margin-right:3px;"></i> Use my location
                    </button>
                    <r:img uri="/images/spinner.gif" class="spinner0" style="display: none; height: 30px;"/>
                    <div style="margin: 10px 0;"><span class="label label-info">OR</span></div>
                    <div class="hide">Enter an address, location or coordinates</div>
                    <div class="input-group">
                        <input class="form-control" id="geocodeinput" type="text" placeholder="Enter an address, location or lat/lng">
                        <span class="input-group-btn">
                            <button id="geocodebutton" class="btn btn-default"><i class="fa fa-search"></i></button>
                        </span>
                    </div><!-- /input-group -->
                    <br>
                    <div>
                        Show known species in a
                        <g:select name="radius" id="radius" class="" from="${[1, 2, 5, 10, 20]}"
                                  value="${defaultRadius ?: 5}"/>
                        km area surrounding this location
                    </div>
                    <br>
                    <div id="locationLatLng"><span></span></div>
                </div>

                <div class="col-sm-6">
                    <div id="map" style="width: 100%; height: 280px"></div>
                    <div class="" id="mapTips">Tip: drag the marker to fine-tune your location</div>
                </div>
            </div>
        </div>

        <div class="boxed-heading" id="species_group" data-content="2. Narrow to a species group">
            <p>Select the group and subgroup (optional) that best fits the species (if unsuccessful try
            different groups or increase the "surrounding area" size - drop-down above)</p>
            <div id="speciesGroup"><span>[Specify a location first]</span></div>
            <r:img uri="/images/spinner.gif" class="spinner1 hide"/>
            <p class="hide">Select a species sub-group (optional)</p>
            <div id="speciesSubGroup"></div>
            <div class="clearfix"></div>
        </div>
        <div class="boxed-heading" id="browse_species_images" data-content="3. Browse species images">
            <p>
                Look for images that match the species you are trying to identify. Click the image for more
                example images of that species and finally click the "select this image" button.
                <br><g:checkBox name="toggleNoImages" id="toggleNoImages" class="" value="${true}"/> hide species without images
            </p>
            <div id="speciesImages">
                <span>[Specify a location first]</span>
            </div>
            <r:img uri="/images/spinner.gif" class="spinner2 hide"/>
        </div>

        <!-- Modal -->
        <div id="imgModal" class="modal fade">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
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
                        <button class="btn btn-default" data-dismiss="modal" aria-hidden="true">Close</button>
                        <button class="btn btn-primary pull-left" id="selectedSpeciesBtn">Select this species</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>