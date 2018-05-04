<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Home | Field Capture</title>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}"
    }
    </asset:script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
</head>
<body>
<div id="wrapper" class="container-fluid">
    <div class="row-fluid large-space-after hide">
        <div class="span12" id="heading">
            <h1 class="pull-left">Field Capture</h1>
            <g:form controller="search" method="GET" class=" form-horizontal pull-right" style="padding-top:5px;">
                <div class="input-append">
                    <g:textField class="input-large" name="query"/>
                    <button class="btn" type="submit">Search</button>
                </div>
            </g:form>
        </div>
    </div>

    <g:if test="${flash.error || geoPoints.error}">
        <g:set var="error" value="${flash.error?:geoPoints.error}"/>
        <div class="row-fluid">
            <div class="alert alert-error large-space-before">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <span>Error: ${error}</span>
            </div>
        </div>
    </g:if>
    <g:elseif test="${geoPoints.hits?.total?:0 > 0}">
        <div class="row-fluid large-space-before">
            <div class="span6 well well-small ">
                %{--<h3 class="">Sites</h3>--}%
                <div class="map-box">
                    <div id="map" style="width: 100%; height: 100%;"></div>
                </div>
                <div class="facetBtns">
                    <button class="btn btn-info btn-mini facetBtn" data-facet="stateFacet" data-value="">All States (${geoPoints.hits.total})</button>
                    <g:each var="t" in="${geoPoints.facets?.stateFacet?.terms}">
                        <g:if test="${t.term}">
                            <button class="btn btn-mini facetBtn" data-facet="stateFacet"
                                    data-value="${t.term}">${t.term} (${t.count})</button>
                        </g:if>
                    </g:each>
                </div>
                <div class="facetBtns">
                    <button class="btn btn-info btn-mini facetBtn" data-facet="nrmFacet" data-value="">All NRMs (${geoPoints.hits.total})</button>
                    <g:each var="t" in="${geoPoints.facets?.nrmFacet?.terms}">
                        <g:if test="${t.term}">
                            <button class="btn btn-mini facetBtn" data-facet="nrmFacet"
                                    data-value="${t.term}">${t.term} (${t.count})</button>
                        </g:if>
                    </g:each>
                </div>
            </div>
            <div class="span6 well well-small list-box">
                %{--<h3 class="pull-left">Projects</h3>--}%
                <div class="scroll-list clearfix" id="projectList">
                    <table class="table table-bordered table-hover" id="projectTable" data-sort="lastUpdated" data-order="DESC" data-offset="0" data-max="10">
                        <thead>
                        <tr>
                            <th width="85%" data-sort="nameSort" data-order="ASC" class="header">Project name</th>
                            <th width="15%" data-sort="lastUpdated"  data-order="DESC" class="header headerSortUp">Last&nbsp;updated&nbsp;</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                    <div id="paginateTable" class="hide" style="text-align:center;">
                        <span id="paginationInfo" style="display:inline-block;float:left;margin-top:4px;"></span>
                        <button class="btn btn-small prev"><i class="icon-chevron-left"></i> previous</button>
                        <button class="btn btn-small next">next <i class="icon-chevron-right"></i></button>
                        <span id="project-filter-warning" class="label filter-label label-warning hide pull-left">Filtered</span>
                        <div class="control-group pull-right dataTables_filter">
                            <div class="input-append">
                                <g:textField class="filterinput input-medium" data-target="project"
                                             title="Type a few characters to restrict the list." name="projects"
                                             placeholder="filter"/>
                                <button type="button" class="btn clearFilterBtn"
                                        title="clear"><i class="icon-remove"></i></button>
                            </div>
                        </div>
                    </div>
                </div>
                %{-- template for jQuery DOM injection --}%
                <table id="projectRowTempl" class="hide">
                    <tr>
                        <td class="td1">
                            <a href="#" class="projectTitle" id="a_" data-id="" title="click to show/hide details">
                                <span class="showHideCaret">&#9658;</span> <span class="projectTitleName">$name</span></a>
                            <div class="hide projectInfo" id="proj_$id">
                                <div class="homeLine">
                                    <i class="icon-home"></i>
                                    <a href="">View project page</a>
                                </div>
                                <div class="sitesLine">
                                    <i class="icon-map-marker"></i>
                                    Sites: <a href="#" data-id="$id" class="zoom-in btnX btn-miniX"><i
                                        class="icon-plus-sign"></i> zoom in</a>
                                    <a href="#" data-id="$id" class="zoom-out btnX btn-miniX"><i
                                            class="icon-minus-sign"></i> zoom out</a>
                                </div>
                                <div class="orgLine">
                                    <i class="icon-user"></i>
                                </div>
                                <div class="descLine">
                                    <i class="icon-info-sign"></i>
                                </div>
                            </div>
                        </td>
                        <td class="td2">$date</td>
                    </tr>
                </table>

            </div><!-- /.span6.well -->
        </div><!-- /.row-fluid -->
    </g:elseif>
    <g:else>
        <div class="row-fluid ">
            <div class="span12">
                <div class="alert alert-error large-space-before">
                    Error: search index returned 0 results
                </div>
            </div>
        </div>
    </g:else>

    <g:if env="development">
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <!--h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre-->
            <h4>Activities</h4>
            <pre>${activities}</pre>
            <h4>Sites</h4>
            <pre>${sites}</pre>
            <h4>Projects</h4>
            <pre>${projects}</pre>
            <h4>GeoPoints</h4>
            <pre>${geoPoints}</pre>
        </div>
    </div>
    </g:if>
</div>

<asset:script type="text/javascript">
    var projectListIds = []; // list of strings

    $(window).load(function () {
        var delay = (function(){
            var timer = 0;
            return function(callback, ms){
                clearTimeout (timer);
                timer = setTimeout(callback, ms);
            };
        })();

        // bind filters
        $('.filterinput').keyup(function() {
            //console.log("filter keyup");
            var a = $(this).val(),
                target = $(this).attr('data-target');

            var qList;

            if (a.length > 1) {
                $('#' + target + '-filter-warning').show();
                var qList = [ "_all:" +  a ]
            } else {
                $('#' + target + '-filter-warning').hide();
                qList = null;
            }

            delay(function(){
                //console.log('Time elapsed!');
                $("#projectTable").data("offset", 0);
                updateProjectTable( qList );
            }, 1000 );

            return false;
        });

        $('.clearFilterBtn').click(function () {
            var $filterInput = $(this).prev(),
                target = $filterInput.attr('data-target');
            //console.log("clear button");
            $('#' + target + '-filter-warning').hide();
            $filterInput.val('');
            $("#projectTable").data("offset", 0);
            updateProjectTable();
        });

        // highlight icon on map when project name is clicked
        var prevFeatureId;
        $('#projectTable').on("click", ".projectTitle", function(el) {
            //console.log("projectHighlight", $(this).data("id"), alaMap.featureIndex);
            el.preventDefault();
            var thisEl = this;
            var fId = $(this).data("id");
            //if (prevFeatureId) alaMap.unAnimateFeatureById(prevFeatureId);
            alaMap.animateFeatureById(fId);
            if (!prevFeatureId) {
                $("#proj_" + fId).slideToggle();
                $(thisEl).find(".showHideCaret").html("&#9660;");
            } else if (prevFeatureId != fId) {
                if ($("#proj_" + prevFeatureId).is(":visible")) {
                    // hide prev selected, show this
                    $("#proj_" + prevFeatureId).slideUp();
                    $("#a_" + prevFeatureId).find(".showHideCaret").html("&#9658;");
                    $("#proj_" + fId).slideDown();
                    $("#a_" + fId).find(".showHideCaret").html("&#9660;");
                } else {
                    //show this, hide others
                    $("#proj_" + fId).slideToggle();
                    $(thisEl).find(".showHideCaret").html("&#9660;");
                    $("#proj_" + prevFeatureId).slideUp();
                    $("#a_" + prevFeatureId).find(".showHideCaret").html("&#9658;");
                }
                alaMap.unAnimateFeatureById(prevFeatureId);
            } else {
                $("#proj_" + fId).slideToggle();
                if ($("#proj_" + fId).is(':visible')) {
                    $(thisEl).find(".showHideCaret").html("&#9658;");
                } else {
                    $(thisEl).find(".showHideCaret").html("&#9660;");
                }
                alaMap.unAnimateFeatureById(fId);
            }
            prevFeatureId = fId;
        });

        // zoom in/out to project points via +/- buttons
        var initCentre, initZoom;
        $('#projectTable').on("click", "a.zoom-in",function(el) {
            el.preventDefault();
            if (!initCentre && !initZoom) {
                initCentre = alaMap.map.getCenter();
                initZoom = alaMap.map.getZoom();
            }
            var projectId = $(this).data("id");
            var bounds = alaMap.getExtentByFeatureId(projectId);
            alaMap.map.fitBounds(bounds);
        });
        $('#projectTable').on("click", "a.zoom-out",function(el) {
            el.preventDefault();
            alaMap.map.setCenter(initCentre);
            alaMap.map.setZoom(initZoom);
        });

        // initial loading of map
        generateMap();

        // Tooltips
        $('.projectTitle').tooltip({
            placement: "right",
            container: "#projectTable",
            delay: 400
        });

        // sorting project table
        $("#projectTable .header").click(function(el) {
            var sort = $(this).data("sort");
            var order = $(this).data("order");
            var prevSort =  $("#projectTable").data("sort");
            var newOrder = (prevSort != sort) ? order : ((order == "ASC") ? "DESC" :"ASC");
            // update new data attrs in table
            $("#projectTable").data("sort", sort);
            $("#projectTable").data("order", newOrder); // toggle
            $("#projectTable").data("offset", 0); // always start at page 1
            $(this).data("order", newOrder);
            // update CSS classes
            $("#projectTable .header").removeClass("headerSortDown").removeClass("headerSortUp"); // remove all sort classes first
            $(this).addClass((newOrder == "ASC") ? "headerSortDown" : "headerSortUp");
            // $(this).removeClass((newOrder == "ASC") ? "headerSortUp" : "headerSortDown");
            updateProjectTable();
        });

        // facet buttons
        $(".facetBtn").click(function(el) {
            var facetList = [];
            var facet = $(this).data("facet");
            var facetVal = $(this).data("value");
            var prevFacet =  $("#projectTable").data("facetName");
            // store values in table
            $("#projectTable").data("facetName",facet);
            $("#projectTable").data("facetValue",facetVal);
            if (facetVal.length > 1) {
                facetList.push(facet + ":" + facetVal);
            }
            $("#projectTable").data("offset", 0);
            generateMap(facetList);
            // change button class to indicate this facet is active
            if (facet != prevFacet) {
                // different facet group selected - reset prev
                $(".facetBtn[data-facet='" + prevFacet + "']").removeClass("btn-info");
                $(".facetBtn[data-value='']").addClass("btn-info");
            }
            $(".facetBtn[data-facet='" + facet + "']").removeClass("btn-info");
            $(this).addClass("btn-info");
        });

        // next/prev buttons in project list table
        $("#paginateTable .btn").not(".clearFilterBtn").click(function(el) {
            // Don't trigger if button is disabled
            if (!$(this).hasClass("disabled")) {
                 //var prevOrNext = (this).hasClass("next") ? "next" : "prev";
                var offset = $("#projectTable").data("offset");
                var max = $("#projectTable").data("max");
                var newOffset = $(this).hasClass("next") ? (offset + max) : (offset - max);
                $("#projectTable").data("offset", newOffset);
                //console.log("offset", offset, newOffset, $("#projectTable").data("offset"));
                updateProjectTable();
            }
        });
    });

    function generateMap(facetFilters) {
        var url = "${createLink(action:'geoService')}";

        if (facetFilters && facetFilters.length > 0) {
            url += "?fq=" + facetFilters.join("&fq=");
        }

        $.getJSON(url, function(data) {
            //console.log("getJSON data", data);
            var features = [];
            var projectIdMap = {};
            var bounds = new google.maps.LatLngBounds();
            var geoPoints = data;

            if (geoPoints.hits) {
                //console.log("geoPoints: ", geoPoints);
                var projectLinkPrefix = "${createLink(controller:'project')}/";
                var siteLinkPrefix = "${createLink(controller:'site')}/";

                if (geoPoints.hits.total > 0) {
                    $.each(geoPoints.hits.hits, function(j, h) {
                        var s = h["_source"];
                        var projectId = s.projectId
                        var projectName = s.name
                        //console.log("s", s, j);
                        if (s.geo && s.geo.length > 0) {
                            $.each(s.geo, function(k, el) {
                                var point = {
                                    type: "dot",
                                    id: projectId,
                                    name: projectName,
                                    popup: generatePopup(projectLinkPrefix,projectId,projectName,s.organisationName,siteLinkPrefix,el.siteId, el.siteName),
                                    latitude: el.loc.lat,
                                    longitude: el.loc.lon
                                }
                                //console.log("point", point);
                                features.push(point);
                                bounds.extend(new google.maps.LatLng(el.loc.lat,el.loc.lon));
                                if (projectId) {
                                    projectIdMap[projectId] = true;
                                }
                            });
                        }
                    });

                    if (facetFilters && facetFilters.length > 0) {
                        // convert projectIdMap to a list and add to global var
                        projectListIds = []; // clear the list
                        for (var id in projectIdMap) {
                            projectListIds.push(id);
                        }
                    } else {
                        projectListIds = []; // clear the list
                    }

                    updateProjectTable();
                    //console.log("features count", features.length);
                }
            }

            var mapData = {
                "zoomToBounds": true,
                "zoomLimit": 12,
                "highlightOnHover": false,
                "features": features
            }

            window.alaMap = new new ALA.Map("map", {});

            alaMap.map.fitBounds(bounds);

        }).error(function (request, status, error) {
            console.error("AJAX error", status, error);
        });
    }

    function generatePopup(projectLinkPrefix, projectId, projectName, orgName, siteLinkPrefix, siteId, siteName){
        var html = "<div class='projectInfoWindow'>";

        if (projectId && projectName) {
            html += "<div><i class='icon-home'></i> <a href='" +
                        projectLinkPrefix + projectId + "'>" +projectName + "</a></div>";
        }

        if(orgName !== undefined && orgName != ''){
            html += "<div><i class='icon-user'></i> Org name:" +orgName + "</div>";
        }

        html+= "<div><i class='icon-map-marker'></i> Site: <a href='" +siteLinkPrefix + siteId + "'>" + siteName + "</a></div>";
        return html;
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

    /**
    * Dynamically update the project list table via AJAX
    *
    * @param facetFilters (an array)
    */
    function updateProjectTable(facetFilters) {
        var url = "${createLink(action:'getProjectsForIds')}"; //?sort=lastUpdated&order=DESC";
        var sort = $('#projectTable').data("sort");
        var order = $('#projectTable').data("order");
        var offset = $('#projectTable').data("offset");
        var params = "sort="+sort+"&order="+order+"&offset="+offset;

        if (projectListIds.length > 0) {
            params += "&ids=" + projectListIds.join(",");
        } else {
            params += "&query=class:au.org.ala.ecodata.Project";
        }
        if (facetFilters) {
            params += "&fq=" + facetFilters.join("&fq=");
        }

        $.post(url, params, function(data1) {
            //console.log("getJSON data", data);
            var data
            if (data1.resp) {
                data = data1.resp;
            } else if (data1.hits) {
                data = data1;
            }
            if (data.error) {
                console.error("Error: " + data.error);
            } else {
                var total = data.hits.total;
                $('#projectTable').data("total", total);
                $('#paginateTable').show();
                if (total == 0) {
                    $('#paginationInfo').html("Nothing found");

                } else {
                    var max = data.hits.hits.length
                    $('#paginationInfo').html((offset+1)+" to "+(offset+max) + " of "+total);
                    if (offset == 0) {
                        $('#paginateTable .prev').addClass("disabled");
                    } else {
                        $('#paginateTable .prev').removeClass("disabled");
                    }
                    if (offset >= (total - 10) ) {
                        $('#paginateTable .next').addClass("disabled");
                    } else {
                        $('#paginateTable .next').removeClass("disabled");
                    }
                }

                $('#projectTable tbody').empty();
                populateTable(data);
            }
        }).error(function (request, status, error) {
            //console.error("AJAX error", status, error);
            $('#paginationInfo').html("AJAX error:" + status + " - " + error);
        });
    }

    /**
    * Update the project table DOM using a plain HTML template (cloned)
    *
    * @param data
    */
    function populateTable(data) {
        //console.log("populateTable", data);
        $.each(data.hits.hits, function(i, el) {
            //console.log(i, "el", el);
            var id = el._id;
            var src = el._source
            var $tr = $('#projectRowTempl tr').clone(); // template
            $tr.find('.td1 > a').attr("id", "a_" + id).data("id", id);
            $tr.find('.td1 .projectTitleName').text(src.name); // projectTitleName
            $tr.find('.projectInfo').attr("id", "proj_" + id);
            $tr.find('.homeLine a').attr("href", "${createLink(controller: 'project')}/" + id);
            $tr.find('a.zoom-in').data("id", id);
            $tr.find('a.zoom-out').data("id", id);
            $tr.find('.orgLine').append(src.organisationName);
            $tr.find('.descLine').append(src.description);
            $tr.find('.td2').text(formatDate(Date.parse(src.lastUpdated))); // relies on the js_iso8601 resource
            //console.log("appending row", $tr);
            $('#projectTable tbody').append($tr);
        });
    }

    /**
    * Format a date given an Unix time number (output of Date.parse)
    *
    * @param t
    * @returns {string}
    */
    function formatDate(t) {
        var d = new Date(t);
        var yyyy = d.getFullYear().toString();
        var mm = (d.getMonth()+1).toString(); // getMonth() is zero-based
        var dd  = d.getDate().toString();
        return yyyy + "-" + (mm[1]?mm:"0"+mm[0]) + "-" + (dd[1]?dd:"0"+dd[0]);
    }

    /* This implementation of list filtering is not used but is left for reference.
       The jQuery implementation is quicker and cleaner in this case. This may
       not be true if the data model is needed for other purposes.
    var data = {};
    data.sites = /$/{sites};

    function ViewModel (data) {
        var self = this;
        self.sitesFilter = ko.observable("");
        self.sites = ko.observableArray(data.sites);
        self.isSitesFiltered = ko.observable(false);
        // Animation callbacks for the lists
        self.showElement = function(elem) { if (elem.nodeType === 1) $(elem).hide().slideDown() };
        self.hideElement = function(elem) { if (elem.nodeType === 1) $(elem).slideUp(function() { $(elem).remove(); }) };

        self.filteredSites = ko.computed(function () {
            var filter = self.sitesFilter().toLowerCase();
            var regex = new RegExp('\\b' + filter, 'i');
            if (!filter || filter.length === 1) {
                self.isSitesFiltered(false);
                return self.sites();
            } else {
                self.isSitesFiltered(true);
                return ko.utils.arrayFilter(self.sites(), function (item) {
                    return regex.test(item.name);
                })
            }
        });
        self.clearSiteFilter = function () {
            self.sitesFilter("");
        }
    }
    var viewModel = new ViewModel(data);
    ko.applyBindings(viewModel);*/

</asset:script>
</body>
</html>