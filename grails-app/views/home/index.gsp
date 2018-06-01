<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
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
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}"
    }
    </asset:script>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <asset:javascript src="common.js"/>
    <asset:javascript src="forms-manifest.js"/>
    <asset:javascript src="siteDisplay.js"/>
</head>
<body>
<div id="wrapper" class="container-fluid">

<div class="row-fluid">
    <g:if test="${flash.errorMessage}">
        <div class="container-fluid">
            <div class="alert alert-error">
                ${flash.errorMessage}
            </div>
        </div>
    </g:if>

    <g:if test="${flash.message}">
        <div class="row-fluid">
            <div class="span6 alert alert-info" style="margin-bottom:0;">
                <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                ${flash.message}
            </div>
        </div>
    </g:if>
</div>

<div class="row-fluid">
    <div class="span12" id="heading">
        <h1 class="pull-left"><fc:homePageTitle/></h1>
    </div>
</div>
<div class="row-fluid large-space-after">
    <div class="span12">
        <markdown:renderHtml>${description}</markdown:renderHtml>
    </div>
</div>

<g:if test="${flash.error || results.error}">
    <g:set var="error" value="${flash.error?:results.error}"/>
    <div class="row-fluid">
        <div class="alert alert-error large-space-before">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <span>Error: ${error}</span>
        </div>
    </div>
</g:if>
<g:elseif test="${results?.hits?.total?:0 > 0}">
    <div id="" class="row-fluid ">
        <div id="facetsCol" class="span4 well well-small">
            <g:set var="reqParams" value="sort,order,max,fq"/>
            <div class="visible-phone pull-right" style="margin-top: 5px;">
                <a href="#" id="toggleFacetDisplay" rel="facetsContent" role="button" class="btn btn-small btn-inverse" style="color:white;">
                    <span>show</span> options&nbsp;
                    <b class="caret"></b>
                </a>
            </div>
            <h3 style="margin-bottom:0;">Filter results</h3>
            <button class="btn btn-small facetSearch"><i class="icon-filter"></i>Refine</button>
            <button class="btn btn-small clearFacet"><i class="icon-remove-sign"></i>Clear all</button>
            <g:if test="${params.fq}">
                <div class="currentFilters">
                    <h4>Current filters</h4>
                    <ul>
                    <%-- convert either Object and Object[] to a list, in case there are multiple params with same name --%>
                        <g:set var="fqList" value="${[params.fq].flatten().findAll { it != null }}"/>
                        <g:each var="f" in="${fqList}">
                            <g:set var="fqBits" value="${f?.tokenize(':')}"/>
                            <g:set var="newUrl"><fc:formatParams params="${params}" requiredParams="${reqParams}" excludeParam="${f}"/></g:set>
                            <li><g:message code="label.${fqBits[0]}" default="${fqBits[0]}"/>: <g:message code="label.${fqBits[1]}" default="${fqBits[1].capitalize()}"/>
                                <a href="${newUrl?:"?"}" class="btn btn-inverse btn-mini tooltips" title="remove filter">
                                    <i class="icon-white icon-remove"></i></a>
                            </li>
                        </g:each>
                    </ul>
                </div>
            </g:if>
            <div id="facetsContent" class="hidden-phone">
                <g:set var="baseUrl"><fc:formatParams params="${params}" requiredParams="${reqParams}"/></g:set>
                <g:set var="fqLink" value="${baseUrl?:"?"}"/>
            <!-- fqLink = ${fqLink} -->
                <g:each var="fn" in="${facetsList}">
                    <g:set var="f" value="${results.facets.get(fn)}"/>
                    <g:set var="max" value="${5}"/>
                    <g:if test="${fn != 'class' && f?.terms?.size() > 0}">
                        <g:set var="fName"><g:message code="label.${fn}" default="${fn?.capitalize()}"/></g:set>
                        <h4>${fName}</h4>
                        <ul style="list-style-type: none;" class="facetValues">
                            <g:each var="t" in="${f.terms}" status="i">
                                <g:if test="${i < max}">
                                    <li>
                                    		<input type="checkbox" class="facetSelection" name="facetSelection" value="fq=${fn.encodeAsURL()}:${t.term.encodeAsURL()}">
                                    		<a href="${fqLink}&fq=${fn.encodeAsURL()}:${t.term.encodeAsURL()}"><g:message
                                            code="label.${t.term.capitalize()}" default="${t.term.capitalize()}"/></a> (${t.count})
                                    </li>
                                </g:if>
                            </g:each>
                        </ul>
                        <g:if test="${f?.terms?.size() > max}">
                            <a href="#${fn}Modal" role="button" class="moreFacets tooltips" data-toggle="modal" title="View full list of values"><i class="icon-hand-right"></i> choose more...</a>
                            <div id="${fn}Modal" class="modal hide fade">
                               	<div class="modal-header">
	                                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	                                    <h3>Filter by ${fName}</h3>
	                                </div>
	                                <div class="modal-body">
	                                    <ul style="list-style-type: none;" class="facetValues">
	                                        <g:each var="t" in="${f.terms}">
	                                        		
	                                            <li data-sortalpha="${t.term.toLowerCase().trim()}" data-sortcount="${t.count}">
	                                            		<input type="checkbox" class="facetSelection" name="facetSelection" value="fq=${fn.encodeAsURL()}:${t.term.encodeAsURL()}">
	                                            		<a href="${fqLink}&fq=${fn.encodeAsURL()}:${t.term.encodeAsURL()}"><g:message
	                                                    code="label.${t.term}" default="${t.term?:'[empty]'}"/></a> (<span class="fcount">${t.count}</span>)
	                                            </li>
	                                        </g:each>
	                                    </ul>
	                                </div>
	                                <div class="modal-footer">
	                                    <div class="pull-left">
                                            <button class="btn btn-small facetSearch"><i class="icon-filter"></i>Refine</button>
	                                        <button class="btn btn-small sortAlpha"><i class="icon-filter"></i> Sort by name</button>
	                                        <button class="btn btn-small sortCount"><i class="icon-filter"></i> Sort by count</button>
	                                    </div>
                                        <a href="#" class="btn" data-dismiss="modal">Close</a>
	                                </div>
                            	 
                            </div>
                        </g:if>
                    </g:if>
                </g:each>
            </div>
        </div>
        <div class="span8">

            <div class="tabbable">
                <ul class="nav nav-tabs" data-tabs="tabs">
                    <li class=""><a id="mapView-tab" href="#mapView" data-toggle="tab">Map</a></li>
                    <li class=""><a id="projectsView-tab" href="#projectsView" data-toggle="tab">Projects</a></li>
                    <li class=""><a id="reportView-tab" href="#reportView" data-toggle="tab">Dashboard</a></li>
                    <g:if test="${fc.userIsSiteAdmin()}">
                        <li class=""><a id="downloadView-tab" href="#downloadView" data-toggle="tab">Download</a></li>
                    </g:if>

                </ul>
            </div>

            <div class="tab-content clearfix">
                <g:render template="/shared/sites" model="${[projectCount:results?.hits?.total?:0]}"/>

                <div class="tab-pane " id="projectsView">
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
                            <div class="btn-group">
                                <button class="btn btn-small prev"><i class="icon-chevron-left"></i>&nbsp;previous</button>
                                <button class="btn btn-small next">next&nbsp;<i class="icon-chevron-right"></i></button>
                            </div>
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
                                    <div class="descLine">
                                        <i class="icon-info-sign"></i>
                                    </div>
                                    <g:if test="${fc.userIsSiteAdmin()}">
                                        <div class="downloadLine">
                                            <i class="icon-download"></i>
                                            <a href="" target="_blank">Download (.xlsx)</a>
                                        </div>
                                        <div class="downloadJSONLine">
                                            <i class="icon-download"></i>
                                            <a href="" target="_blank">Download (.json)</a>
                                        </div>
                                    </g:if>

                                </div>
                            </td>
                            <td class="td2">$date</td>
                        </tr>
                    </table>
                </div>

                <div class="tab-pane" id="reportView">
                    <div class="row-fluid">
                        <g:if test="${fc.userIsAlaOrFcAdmin()}">
                        <span class="span12">
                            <h4>Report: </h4>
                            <select id="dashboardType" name="dashboardType"><option value="dashboard">Activity Outputs</option><option value="greenArmy">Green Army</option><option value="announcements">Announcements</option></select>
                        </span>
                        </g:if>
                        <g:else>
                            <select id="dashboardType" name="dashboardType" style="display:none"><option value="dashboard">Activity Outputs</option><option value="greenArmy">Green Army</option></select>
                        </g:else>
                    </div>
                    <div class="loading-message">
                        <img src="${asset.assetPath(src:'loading.gif')}" alt="saving icon"/> Loading...
                    </div>
                    <div id="dashboard-content">

                    </div>
                </div>
                %{-- hiding the downloads from non-admin until they are approved for public consumption. --}%
                <g:if test="${fc.userIsSiteAdmin()}">
                    <div class="tab-pane" id="downloadView">
                        <h3>Download data for a filtered selection of projects</h3>
                        <table style="width: 50%;">
                            <thead>
                            <tr><th></th>
                                <th><b>Summary data</b></th>
                                <th><b>All data</b></th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td width="10%">1</td>
                                <td width="45%">
                                    <a target="_blank" href="${grailsApplication.config.grails.serverURL}/search/downloadSummaryData<fc:formatParams params="${params}"/>view=json">JSON</a>
                                </td>
                                <td width="45%">
                                    <a target="_blank" href="${grailsApplication.config.grails.serverURL}/search/downloadAllData<fc:formatParams params="${params}"/>&view=json">JSON</a>
                                </td>
                             </tr>
                            <tr>
                                <td width="10%">2</td>
                                <td width="45%">
                                    <a target="_blank" href="${grailsApplication.config.grails.serverURL}/search/downloadSummaryData<fc:formatParams params="${params}"/>&view=xlsx">XLSX</a>
                                </td>
                                <td width="45%">
                                    <a target="_blank" href="${grailsApplication.config.grails.serverURL}/search/downloadAllData<fc:formatParams params="${params}"/>&view=xlsx">XLSX</a>
                                </td>
                            </tr>
                            </tbody>
                        </table>

                </div>
                </g:if>
            </div>
            <p>&nbsp;</p>
            <fc:getSettingContent settingType="${SettingPageType.ABOUT}"/>
        </div>
    </div>
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

</div>

<asset:script type="text/javascript">
    var projectListIds = [], facetList = [], mapDataHasChanged = false, mapBounds, projectSites, siteDisplay; // globals

    $(window).load(function () {
        $.fn.clicktoggle = function(a, b) {
            return this.each(function() {
                var clicked = false;
                $(this).click(function() {
                    if (clicked) {
                        clicked = false;
                        return b.apply(this, arguments);
                    }
                    clicked = true;
                    return a.apply(this, arguments);
                });
            });
        };
        var delay = (function(){
            var timer = 0;
            return function(callback, ms){
                clearTimeout (timer);
                timer = setTimeout(callback, ms);
            };
        })();

        var loadReport = function(reportType) {
            var $content = $('#dashboard-content');
            var $loading = $('.loading-message');
            $content.hide();
            $loading.show();

            $.get(fcConfig.dashboardUrl,{report:reportType}, function(data) {
                $content.show();
                $loading.hide();
                $content.html(data);
                $('#reportView .helphover').popover({animation: true, trigger:'hover', container:'body'});
            });
        };

       var TAB_STATE_KEY = 'project-tab-state';
        var initialisedReport = false, initialisedMap = false, initialisedProjects = false;
        var initialiseTab = function(tab) {
            if (tab === '#mapView' && !initialisedMap) {
                generateMap(facetList);
                initialisedMap = true;
            }
            else if (tab === '#projectsView' && !initialisedProjects) {
                updateProjectTable();
                initialisedProjects = true;
            }
            else if (tab === '#reportView' && !initialisedReport) {
                initialisedReport = true;
                var reportType = amplify.store('report-type-state');
                var $reportSelector = $('#dashboardType');
                if (reportType) {
                    $reportSelector.val(reportType);
                }
                $reportSelector.change(function() {
                    var reportType = $reportSelector.val();
                    amplify.store('report-type-state', reportType);
                    loadReport(reportType);
                }).trigger('change');
            }
        };
        // retain tab state for future re-visits
        $('a[data-toggle="tab"]').on('shown', function (e) {
            var tab = e.currentTarget.hash;
            amplify.store(TAB_STATE_KEY, tab);
            initialiseTab(tab);
        });

        // re-establish the previous tab state
        var storedTab = amplify.store(TAB_STATE_KEY) || '#mapView';
        $('.nav-tabs a[href="'+storedTab+'"]').tab('show');

        // project list filter
        $('.filterinput').keyup(function() {
            //console.log("filter keyup");
            var a = $(this).val(),
                target = $(this).attr('data-target');

            var qList;

            if (a.length > 1) {
                $('#' + target + '-filter-warning').show();
                var qList = [ "_all:" +  a.toLowerCase() ]
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
            } else {
                $("#proj_" + fId).slideToggle();
                if ($("#proj_" + fId).is(':visible')) {
                    $(thisEl).find(".showHideCaret").html("&#9658;");
                } else {
                    $(thisEl).find(".showHideCaret").html("&#9660;");
                }
            }
            prevFeatureId = fId;
        });

        // zoom in/out to project points via +/- buttons
        var initCentre, initZoom;
        $('#projectTable').on("click", "a.zoom-in",function(el) {
            el.preventDefault();

            if (!projectSites) {
                alert("No sites found for project");
                return false;
            }

            if (!initCentre && !initZoom) {
                initCentre = alaMap.map.getCenter();
                initZoom = alaMap.map.getZoom();
            }

            var projectId = $(this).data("id");
            var delay = 0;
            if (!alaMap.map || alaMap.map.zoom == 0) {
                // maps not loaded yet (lazy loading and maps tab not yet clicked) - add delay
                // so that map data can be loaded #HACK
                delay = 2000;
            }
            $('#mapView-tab').tab('show');
            setTimeout(
                function() {
                    //var fId = $(this).data("id");
                    alaMap.animateFeatureById(projectId);
                    var bounds = alaMap.getExtentByFeatureId(projectId);
                    alaMap.map.fitBounds(bounds);
                }, delay
            );

        });
        $('#projectTable').on("click", "a.zoom-out",function(el) {
            el.preventDefault();
            $('#mapView-tab').tab('show');
            alaMap.map.setCenter(initCentre);
            alaMap.map.setZoom(initZoom);
        });

        // Tooltips
        $('.projectTitle').tooltip({
            placement: "right",
            container: "#projectTable",
            delay: 400
        });
        $('.tooltips').tooltip({placement: "right"});


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
            facetList = []; // reset global var
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
            mapDataHasChanged = true;
            generateMap();
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

        // in mobile view toggle display of facets
        $("#toggleFacetDisplay").click(function(e) {
            e.preventDefault();
            $(this).find("i").toggleClass("icon-chevron-down icon-chevron-right");
            if ($("#" + $(this).attr('rel')).is(":visible")) {
                $("#" + $(this).attr('rel')).addClass("hidden-phone");
                $(this).find("span").text("show");
            } else {
                $("#" + $(this).attr('rel')).removeClass("hidden-phone");
                $(this).find("span").text("hide");
            }
        });



        // sort facets in popups by term
        $(".sortAlpha").clicktoggle(function(el) {
            var $list = $(this).closest(".modal").find(".facetValues");
            sortList($list, "sortalpha", ">");
            $(this).find("i").removeClass("icon-flipped180");
        }, function(el) {
            var $list = $(this).closest(".modal").find(".facetValues");
            sortList($list, "sortalpha", "<");
            $(this).find("i").addClass("icon-flipped180");
        });
        
        $(".clearFacet").click(function(e){
       	 window.location.href ="${grailsApplication.config.grails.serverURL}";
        });
        
        $(".facetSearch").click(function(e){
        	var data = [];
        	$('input[type="checkbox"][name="facetSelection"]').each(function(i){
		        if(this.checked){
		            data.push(this.value);
		        }
		    });
			var url = "${baseUrl?:"?"}";
		    window.location.href = url + "&" + data.join('&');
        });

        // sort facets in popups by count
        $(".sortCount").clicktoggle(function(el) {
            var $list = $(this).closest(".modal").find(".facetValues");
            sortList($list, "sortcount", "<");
            $(this).find("i").removeClass("icon-flipped180");
        }, function(el) {
            var $list = $(this).closest(".modal").find(".facetValues");
            sortList($list, "sortcount", ">");
            $(this).find("i").addClass("icon-flipped180");
        });
    });

    /**
    * Sort a list by its li elements using the data-foo (dataEl) attribute of the li element
    *
    * @param $list
    * @param dataEl
    * @param op
    */
    function sortList($list, dataEl, op) {
        //console.log("args",$list, dataEl, op);
        $list.find("li").sort(function(a, b) {
            var comp;
            if (op == ">") {
                comp =  ($(a).data(dataEl)) > ($(b).data(dataEl)) ? 1 : -1;
            } else {
                comp =  ($(a).data(dataEl)) < ($(b).data(dataEl)) ? 1 : -1;
            }
            return comp;
        }).appendTo($list);
    }


    /**
    * Dynamically update the project list table via AJAX
    *
    * @param facetFilters (an array)
    */
    function updateProjectTable(facetFilters) {
        var url = "${createLink(controller:'nocas', action:'geoService')}"; //?sort=lastUpdated&order=DESC";
        var sort = $('#projectTable').data("sort");
        var order = $('#projectTable').data("order");
        var offset = $('#projectTable').data("offset");
        var params = "max=10&sort="+sort+"&order="+order+"&offset="+offset;

        if (projectListIds.length > 0) {
            params += "&ids=" + projectListIds.join(",");
        } else {
            params += "&query=class:au.org.ala.ecodata.Project";
        }
        if (facetFilters) {
            params += "&fq=" + facetFilters.join("&fq=");
        }

        <g:if test="${params.fq}">
        <g:set var="fqList" value="${[params.fq].flatten()}"/>
        params += "&fq=${fqList.collect{it.encodeAsURL()}.join('&fq=')}";
        </g:if>

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
                $("numberOfProjects").html(total);
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
            <g:if test="${fc.userIsSiteAdmin()}">
                $tr.find('.downloadLine a').attr("href", "${createLink(controller: 'project',action: 'downloadProjectData')}" + "?id="+id+"&view=xlsx");
                $tr.find('.downloadJSONLine a').attr("href", "${createLink(controller: 'project',action: 'downloadProjectData')}" + "?id="+id+"&view=json");
            </g:if>
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

</asset:script>
</body>
</html>