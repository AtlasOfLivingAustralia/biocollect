<%@ page import="java.text.SimpleDateFormat" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${site?.name?.encodeAsHTML()} | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'site', action: 'list')},Sites"/>
    <meta name="breadcrumb" content="${site.name?.encodeAsHTML()}"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            siteListUrl: "${createLink(controller: 'site', action: 'list')}",
            addStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxAddToFavourites')}",
            removeStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxRemoveFromFavourites')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
            spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
            sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
            poiGalleryUrl: "${createLink(controller: 'site', action: 'getImages')}",
            imagesForPoiUrl: "${createLink(controller: 'site', action: 'getPoiImages')}",
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            // copied from bioactivity/list.gsp
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities')}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            getRecordsForMapping: "${createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping')}",
            recordListUrl: "${createLink(controller: 'record', action: 'ajaxList')}",
            recordDeleteUrl: "${createLink(controller: 'record', action: 'delete')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            speciesPage: "${grailsApplication.config.bie.baseURL}/species/"
            },
            here = "${createLink(controller: 'site', action: 'index', id: site.siteId)}";
    </asset:script>
    <asset:stylesheet src="sites-manifest.css"/>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="sites-manifest.js"/>
</head>

<body>
<div class="container-fluid">
    <div class="alert alert-block hide well" data-bind="slideVisible: message" id="message">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <span data-bind="text: message"></span>
    </div>
    <div class="alert alert-info">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        <strong>Heads up!</strong> You can only edit the site if you have at least 'editor' privilege on all projects associated with the site. Check the projects this site is associated with on the 'Projects' tab below.
    </div>
    <ul class="breadcrumb pull-right">
        <li>
            <g:set var="disabled">${(!user) ? "disabled='disabled' title='login required'" : ''}</g:set>
        %{--Favourite functionality only available to authenticated users --}%
            <g:if test="${user}">
                <g:if test="${isSiteStarredByUser}">
                    <button class="btn btn-small" id="starBtn"><i
                            class="icon-star"></i><span>Remove from favourites</span></button>
                </g:if>
                <g:else>
                    <button class="btn btn-small" id="starBtn" ${disabled}><i
                            class="icon-star-empty"></i><span>Add to favourites</span></button>
                </g:else>
            </g:if>
            <g:link action="edit" id="${site.siteId}" class="btn btn-small"><i
                    class="icon-edit"></i> Edit site</g:link>
            <g:if test="${site?.extent?.geometry?.pid}">
                <a href="${grailsApplication.config.spatial.layersUrl}/shape/shp/${site.extent.geometry.pid}"
                   class="btn btn-small">
                    <i class="icon-download"></i>
                    Download ShapeFile
                </a>
                <a href="${grailsApplication.config.spatial.baseURL}/?pid=${site.extent.geometry.pid}"
                   class="btn btn-small"><i class="fa fa-map"></i> View in Spatial Portal</a>
            </g:if>
            <g:if test="${fc.userIsAlaAdmin()}">
                <div class="btn btn-small btn-danger" onclick="deleteSite()"><i
                        class="fa fa-remove"></i> Delete site
                </div>
            </g:if>
        </li>
    </ul>
    <div class="row-fluid space-after">
        <div class="span6"><!-- left block of header -->
            <g:if test="${flash.errorMessage || flash.message}">
                <div>
                    <div class="alert alert-error">
                        <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                        ${flash.errorMessage ?: flash.message}
                    </div>
                </div>
            </g:if>
            <div>
                <div class="clearfix">
                    <h1 class="pull-left"><strong>${site?.name?.encodeAsHTML()}</strong></h1>
                </div>
                <g:if test="${site.description?.encodeAsHTML()}">
                    <dl>
                        <dt><h3>Site description</h3></dt>
                        <dd>${site.description?.encodeAsHTML()}</dd>
                    </dl>
                </g:if>
            </div>

            <h3>Site metadata</h3>
            <dl class="dl-horizontal">
                <dt>External Id</dt>
                <dd>${site.externalId ?: 'Not specified'}</dd>
                <dt>Type</dt>
                <dd>${site.type ?: 'Not specified'}</dd>
                <dt>Area</dt>
                <dd>
                    <g:if test="${site?.extent?.geometry?.area}">
                        ${site.extent.geometry.area} square km
                    </g:if>
                    <g:else>
                        Not specified
                    </g:else>
                </dd>
                <g:if test="${site.extent?.geometry}">
                    <fc:siteFacet site="${site}" label="State/territory" facet="state"/>
                    <fc:siteFacet label="Local government area" site="${site}" facet="lga"/>
                    <fc:siteFacet label="NRM" site="${site}" facet="nrm"/>
                    <dt>Locality</dt>
                    <dd>${site.extent.geometry.locality ?: 'Not specified'}</dd>
                    <dt data-toggle="tooltip" title="NVIS major vegetation group">NVIS major vegetation group</dt>
                    <dd>${site.extent.geometry.mvg ?: 'Not specified'}</dd>
                    <dt data-toggle="tooltip" title="NVIS major vegetation subgroup">NVIS major vegetation subgroup</dt>
                    <dd>${site.extent.geometry.mvs ?: 'Not specified'}</dd>
                </g:if>
                <g:if test="${site.notes}">
                    <dt>Notes</dt>
                    <dd>${site.notes?.encodeAsHTML()}</dd>
                </g:if>
            </dl>
            <script>
                $('.dl-horizontal').tooltip()
            </script>
        </div>

        <div class="span6">
            <div id="siteNotDefined" class="hide pull-right">
                <span class="label label-important">This site does not have a geoference associated with it.</span>
            </div>
            <m:map id="smallMap" width="100%" height="500px"/>
        </div>
    </div>

    <div id="detailsLinkedToSite">
        <ul class="nav nav-tabs" id="myTab">
            <li class="active"><a href="#sitePhotopoints" data-toggle="tab">Photo points</a></li>
            <g:if test="${site.projects}">
                <li><a href="#siteProjects" data-toggle="tab">Projects</a></li>
            </g:if>
            <li><a href="#siteActivities" data-toggle="tab">Records</a></li>
        </ul>

        <div class="tab-content">
            <!-- ko stopBinding: true -->
            <div class="tab-pane active" id="sitePhotopoints">
                <g:render template="poiGallery"
                          model="${[siteId: site.siteId, siteElementId: 'sitePhotopoints']}"></g:render>
            </div>
            <!-- /ko -->
            <div class="tab-pane" id="siteProjects">
                <g:if test="${site.projects}">
                    <div>
                        <p>Projects associated with this site -</p>
                        <ol>
                            <g:each in="${site.projects}" var="p" status="count">
                                <li>
                                    <g:link controller="project" action="index"
                                            id="${p.projectId}">${p.name?.encodeAsHTML()}</g:link>
                                </li>
                            </g:each>
                        </ol>
                    </div>
                </g:if>
            </div>

            <div class="tab-pane" id="siteActivities">
                <!-- ko if: activities().length == 0 -->
                <div class="row-fluid">
                    <h4 class="text-left margin-bottom-five">
                        <!-- ko if: $root.searchTerm() != "" || $root.selectedFilters().length > 0 -->
                        No results
                        <!-- /ko -->
                    </h4>
                </div>
                <!-- /ko -->

                <!-- ko if: activities().length > 0 -->

                <div class="alert alert-info hide" id="downloadStartedMsg"><i
                        class="fa fa-spin fa-spinner">&nbsp;&nbsp;</i>Preparing download, please wait...</div>

                <div class="row-fluid">
                    <div class="span9">
                        <h3 class="text-left margin-bottom-2">Found <span data-bind="text: total()"></span> record(s)
                        </h3>
                    </div>
                </div>
                <g:render template="/shared/pagination"/>
                <!-- ko foreach : activities -->
                <div class="row-fluid">
                    <div class="span12">
                        <div data-bind="attr:{class: embargoed() ? 'searchResultSection locked' : 'searchResultSection'}">

                            <div class="span9 text-left">
                                <div>
                                    <h4>
                                        <!-- ko if: embargoed() -->
                                        <a href="#" class="helphover"
                                           data-bind="popover: {title:'Only project members can access the record.', content:'Embargoed until : ' + moment(embargoUntil()).format('DD/MM/YYYY')}">
                                            <span class="fa fa-lock"></span>
                                        </a>
                                        <!--/ko -->
                                        Survey name:
                                        <a data-bind="attr:{'href': transients.viewUrl}">
                                            <span data-bind="text: name"></span>
                                        </a>
                                    </h4>
                                </div>

                                <div class="row-fluid">
                                    <div class="span12">
                                        <div class="span7">
                                            <div>
                                                <h6>Project name: <a
                                                        data-bind="attr:{'href': projectUrl()}"><span
                                                            data-bind="text: projectName"></span></a></h6>
                                            </div>

                                            <div>
                                                <h6>Submitted by: <span
                                                        data-bind="text: ownerName"></span> on <span
                                                        data-bind="text: lastUpdated.formattedDate"></span>
                                                </h6>
                                            </div>
                                        </div>

                                        <div class="span5">
                                            <!-- ko if : records().length > 0 -->
                                            <div>
                                                <h6>
                                                    Species :
                                                    <!-- ko foreach : records -->
                                                    <a target="_blank"
                                                       data-bind="visible: guid, attr:{href: $root.transients.bieUrl + '/species/' + guid()}">
                                                        <span data-bind="text: $index()+1"></span>. <span
                                                            data-bind="text: name"></span>
                                                    </a>
                                                    <span data-bind="visible: !guid()">
                                                        <span data-bind="text: $index()+1"></span>. <span
                                                            data-bind="text: name"></span>
                                                    </span>
                                                    <span data-bind="if: $parent.records().length != $index()+1">
                                                        <b>|</b>
                                                    </span>
                                                    <!-- /ko -->
                                                </h6>
                                            </div>
                                            <!-- /ko -->

                                        </div>
                                    </div>

                                </div>
                            </div>

                            <div class="span3 text-right">

                                <!-- looks awkward to show view eye icon by itself. Users can view the survey by clicking the survey title.-->
                                <div class="padding-top-0" data-bind="if: showCrud()">
                                    <span class="margin-left-1">
                                        <a data-bind="attr:{'href': transients.viewUrl}"><i
                                                class="fa fa-eye" title="View survey"></i></a>
                                    </span>
                                    <span class="margin-left-1" data-bind="visible: showAdd()">
                                        <a data-bind="attr:{'href': transients.addUrl}"><i
                                                class="fa fa-plus" title="Add survey"></i></a>
                                    </span>
                                    <span class="margin-left-1">
                                        <a data-bind="attr:{'href': transients.editUrl}"><i
                                                class="fa fa-edit" title="Edit survey"></i></a>
                                    </span>
                                    <span class="margin-left-1">
                                        <a href="#" data-bind="click: $parent.remove"><i
                                                class="fa fa-remove" title="Delete survey"></i></a>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <hr/>
                <!-- /ko -->
                <div class="margin-top-2"></div>
                <g:render template="/shared/pagination"/>
                <!-- ko if : activities().length > 0 -->
                <div class="row-fluid">
                    <div class="span12 pull-right">
                        <div class="span12 text-right">
                            <div><small class="text-right"><span class="fa fa-lock"></span> indicates that only project members can access the record.
                            </small></div>
                        </div>

                    </div>
                </div>
                <!-- /ko -->

                <!-- /ko -->
            </div>
        </div>
    </div>
    <small class="pull-right"><em>Created on <fc:formatDateString date="${site.dateCreated}"
                                                                  inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"
                                                                  format="dd-MM-yyyy"/>
    and last updated on <fc:formatDateString date="${site.lastUpdated}" inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"
                                             format="dd-MM-yyyy"/></em></small>
    <g:if env="development">
        <div class="expandable-debug">
            <hr/>

            <h3>Debug</h3>

            <div>
                <h4>KO model</h4>
                <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
                <h4>Activities</h4>
                <pre>${site.activities?.encodeAsHTML()}</pre>
                <h4>Site</h4>
                <pre>${site}</pre>
                <h4>Projects</h4>
                <pre>${projects?.encodeAsHTML()}</pre>
                <h4>Features</h4>
                <pre>${mapFeatures}</pre>
            </div>
        </div>
    </g:if>
</div>
<asset:script type="text/javascript">
        $(function(){
            var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');

            var mapOptions = {
                drawControl: false,
                singleMarker: false,
                useMyLocation: false,
                allowSearchByAddress: false,
                draggableMarkers: false,
                showReset: false,
                maxZoom: 20,
                wmsLayerUrl: fcConfig.spatialWms + "/wms/reflect?",
                wmsFeatureUrl: fcConfig.featureService + "?featureId="
            };
            var smallMap = new ALA.Map("smallMap", mapOptions);


            if(mapFeatures.features === undefined || mapFeatures.features.length == 0){
                $('#siteNotDefined').show();
            } else {
                var geoJson = Biocollect.MapUtilities.featureToValidGeoJson(mapFeatures.features[0]);
                smallMap.setGeoJSON(geoJson);
            }


            var activitiesAndRecordsViewModel = new ActivitiesAndRecordsViewModel('data-result-placeholder', null, null, true, true)
            activitiesAndRecordsViewModel.searchTerm('siteId:${site.siteId}');
            activitiesAndRecordsViewModel.search();
            ko.applyBindings(activitiesAndRecordsViewModel, document.getElementById('siteActivities'));
            var params = {
                params: {
                    id: '${site.siteId}'
                }
            }
            initPoiGallery(params,'sitePhotopoints');

            // Star button click event
            $("#starBtn").click(function(e) {
                var isStarred = ($("#starBtn i").attr("class") == "icon-star");
                toggleStarred(isStarred);
            });


        });
        function Message (){
            var self = this;
            self.message = ko.observable();
            self.clear = function(){
                self.message('')
            }

            self.message.subscribe(function(){
                setTimeout(self.clear, 3000);
            })
        }
        var msg = new Message();
        ko.applyBindings(msg, document.getElementById('message'))
        function deleteSite(){
            var url = fcConfig.siteDeleteUrl + '/' + "${site.siteId}"
            $.ajax({
                url: url,
                success: function(){
                    msg.message('Successfully deleted site. Redirecting in 3 seconds.');
                    setTimeout(function(){ window.location = fcConfig.siteListUrl}, 3000);
                },
                error: function(xhr){
                    msg.message(xhr.responseText);
                }
            })
        }


       /**
        * Star/Unstar project for user - send AJAX and update UI
        *
        * @param boolean isProjectStarredByUser
        */
        function toggleStarred(isProjectStarredByUser) {
            if (isProjectStarredByUser) {
              // remove star
              var url = fcConfig.removeStarSiteUrl + '/' + "${site.siteId}"
                $.ajax({
                    url: url,
                    success: function(){
                        msg.message('Site removed from favourites.');
                        $("#starBtn i").removeClass("icon-star").addClass("icon-star-empty");
                        $("#starBtn span").text(" Add to favourites");
                    },
                    error: function(xhr){
                        msg.message(xhr.responseText);
                    }
                })
            } else {
                // add star
                var url = fcConfig.addStarSiteUrl + '/' + "${site.siteId}"
                $.ajax({
                    url: url,
                    success: function(){
                        msg.message('Site added to favourites.');
                        $("#starBtn i").removeClass("icon-star-empty").addClass("icon-star");
                        $("#starBtn span").text(" Remove from favourites");
                    },
                    error: function(xhr){
                    msg.message(xhr.responseText);
                    }
                })
            }
        }

</asset:script>
</body>
</html>