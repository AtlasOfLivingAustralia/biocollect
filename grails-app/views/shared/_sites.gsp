
<div class="tab-pane" id="mapView">
    <div class="map-box">
        <div id="map" style="width: 100%; height: 100%;"></div>
    </div>
    <div style=" float: right;" id="map-info">
        <span id="numberOfProjects">${projectCount ?: 0}</span> projects with <span id="numberOfSites">[calculating]</span>
    </div>

    <div style="display:none;" id="map-legend">
        <span id="colorOptions">
            <select style="font-size:100%; width:150px; opacity:0.8;filter:alpha(opacity=50);" id="mapchange" onchange="generateMap(facetList||[], this.options[this.selectedIndex].value)">
                <option value="-1">Mark points by</option>
                <g:each var="fn" in="${mapFacets}">
                    <g:set var="f" value="${results.facets.get(fn)}"/>
                    <g:if test="${fn != 'class' && f?.terms?.size() > 0}">
                        <g:set var="fName"><g:message code="label.${fn}" default="${fn?.capitalize()}"/></g:set>
                        <option value="${fn.encodeAsURL()}">${fName}</option>
                    </g:if>
                </g:each>
            </select>
            <img style="display:none;" id="map-colorby-status" width="23" height="23" src="${request.contextPath}/images/loading-1.gif" alt="Loading"/>
            <div id="legend-table">
                <table style="opacity:1.0; filter:alpha(opacity=50); border: none; font-size : 80%; display:inline-block;" id="legend-1" >
                    <tbody>
                    </tbody>
                </table>
                <table style="opacity:1.0; filter:alpha(opacity=50); border: none; font-size : 80%; display:inline-block;" id="legend-2" >
                    <tbody>
                    </tbody>
                </table>
            </div>
        </span>
    </div>

</div>

<r:script>

    function generateMap(facetList, markBy, mapOptions) {

        var alaMap = null;


        markBy =  (markBy === undefined) || markBy == "-1" ? "" : "&markBy="+markBy;

        var url = "${createLink(controller:'nocas', action:'geoService')}?max=10000&geo=true"+markBy;

        if (facetList && facetList.length > 0) {
            url += "&fq=" + facetList.join("&fq=");
        }
        <g:if test="${params.fq}">
            <g:set var="fqList" value="${[params.fq].flatten()}"/>
            url += "&fq=${fqList.collect{it.encodeAsURL()}.join('&fq=')}";
        </g:if>
        $("#legend-table").hide();
        $("#map-colorby-status").show();
        $.getJSON(url, function(data) {

            var features = [];
            var projectIdMap = {};
            var bounds = new google.maps.LatLngBounds();
            var geoPoints = data;
            var legends = [];

            if (geoPoints.total) {
                var projectLinkPrefix = "${createLink(controller:'project')}/";
                var siteLinkPrefix = "${createLink(controller:'site')}/";
                $("#numberOfSites").html(geoPoints.total + " sites");

                if (geoPoints.total > 0) {
                    var staticColors =
                            ['#458B00','#FF0000','#FF00FF','#282828','#8B4513','#FF8000','#1E90FF','#a549f6','#20988e','#afaec9',
                                '#dc0430','#aa7f69','#1077f1','#6da1ab','#3598e6','#95294d','#f27ad5','#dfd06e','#c16b54','#34f242'];
                    $.each(geoPoints.selectedFacetTerms, function(i,facet){
                        var legend = {};
                        var hex = i < staticColors.length ? staticColors[facet.index] : getRandomColor();
                        legend.color = hex;
                        legend.legendName = facet.legendName;
                        legend.count = facet.count;
                        legends.push(legend);
                    });
                    $.each(geoPoints.projects, function(j, project) {
                        var projectId = project.projectId
                        var projectName = project.name

                        if (project.geo && project.geo.length > 0) {
                            $.each(project.geo, function(k, el) {
                                var point = {
                                    type: "dot",
                                    id: projectId,
                                    name: projectName,
                                    popup: generatePopup(projectLinkPrefix,projectId,projectName,project.org,siteLinkPrefix,el.siteId, el.siteName),
                                    latitude: el.loc.lat,
                                    longitude: el.loc.lon,
                                    color: "-1"
                                }
                                var lat = parseFloat(point.latitude);
                                var lon = parseFloat(point.longitude);
                                if (!isNaN(lat) && !isNaN(lon)) {
                                    if (lat >= -90 && lat <=90 && lon >= -180 && lon <= 180) {
                                        if(el.index !== undefined && el.index != null){
                                            point.color = legends[el.index].color;
                                            point.legendName = el.legendName;
                                        }
                                        features.push(point);
                                        bounds.extend(new google.maps.LatLng(el.loc.lat,el.loc.lon));
                                        if (projectId) {
                                            projectIdMap[projectId] = true;
                                        }
                                    }
                                }

                            });
                        }
                    });

                    if (facetList && facetList.length > 0) {
                        // convert projectIdMap to a list and add to global var
                        projectListIds = []; // clear the list
                        for (var id in projectIdMap) {
                            projectListIds.push(id);
                        }
                    } else {
                        projectListIds = []; // clear the list
                    }
                }
            }

            //To reduce memory footprint and leak, make sure to clear feature before loading new feature.
            initialiseMap(features, bounds, mapOptions);
            $("#legend-table").fadeIn();
            $("#map-colorby-status").hide();

            mapBounds = bounds;
            features.length > 0 ? showLegends(legends) : "";

        }).error(function (request, status, error) {
            console.error("AJAX error", status, error);
        });
    }

    function initialiseMap(features, bounds, mapOptions){

        var defaults = {
            includeLegend: true
        };
        var config = $.extend({}, defaults, mapOptions);

        var mapData = {
            "zoomToBounds": true,
            "zoomLimit": 12,
            "highlightOnHover": false,
            "features": features
        };

        var layers = <fc:modelAsJavascript model="${geographicFacets?:[]}"/>;
        $.each(layers, function(i, layer) {
            layer.type = 'pid';
            layer.style = 'polygon';
            layer.excludeBounds = true;
            mapData.features.push(layer);
        });

        var mapOptions = {
            mapContainer: "map",
            zoomToBounds:true,
            scrollwheel: false,
            zoomLimit:16,
            featureService: "${createLink(controller: 'proxy', action:'feature')}",
            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
        };

        this.alaMap = new MapWithFeatures(mapOptions, mapData);

        if (!bounds.isEmpty()) {
        this.alaMap.map.fitBounds(bounds);
        } else {
            this.alaMap.map.setZoom(4);
        }

        // Create the DIV to hold the control and
        // call the HomeControl() constructor passing
        // in this DIV.

        var homeControlDiv = document.createElement('div');
        var homeControl = new HomeControl(homeControlDiv, alaMap.map);
        homeControlDiv.index = 2;
        this.alaMap.map.controls[google.maps.ControlPosition.BOTTOM_LEFT].push(homeControlDiv);

        if (config.includeLegend) {
            var homeToggleControlDiv = document.createElement('div');
            var toggleControl = new HomeToggleControl(homeToggleControlDiv, alaMap.map);
            homeToggleControlDiv.index = 1;
            this.alaMap.map.controls[google.maps.ControlPosition.BOTTOM_LEFT].push(homeToggleControlDiv);
        }
        var numSitesHtml = "";
        if(features.length > 0){
            numSitesHtml = features.length + " sites";
        } else {
            numSitesHtml = "0 sites <span class=\"label label-important\">No georeferenced points for the selected projects</span>";
        }

        $("#numberOfSites").html(numSitesHtml);
    }


    function generatePopup(projectLinkPrefix, projectId, projectName, orgName, siteLinkPrefix, siteId, siteName){

        //console.log('Generating popup for ' + siteId);

        var html = "<div class='projectInfoWindow'>";

        if (projectId && projectName) {
            html += "<div><i class='icon-home'></i> <a href='" +
                    projectLinkPrefix + projectId + "'>" +projectName + "</a></div>";
        }

        if(orgName !== undefined && orgName != ''){
            html += "<div><i class='icon-user'></i> Org name: " +orgName + "</div>";
        }

        html+= "<div><i class='icon-map-marker'></i> Site: <a href='" +siteLinkPrefix + siteId + "'>" + siteName + "</a></div>";
        return html;
    }

    function HomeControl(controlDiv, map) {

        // Set CSS styles for the DIV containing the control
        // Setting padding to 5 px will offset the control
        // from the edge of the map
        controlDiv.style.padding = '5px';

        // Set CSS for the control border
        var controlUI = document.createElement('div');
        controlUI.style.backgroundColor = 'white';
        controlUI.style.borderStyle = 'solid';
        controlUI.style.borderWidth = '1px';
        controlUI.style.cursor = 'pointer';
        controlUI.style.textAlign = 'center';
        controlUI.title = 'Click to set the map to show all sites';
        controlDiv.appendChild(controlUI);

        // Set CSS for the control interior
        var controlText = document.createElement('div');
        controlText.style.fontFamily = 'Arial,sans-serif';
        controlText.style.fontSize = '12px';
        controlText.style.paddingLeft = '6px';
        controlText.style.paddingRight = '6px';
        controlText.innerHTML = '<b>Reset</b>';
        controlUI.appendChild(controlText);

        // Setup the click event listeners
        google.maps.event.addDomListener(controlUI, 'click', function() {
            this.alaMap.map.fitBounds(mapBounds);
        });

    }


    function HomeToggleControl(controlDiv, map) {

        // Set CSS styles for the DIV containing the control
        // Setting padding to 5 px will offset the control
        // from the edge of the map
        controlDiv.style.padding = '5px';

        // Set CSS for the control border
        var controlUI = document.createElement('div');
        controlUI.style.backgroundColor = 'white';
        controlUI.style.borderStyle = 'solid';
        controlUI.style.borderWidth = '1px';
        controlUI.style.cursor = 'pointer';
        controlUI.style.textAlign = 'center';
        controlUI.title = 'Click to set the map to show all sites';
        controlDiv.appendChild(controlUI);

        // Set CSS for the control interior
        var controlText = document.createElement('div');
        controlText.style.fontFamily = 'Arial,sans-serif';
        controlText.style.fontSize = '12px';
        controlText.style.paddingLeft = '6px';
        controlText.style.paddingRight = '6px';
        controlText.innerHTML = '<i class="icon-list"></i>';
        controlUI.appendChild(controlText);
        // Setup the click event listeners
        google.maps.event.addDomListener(controlUI, 'click', function() {
           $("#map-legend").toggle();
        });

    }

    function showLegends(legends){
        legends.sort(function(a, b){
            if (a.legendName > b.legendName) {
                return 1;
            }
            if (a.legendName < b.legendName) {
                return -1;
            }
            return 0;
        });
        var table = $("#legend-1 tbody");
        $(table).empty();
        var firstHalf = Math.ceil(legends.length / 2);
        var legends1 = legends.slice(0,firstHalf);
        var legends2 = legends.slice(firstHalf,legends.length);
        $.each(legends1, function(idx, legend){
            table.append('<tr>' +
             '<td><input checked type="checkbox" class="legendSelection" id="a'+idx+'" value="'+legend.legendName+'"></td>' +
               '<td style="background:'+legend.color+'"></td>' +
               '<td width="200"> '+legend.legendName + ' (' + legend.count + ')</td></tr>');
        });

        var table1 = $("#legend-2 tbody");
        $(table1).empty();
        $.each(legends2, function(idx, legend){
            table1.append('<tr>' +
             '<td><input checked type="checkbox" class="legendSelection" id="b'+idx+'" value="'+legend.legendName+'"></td>' +
               '<td style="background:'+legend.color+'"></td>' +
               '<td width="200">'+legend.legendName + ' (' + legend.count + ')</td></tr>');
        });
        $('input[type="checkbox"][class="legendSelection"]').change(function() {
            var map = $('#'+this.id).prop('checked') ? alaMap.map : null;
            this.alaMap.toggleMarkerVisibility(this.value, map);
        });
    }

    function getRandomColor(h) {
        return (function(h){return '#000000'.substr(0,7-h.length)+h})((~~(Math.random()*(1<<24))).toString(16));
    }

</r:script>
