/*
 * Copyright (C) 2014 Atlas of Living Australia
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

// global var with config vars: GSP_VARS required

$(function () {
    if (!GSP_VARS) {
        alert("GSP_VARS not set!");
    }

    // mouse over affect on thumbnail images
    $('#speciesImages').on('hover', '.imgCon', function () {
        $(this).find('.brief, .detail').toggleClass('hide');
    });

    $('#speciesImages').on('inview', '#end', function (event, isInView, visiblePartX, visiblePartY) {
        //console.log("inview", isInView, visiblePartX, visiblePartY);
        if (isInView) {
            //console.log("images bottom in view");
            var start = $('#speciesImages').data('start');
            var speciesGroup = $('#speciesImages').data('species_group');
            loadSpeciesGroupImages(speciesGroup, start)
        }
    });

    $('#toggleNoImages').on('change', function (e) {
        $('.imgCon.noImage').toggleClass('hide');
    });

    $('#speciesImages').on('click', '.imgCon a', function () {
        var lsid = $(this).data('lsid');
        //var name = $(this).find('.brief').html(); // TODO: store info in object and store object in 'data' attribute
        var displayname = $(this).data('displayname');
        loadSpeciesPopup(lsid, displayname);
        return false;
    });
});

function loadSpeciesGroupImages(speciesGroup, start) {
    alert('loadSpeciesGroupImages - ' + speciesGroup );
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
        url : GSP_VARS.biocacheBaseUrl + '/occurrences/search.json',
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
                //var lsid = parts[2];
                //var displayName = (parts[0]) ? parts[0] : "<i>" + parts[1] + "</i>";
                var imgUrl = "http://bie.ala.org.au/ws/species/image/small/" + nameObj.lsid; // http://bie.ala.org.au/ws/species/image/thumbnail/urn:lsid:biodiversity.org.au:afd.taxon:aa745ff0-c776-4d0e-851d-369ba0e6f537
                images += "<div class='imgCon'><a class='cbLink thumbImage tooltips' rel='thumbs' href='http://bie.ala.org.au/species/" +
                    nameObj.lsid + "' target='species' data-lsid='" + nameObj.lsid + "' data-displayname='" + nameObj.fullName1 + "'><img src='" + imgUrl +
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