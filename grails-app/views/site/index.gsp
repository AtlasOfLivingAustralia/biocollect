<%@ page import="java.text.SimpleDateFormat; grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${site?.name?.encodeAsHTML()} | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'site', action: 'list')},Sites"/>
    <meta name="breadcrumb" content="${site.name?.encodeAsHTML()}"/>

    <asset:script type="text/javascript">
        var fcConfig = {
            <g:applyCodec encodeAs="none">
            intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDelete')}",
            siteListUrl: "${createLink(controller: 'site', action: 'list')}",
            addStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxAddToFavourites')}",
            removeStarSiteUrl: "${createLink(controller: 'site', action: 'ajaxRemoveFromFavourites')}",
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
            worksActivityEditUrl: "${createLink(controller: 'activity', action: 'enterData')}",
            worksActivityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities')}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            getRecordsForMapping: "${createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping')}",
            recordListUrl: "${createLink(controller: 'record', action: 'ajaxList')}",
            recordDeleteUrl: "${createLink(controller: 'record', action: 'delete')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
            mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
            </g:applyCodec>
        },
        here = "${createLink(controller: 'site', action: 'index', id: site.siteId)}";
    </asset:script>
    <asset:stylesheet src="sites-manifest.css"/>
    <asset:stylesheet src="leaflet-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="leaflet-manifest.js"/>
    <asset:javascript src="sites-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>
<div class="container-fluid">
    <div class="alert alert-info alert-dismissible" id="message" data-bind="slideVisible: message">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        <span data-bind="text: message"></span>
    </div>

    <div class="alert alert-info alert-dismissible">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        <strong><g:message code="site.details.headsUp"/></strong> <g:message code="site.details.editWarning"/>
    </div>
    <ul class="list-inline text-right">
        <li class="list-inline-item btn-space">
            <g:set var="disabled">${(!user) ? "disabled='disabled' title='login required'" : ''}</g:set>
        %{--Favourite functionality only available to authenticated users --}%
            <g:if test="${!hubConfig?.systematic}">
                <g:link action="edit" id="${site.siteId}" class="btn btn-sm btn-primary-dark"><i
                        class="fas fa-pencil-alt"></i> <g:message code="site.details.editSite"/></g:link>
            %{-- TODO - delete button could be for volunteers too but maybe have an alert before delete happens --}%
                <g:if test="${fc.userIsAlaAdmin()}">
                    <div class="btn btn-sm btn-danger" onclick="deleteSite()"><i
                            class="far fa-trash-alt"></i> <g:message code="site.details.deleteSite"/>
                    </div>
                </g:if>
            </g:if>
            <g:if test="${hubConfig?.systematic}">
                <g:link action="editSystematic" id="${site.siteId}" class="btn btn-sm btn-dark"><i
                        class="fas fa-pencil-alt"></i> <g:message code="site.details.editSystematic"/></g:link>
            </g:if>
            <g:if test="${site?.extent?.geometry?.pid}">
                <a href="${grailsApplication.config.spatial.layersUrl}/shape/shp/${site.extent.geometry.pid}"
                   class="btn btn-sm btn-dark">
                    <i class="fas fa-download"></i>
                    <g:message code="site.details.downloadShp"/>
                </a>
                <a href="${grailsApplication.config.spatial.baseURL}/?pid=${site.extent.geometry.pid}"
                   class="btn btn-sm btn-dark"><i class="fa fa-map"></i> <g:message
                        code="site.details.viewInSpatialPortal"/></a>
            </g:if>
        </li>
    </ul>

    <div class="row">
        <div class="col-12 col-md-6"><!-- left block of header -->
            <g:if test="${flash.errorMessage || flash.message}">
                <div class="alert alert-danger alert-dismissible">
                    <button type="button" class="close" data-dismiss="alert"
                            onclick="$('.alert').fadeOut();" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    ${flash.errorMessage ?: flash.message}
                </div>
            </g:if>
            <h1>${site?.name?.encodeAsHTML()}</h1>
            <g:if test="${site.description?.encodeAsHTML()}">
                <dl class="row">
                    <dt class="col-3"><h3><g:message code="site.details.siteDescription"/></h3></dt>
                    <dd class="col-9">${site.description?.encodeAsHTML()}</dd>
                </dl>
            </g:if>

            <h3><g:message code="site.details.siteMetadata"/></h3>
            <g:if test="${!hubConfig?.systematic}">
                <dl class="row">
                    <dt class="col-3"><g:message code="site.details.externalId"/></dt>
                    <dd class="col-9">${site.externalId ?: 'Not specified'}</dd>
                    <dt class="col-3"><g:message code="site.details.type"/></dt>
                    <dd class="col-9">${site.type ?: 'Not specified'}</dd>
                    <dt class="col-3"><g:message code="site.details.catchment"/></dt>
                    <dd class="col-9">${site.catchment ?: 'Not specified'}</dd>
                    <dt class="col-3"><g:message code="site.details.area"/></dt>
                    <dd class="col-9">
                        <g:if test="${site?.extent?.geometry?.area}">
                            ${site.extent.geometry.area} <g:message code="site.details.area.sqKm"/>
                        </g:if>
                        <g:else>
                            <g:message code="site.details.notSpecified"/>
                        </g:else>
                    </dd>
                    <g:if test="${site.extent?.geometry}">
                        <fc:siteFacet site="${site}" label="State/territory" facet="state" showPreview="${true}"
                                      trimSize="${80}"/>
                        <fc:siteFacet label="Local government area" site="${site}" facet="lga" showPreview="${true}"
                                      trimSize="${80}"/>
                        <fc:siteFacet label="NRM" site="${site}" facet="nrm" showPreview="${true}" trimSize="${80}"/>
                        <dt class="col-3"><g:message code="site.metadata.locality"/></dt>
                        <dd class="col-9">${site.extent.geometry.locality ?: 'Not specified'}</dd>
                        <dt class="col-3" data-toggle="tooltip" title="NVIS major vegetation group"><g:message
                                code="site.metadata.nvisGroup"/></dt>
                        <dd class="col-9">${site.extent.geometry.mvg ?: 'Not specified'}</dd>
                        <dt class="col-3" data-toggle="tooltip" title="NVIS major vegetation subgroup"><g:message
                                code="site.metadata.nvisSubgroup"/></dt>
                        <dd class="col-9">${site.extent.geometry.mvs ?: 'Not specified'}</dd>
                    </g:if>
                    <g:if test="${site.notes}">
                        <dt><g:message code="site.details.notes"/></dt>
                        <dd>${site.notes?.encodeAsHTML()}</dd>
                    </g:if>
                </dl>
            </g:if>
            <g:if test="${hubConfig?.systematic}">
                <dl class="row">
                    <dt class="col-3"><g:message code="site.transect.title"/></dt>
                    <g:each in="${site.transectParts}">
                        <dd class="col-9">${it.name} - ${it?.habitat} - ${it?.detail}</dd>
                    </g:each>

                    <g:if test="${site.notes}">
                        <dt class="col-3"><g:message code="site.details.notes"/></dt>
                        <dd class="col-9">${site.notes?.encodeAsHTML()}</dd>
                    </g:if>
                </dl>
            </g:if>
            <script>
                $('dt[data-toggle="tooltip"]').tooltip()
            </script>
        </div>

        <div class="col-12 col-md-6">
            <div id="siteNotDefined" class="hide pull-right">
                <span class="label label-important"><g:message code="site.details.noGeoreference"/></span>
            </div>
            <m:map id="smallMap" width="100%" height="500px"/>
        </div>
    </div>

    <h3><g:message code="site.associated.title"/>:</h3>

    <div id="detailsLinkedToSite">
        <ul class="nav nav-tabs" id="myTab" role="tablist">
            <g:if test="${site.projects}">
                <li class="nav-item"><a class="nav-link" href="#siteProjects" data-toggle="tab"><g:message
                        code="g.projects"/></a></li>
            </g:if>
            <li class="nav-item"><a class="nav-link active" href="#siteActivities" data-toggle="tab"><g:message
                    code="site.details.associated.surveysAndActivities"/></a></li>
            <li class="nav-item"><a class="nav-link" href="#sitePhotopoints" data-toggle="tab"><g:message
                    code="site.details.photoPoints"/></a></li>
        </ul>

        <div class="tab-content mt-3">
            <!-- ko stopBinding: true -->
            <div class="tab-pane" id="sitePhotopoints">
                <g:render template="poiGallery"
                          model="${[siteId: site.siteId, siteElementId: 'sitePhotopoints']}"></g:render>
            </div>
            <!-- /ko -->
            <div class="tab-pane" id="siteProjects">
                <g:if test="${site.projects}">
                    <div>
                        <p><g:message code="site.details.associated.projects"/> -</p>
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

            <div class="tab-pane active" id="siteActivities">
                <!-- ko if: activities().length == 0 -->
                <div class="row">
                    <div class="col-12">
                        <h4 class="text-left margin-bottom-five">
                            <!-- ko if: $root.searchTerm() != "" || $root.selectedFilters().length > 0 -->
                            <g:message code="site.details.noResults"/>
                            <!-- /ko -->
                        </h4>
                    </div>
                </div>
                <!-- /ko -->

                <!-- ko if: activities().length > 0 -->

                <div class="alert alert-info hide" id="downloadStartedMsg">
                    <i class="fas fa-spinner"></i>
                    <g:message code="site.details.downloading"/>...
                </div>

                <div class="row">
                    <div class="col-12 col-md-9">
                        <h3 class="text-left margin-bottom-2"><g:message code="g.found"/> <span
                                data-bind="text: total()"></span> <g:message code="g.records"/>
                        </h3>
                    </div>
                </div>
                <g:render template="/shared/pagination" model="${[bs: 4]}"/>
                <div class="records-list row d-flex flex-wrap mt-4 mt-md-4 mb-3">
                    <!-- ko foreach : activities -->
                    <div class="col-12 col-md-3 d-flex">
                        <div class="record flex-grow-1">
                            <div class="row"
                                 data-bind="attr:{class: embargoed() ? 'searchResultSection locked' : 'searchResultSection'}">
                                <div class="col-12 pl-sm-1">
                                    <h4>
                                        <!-- ko if: embargoed() -->
                                        <a href="#" class="helphover"
                                           data-bind="popover: {title:'Only project members can access the record.', content:'Embargoed until : ' + moment(embargoUntil()).format('DD/MM/YYYY')}">
                                            <span class="fa fa-lock"></span>
                                        </a>
                                        <!--/ko -->
                                        <g:message code="site.details.surveyName"/>:
                                        <a data-bind="attr:{'href': transients.viewUrl}">
                                            <span data-bind="text: name"></span>
                                        </a>
                                    </h4>
                                    <ul class="detail-list">
                                        <li>
                                            <span class="label"><g:message code="site.details.projectName"/>:</span>
                                            <a data-bind="attr:{'href': projectUrl()}" rel="noopener">
                                                <span data-bind="text: projectName"></span>
                                            </a>
                                        </li>
                                        <li>
                                            <span class="label"><g:message code="site.details.submittedBy"/>:</span>
                                            <span data-bind="text: ownerName"></span> on
                                            <span data-bind="text: lastUpdated.formattedDate"></span>
                                        </li>
                                        <li data-bind="if: records().length > 0">
                                            <span class="label"><g:message code="g.species"/>:</span>
                                            <!-- ko foreach : records -->
                                            <a target="_blank"
                                               data-bind="visible: guid, attr:{href: $root.transients.bieUrl + '/species/' + guid()}, text: name">
                                            </a>
                                            <span data-bind="visible: !guid(), text: name"></span>
                                            <span data-bind="if: $parent.records().length != $index()+1">
                                                <b>|</b>
                                            </span>
                                            <!-- /ko -->
                                        </li>
                                    </ul>

                                    <!-- ko if: showCrud() -->
                                    <div class="btn-space">
                                        <a class="btn btn-primary-dark btn-sm"
                                           data-bind="attr:{'href': transients.viewUrl}" title="<g:message code="site.survey.view.btn" />">
                                            <i class="far fa-eye"></i>
                                        </a>
                                        <a class="btn btn-dark btn-sm" data-bind="visible: showAdd(), attr:{'href': transients.addUrl}" title="<g:message code="site.survey.add.btn" />">
                                            <i class="fa fa-plus"></i>
                                        </a>
                                        <a class="btn btn-dark btn-sm" data-bind="attr:{'href': transients.editUrl}" title="<g:message code="site.survey.edit.btn" />">
                                            <i class="fas fa-pencil-alt"></i>
                                        </a>
                                        <a class="btn btn-sm btn-danger" href="#" data-bind="click: $parent.remove" title="<g:message code="site.survey.delete.btn" />">
                                            <i class="far fa-trash-alt"></i>
                                        </a>
                                    </div>
                                    <!-- /ko -->
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- /ko -->
                </div>

                <div class="margin-top-2"></div>
                <g:render template="/shared/pagination" model="${[bs: 4]}"/>
                <!-- ko if : activities().length > 0 -->
                <div class="row">
                    <div class="col-12 text-right">
                        <small>
                            <span class="fa fa-lock"></span> <g:message code="site.details.accessRestrictedTip"/>
                        </small>
                    </div>
                </div>
                <!-- /ko -->

                <!-- /ko -->
            </div>
        </div>
    </div>
    <small class="text-right">
        <em>
            <g:message code="site.details.createdOn"/> <fc:formatDateString date="${site.dateCreated}"
                                                                            inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"
                                                                            format="dd-MM-yyyy"/>
            <g:message code="site.details.lastUpdated"/> <fc:formatDateString date="${site.lastUpdated}"
                                                                              inputFormat="yyyy-MM-dd'T'HH:mm:ss'Z'"
                                                                              format="dd-MM-yyyy"/>
        </em>
    </small>
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
            var overlayLayersMapControlConfig = Biocollect.MapUtilities.getOverlayConfig();
            var baseLayersAndOverlays = Biocollect.MapUtilities.getBaseLayerAndOverlayFromMapConfiguration(fcConfig.mapLayersConfig);

            var mapOptions = {
                autoZIndex: false,
                preserveZIndex: true,
                addLayersControlHeading: true,
                allowSearchLocationByAddress: false,
                allowSearchRegionByAddress: false,
                drawControl: false,
                singleMarker: false,
                useMyLocation: false,
                allowSearchByAddress: false,
                draggableMarkers: false,
                showReset: false,
                maxZoom: 20,
                baseLayer: baseLayersAndOverlays.baseLayer,
                otherLayers: baseLayersAndOverlays.otherLayers,
                overlays: baseLayersAndOverlays.overlays,
                overlayLayersSelectedByDefault: baseLayersAndOverlays.overlayLayersSelectedByDefault,
                wmsFeatureUrl: overlayLayersMapControlConfig.wmsFeatureUrl,
                wmsLayerUrl: overlayLayersMapControlConfig.wmsLayerUrl
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
</asset:script>
</body>
</html>
