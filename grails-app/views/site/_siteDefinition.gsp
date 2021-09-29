<div id="sitedef" class="row">
    <div class="col-12 col-md-7 mt-3">
        <m:map id="mapForExtent" width="100%"/>
    </div>

    <div class="col-12 col-md-5">
        <div class="border border-secondary mt-3 p-3" data-bind="visible: showPointAttributes(), template: { name: 'point'}"></div>

        <div class="border border-secondary mt-3 p-3" data-bind="visible: site().extent().geometry().type">
            <div data-bind="if: transients.loadingGazette()"><span class="fa fa-spin fa-spinner"></span></div>

            <dl class="row">
                <!-- ko if:site().extent().geometry().type() == 'pid' -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.name"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="text: site().extent().geometry().name"></span>
                </dd>

                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.layer"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="text: site().extent().geometry().layerName"></span>
                </dd>

                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.area"/></span>
                </dt>
                <dd class="col-sm-9">
                        <span data-bind="html: displayAreaInReadableFormat"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if:site().extent().geometry().type() != 'pid' -->
                <!-- ko if: site().extent().geometry().areaKmSq -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.area"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="html: displayAreaInReadableFormat"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().state -->
                <dt class="col-sm-3" >
                    <span class="label label-success"><g:message code="site.metadata.state"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="expandable: site().extent().geometry().state"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().lga -->
                <dt class="col-sm-3" >
                    <span class="label label-success"><g:message code="site.metadata.govArea"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span
                        data-bind="expandable: site().extent().geometry().lga"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().nrm -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.nrm"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="expandable: site().extent().geometry().nrm"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().locality -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.locality"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="text: site().extent().geometry().locality"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().mvg -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.nvisGroup"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span
                        data-bind="text: site().extent().geometry().mvg"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().mvs -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.nvisSubgroup"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="text: site().extent().geometry().mvs"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().centre -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.centre"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span data-bind="text: site().extent().geometry().centre"></span>
                </dd>
                <!-- /ko -->

                <!-- ko if: site().extent().geometry().radius -->
                <dt class="col-sm-3">
                    <span class="label label-success"><g:message code="site.metadata.radius"/></span>
                </dt>
                <dd class="col-sm-9">
                    <span
                        data-bind="text: site().extent().geometry().radius"></span>
                </dd>
                <!-- /ko -->
                <!-- /ko -->
            </dl>
        </div>

        <div class="border border-secondary mt-3 p-3" data-bind="visible: allowPointsOfInterest()">
            <h4><g:message code="site.poi.title"/>
            <fc:iconHelp title="${message(code: 'site.poi.title')}"><g:message code="site.poi.help"/></fc:iconHelp>
            </h4>

            <div class="row" id="pointsOfInterest">
                <div class="col-12">
                    <div data-bind="foreach: pointsOfInterest">
                        <div data-bind="template: { name: 'poi'}"></div>
                        <button class="btn btn-danger mb-3" type="button"
                                data-bind="click: $parent.removePointOfInterest, visible:!hasPhotoPointDocuments">Remove</button>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <button class="btn btn-dark" type="button" data-bind="click: newPointOfInterest">Add <span
                            data-bind="visible: pointsOfInterest.length > 0">another&nbsp;</span>POI
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Template containing additional attributes for a Point shape type -->
<script type="text/html" id="point">
<div class="drawLocationDiv row">
    <div class="col-12">
        <div class="row">
            <div class="col-12 col-md-6">
                <fc:textField data-bind="value: site().extent().geometry().decimalLatitude"
                              data-validation-engine="validate[required,custom[number],min[-90],max[90]]"
                              outerClass="form-group" label="${message(code:'site.point.lat')}"/>
            </div>
            <div class="col-12 col-md-6">
                <fc:textField data-bind="value: site().extent().geometry().decimalLongitude"
                              data-validation-engine="validate[required,custom[number],min[-180],max[180]]"
                              data-prompt-position="topRight:-150" outerClass="form-group" label="${message(code:'site.point.lng')}"/>
            </div>
        </div>

        <div class="row">
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value: site().extent().geometry().uncertainty" outerClass="span4"
                              data-validation-engine="validate[min[0],custom[integer]]"
                              label="${message(code:'site.point.uncertainty')}"/>
            </div>
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value: site().extent().geometry().precision" outerClass="span4"
                              data-validation-engine="validate[min[0],custom[number]]"
                              label="${message(code:'site.point.precision')}"/>
            </div>
            %{-- CG - only supporting WGS84 at the moment --}%
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value: site().extent().geometry().datum" outerClass="span4" label="${message(code:'site.point.datum')}"
                              placeholder="WGS84" readonly="readonly"/>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <button class="btn btn-dark mt-3" type="button" data-bind="click: refreshCoordinates">
                    Refresh Coordinates
                </button>
            </div>
        </div>
    </div>
</div>
</script>

<!-- Template containing Point of Interest form fields -->
<script type="text/html" id="poi">
<div class="drawLocationDiv row">
    <div class="col-12">
        <div class="row alert" data-bind="visible:hasPhotoPointDocuments">
            <g:message code="site.poi.tip"/>
        </div>

        <div class="row">
            <div class="col-12 col-md-6">
                <fc:textField data-bind="value:name" outerClass="form-group" label="${message(code:'site.poi.name')}"
                          data-validation-engine="validate[required]"/>
            </div>
            <div class="col-12 col-md-6">
                <label for="type"><g:message code="site.poi.type"/></label>
                <g:select class="form-control" data-bind="value: type"
                          name='type'
                          from="['choose type', 'photopoint', 'location of previous surveys', 'other']"
                          keys="['none', 'photopoint', 'survey', 'other']"/>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <fc:textArea rows="2" data-bind="value:description" outerClass="form-group"
                             label="${message(code:'site.poi.description')}"/>
            </div>
        </div>

        <div class="row">
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().decimalLatitude" outerClass="form-group" label="${message(code:'site.poi.lat')}"
                              data-validation-engine="validate[required,custom[number],min[-90],max[90]]"
                              data-prompt-position="topRight:-150"/>
            </div>
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().decimalLongitude" outerClass="form-group" label="${message(code:'site.poi.lng')}"
                              data-validation-engine="validate[required,custom[number],min[-180],max[180]]"/>
            </div>
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().bearing" outerClass="form-group" label="${message(code:'site.poi.bearing')}"
                              data-validation-engine="validate[custom[number],min[0],max[360]]"
                              data-prompt-position="topRight:-150"/>
            </div>
        </div>

        <div class="row hide">
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().uncertainty, enable: hasCoordinate()" outerClass="form-group"
                              label="${message(code:'site.poi.uncertainty')}"/>
            </div>
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().precision, enable: hasCoordinate()" outerClass="form-group"
                              label="${message(code:'site.poi.precision')}"/>
            </div>
            <div class="col-12 col-md-4">
                <fc:textField data-bind="value:geometry().datum, enable: hasCoordinate()" outerClass="form-group"
                              label="${message(code:'site.poi.datum')}"
                              placeholder="e.g. WGS84"/>
            </div>
        </div>
    </div>
</div>
</script>


<asset:script type="text/javascript">
function initSiteViewModel(allowPointsOfInterest, edit) {
    // server side generated paths & properties
    var SERVER_CONF = {
        siteData: ${site ?: [] as grails.converters.JSON},
        spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: '${grailsApplication.config.spatial.geoserverUrl}',
        allowPointsOfInterest: allowPointsOfInterest,
        readonly: edit? true : false,
        useMyLocation: ${showMyLocation ?: false},
        allowSearchLocationByAddress: ${showAllowSearchLocationByAddress ?: false},
        allowSearchRegionByAddress: ${showAllowSearchRegionByAddress ?: true},
        drawOptions: {
            polyline: ${showLine ?: false},
            marker:  ${showMarker ?: false}
        }
    };

    var savedSiteData = {
        siteId: "${site?.siteId}",
        name : "${site?.name?.encodeAsJavaScript()}",
        externalId : "${site?.externalId}",
        catchment: "${site?.catchment}",
        context : "${site?.context}",
        type : "${site?.type}",
        extent: ${site?.extent ?: 'null'},
        poi: ${site?.poi ?: '[]'},
        area : "${site?.area}",
        description : "${site?.description?.encodeAsJavaScript()}",
        notes : "${site?.notes?.encodeAsJavaScript()}",
        documents : JSON.parse('${(siteDocuments ?: documents).encodeAsJavaScript() ?: '{}'}'),
    <g:if test="${project}">
        projects : ['${project.projectId}'],
    </g:if>
    <g:else>
        projects : ${site?.projects ?: '[]'}
    </g:else>
    };

    var siteViewModel = new SiteViewModel("mapForExtent", savedSiteData, SERVER_CONF)
    var map = siteViewModel.map;

    <g:if  test="${project?.projectSite?.extent?.geometry}">
        var source = "${project.projectSite.extent.source}"
        var projectArea = <fc:modelAsJavascript model="${project.projectSite.extent.geometry}"/>;
        var geometry = Biocollect.MapUtilities.featureToValidGeoJson(projectArea);
        if(source != 'none'){
            map.setGeoJSON(geometry);
        }
    </g:if>


    ko.applyBindings(siteViewModel, document.getElementById("sitemap"));

    return siteViewModel;
}
</asset:script>
