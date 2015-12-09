<div class="tab-pane" id="mapView">
    <m:map id="siteMap" width="100%"/>

    <div style=" float: right;" id="map-info">
        <span id="numberOfProjects">${projectCount ?: 0}</span> projects with <span
            id="numberOfSites">[calculating]</span>
    </div>
</div>

<r:script>

    function generateMap(facetList) {
        var url = "${createLink(controller: 'nocas', action: 'geoService')}?max=10000&geo=true";

        if (facetList && facetList.length > 0) {
            url += "&fq=" + facetList.join("&fq=");
        }
        <g:if test="${params.fq}">
            <g:set var="fqList" value="${[params.fq].flatten()}"/>
            url += "&fq=${fqList.collect { it.encodeAsURL() }.join('&fq=')}";
        </g:if>

        $.getJSON(url, function(data) {
            var features = [];
            var geoPoints = data;

            if (geoPoints.total) {
                var projectLinkPrefix = "${createLink(controller: 'project')}/";
                    var siteLinkPrefix = "${createLink(controller: 'site')}/";
                    $("#numberOfSites").html(geoPoints.total + " sites");

                    if (geoPoints.total > 0) {
                        $.each(geoPoints.projects, function(j, project) {
                            var projectId = project.projectId
                            var projectName = project.name

                            if (project.geo && project.geo.length > 0) {
                                $.each(project.geo, function(k, el) {
                                    var point = {
                                        siteId: el.siteId,
                                        lat: parseFloat(el.loc.lat),
                                        lng: parseFloat(el.loc.lon),
                                        geometry: el.geometry,
                                        popup: generatePopup(projectLinkPrefix, projectId, projectName, project.org, siteLinkPrefix, el.siteId, el.siteName)
                                    }

                                    if (isValidPoint(point)) {
                                        features.push(point);
                                    }
                                });
                            }
                        });
                    }
                }

                initialiseMap(features);
            }).error(function (request, status, error) {
                console.error("AJAX error", status, error);
            }
        );
    }

    function isValidPoint(point) {
        return !isNaN(point.lat) && !isNaN(point.lng) && point.lat >= -90 && point.lat <=90 && point.lng >= -180 && point.lng <= 180
    }

    function initialiseMap(features){
        var mapOptions = {
            drawControl: false,
            singleMarker: false,
            useMyLocation: false,
            allowSearchByAddress: false,
            draggableMarkers: false,
            showReset: false,
            zoomToObject: false,
            wmsLayerUrl: fcConfig.spatialWms + "/wms/reflect?",
            wmsFeatureUrl: fcConfig.featureService + "?featureId=",
        };
        var map = new ALA.Map("siteMap", mapOptions);
        var layers = {};

        map.addButton("<span class='fa fa-refresh reset-map' title='Reset zoom'></span>", map.fitBounds, "bottomleft");

        features.forEach(function (feature) {
            if (feature.geometry) {
                var geometry = Biocollect.MapUtilities.featureToValidGeoJson(feature.geometry);

                var options = {
                    markerWithMouseOver: true,
                    markerLocation: [feature.lat, feature.lng],
                    popup: feature.popup
                }

                map.setGeoJSON(geometry, options);
            }
        });

        var numSitesHtml = "";
        if(features.length > 0){
            numSitesHtml = features.length + " sites";
        } else {
            numSitesHtml = "0 sites <span class='label label-important'>No georeferenced points for the selected projects</span>";
        }

        $("#numberOfSites").html(numSitesHtml);
    }

    function generatePopup(projectLinkPrefix, projectId, projectName, orgName, siteLinkPrefix, siteId, siteName){
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
</r:script>
