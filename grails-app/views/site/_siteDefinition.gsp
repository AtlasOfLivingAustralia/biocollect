<div id="sitedef" class="row-fluid">
    <div class="span7">
        <m:map id="mapForExtent" width="100%"/>
    </div>

    <div class="span5">
        <div data-bind="visible: showPointAttributes(), template: { name: 'point'}"></div>

        <div class="well well-small" data-bind="visible: site().extent().geometry().type">
            <div data-bind="if: transients.loadingGazette()"><span class="fa fa-spin fa-spinner"></span></div>

            <!-- ko if:site().extent().geometry().type() == 'pid' -->
            <div class="row-fluid controls-row">
                <span class="label label-success"><g:message code="site.metadata.name"/> </span> <span
                    data-bind="text: site().extent().geometry().name"></span>
            </div>

            <div class="row-fluid controls-row">
                <span class="label label-success"><g:message code="site.metadata.layer"/></span> <span
                    data-bind="text: site().extent().geometry().layerName"></span>
            </div>

            <div class="row-fluid controls-row">
                <span class="label label-success"><g:message code="site.metadata.area"/></span> <span
                    data-bind="text: site().extent().geometry().areaKmSq"></span>
            </div>
            <!-- /ko -->

            <!-- ko if:site().extent().geometry().type() != 'pid' -->
            <div class="row-fluid controls-row" data-bind="visible: site().extent().geometry().areaKmSq">
                <span class="label label-success"><g:message code="site.metadata.area"/></span> <span
                    data-bind="text: site().extent().geometry().areaKmSq"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().state">
                <span class="label label-success"><g:message code="site.metadata.state"/></span> <span
                    data-bind="expandable: site().extent().geometry().state"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().lga">
                <span class="label label-success"><g:message code="site.metadata.govArea"/></span> <span
                    data-bind="expandable: site().extent().geometry().lga"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().nrm">
                <span class="label label-success"><g:message code="site.metadata.nrm"/></span> <span
                    data-bind="expandable: site().extent().geometry().nrm"></span>
            </div>

            <div class="row-fluid controls-row gazProperties"
                 data-bind="visible: site().extent().geometry().locality">
                <span class="label label-success"><g:message code="site.metadata.locality"/></span> <span
                    data-bind="text: site().extent().geometry().locality"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().mvg">
                <span class="label label-success"><g:message code="site.metadata.nvisGroup"/></span> <span
                    data-bind="text: site().extent().geometry().mvg"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().mvs">
                <span class="label label-success"><g:message code="site.metadata.nvisSubgroup"/></span> <span
                    data-bind="text: site().extent().geometry().mvs"></span>
            </div>

            <div class="row-fluid controls-row" data-bind="visible: site().extent().geometry().centre">
                <span class="label label-success"><g:message code="site.metadata.centre"/></span> <span
                    data-bind="text: site().extent().geometry().centre"></span>
            </div>

            <div class="row-fluid controls-row circleProperties propertyGroup"
                 data-bind="visible: site().extent().geometry().radius">
                <span class="label label-success"><g:message code="site.metadata.radius"/></span> <span
                    data-bind="text: site().extent().geometry().radius"></span>
            </div>
            <!-- /ko -->
        </div>

        <div class="well well-small" data-bind="visible: allowPointsOfInterest()">
            <h4><g:message code="site.poi.title"/>
            <fc:iconHelp title="${message(code: 'site.poi.title')}"><g:message code="site.poi.help"/></fc:iconHelp>
            </h4>

            <div class="row-fluid" id="pointsOfInterest">
                <div class="span12" data-bind="foreach: pointsOfInterest">
                    <div>
                        <div data-bind="template: { name: 'poi'}"></div>
                        <button type="button" class="btn btn-danger" style="margin-bottom:20px;"
                                data-bind="click: $parent.removePointOfInterest, visible:!hasPhotoPointDocuments">Remove</button>
                    </div>
                    <hr/>
                </div>
            </div>

            <div class="row-fluid">
                <button type="button" data-bind="click: newPointOfInterest"
                        class="btn">Add <span
                        data-bind="visible: pointsOfInterest.length > 0">another&nbsp;</span>POI
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Template containing additional attributes for a Point shape type -->
<script type="text/html" id="point">
<div class="well well-small">
    <div class="drawLocationDiv row-fluid">
        <div class="span12">
            <div class="row-fluid controls-row">
                <fc:textField data-bind="value: site().extent().geometry().decimalLatitude"
                              data-validation-engine="validate[required,custom[number],min[-90],max[90]]"
                              outerClass="span6" label="${message(code:'site.point.lat')}"/>
                <fc:textField data-bind="value: site().extent().geometry().decimalLongitude"
                              data-validation-engine="validate[required,custom[number],min[-180],max[180]]"
                              data-prompt-position="topRight:-150" outerClass="span6" label="${message(code:'site.point.lng')}"/>
            </div>

            <div class="row-fluid controls-row">
                <fc:textField data-bind="value: site().extent().geometry().uncertainty" outerClass="span4"
                              data-validation-engine="validate[min[0],custom[integer]]"
                              label="${message(code:'site.point.uncertainty')}"/>
                <fc:textField data-bind="value: site().extent().geometry().precision" outerClass="span4"
                              data-validation-engine="validate[min[0],custom[number]]"
                              label="${message(code:'site.point.precision')}"/>
                %{-- CG - only supporting WGS84 at the moment --}%
                <fc:textField data-bind="value: site().extent().geometry().datum" outerClass="span4" label="${message(code:'site.point.datum')}"
                              placeholder="WGS84" readonly="readonly"/>
            </div>
        </div>
    </div>
</div>
</script>

<!-- Template containing Point of Interest form fields -->
<script type="text/html" id="poi">
<div class="drawLocationDiv row-fluid">
    <div class="span12">
        <div class="row-fluid alert" style="box-sizing:border-box;" data-bind="visible:hasPhotoPointDocuments">
            <g:message code="site.poi.tip"/>
        </div>

        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:name" outerClass="span6" label="${message(code:'site.poi.name')}"
                          data-validation-engine="validate[required]"/>
            <div class="span6">
                <label for="type"><g:message code="site.poi.type"/></label>
                <g:select data-bind="value: type"
                          name='type'
                          from="['choose type', 'photopoint', 'location of previous surveys', 'other']"
                          keys="['none', 'photopoint', 'survey', 'other']"/>
            </div>
        </div>

        <div class="row-fluid controls-row">
            <fc:textArea rows="2" data-bind="value:description" outerClass="span12" class="span12"
                         label="${message(code:'site.poi.description')}"/>
        </div>

        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:geometry().decimalLatitude" outerClass="span4" label="${message(code:'site.poi.lat')}"
                          data-validation-engine="validate[required,custom[number],min[-90],max[90]]"
                          data-prompt-position="topRight:-150"/>
            <fc:textField data-bind="value:geometry().decimalLongitude" outerClass="span4" label="${message(code:'site.poi.lng')}"
                          data-validation-engine="validate[required,custom[number],min[-180],max[180]]"/>
            <fc:textField data-bind="value:geometry().bearing" outerClass="span4" label="${message(code:'site.poi.bearing')}"
                          data-validation-engine="validate[custom[number],min[0],max[360]]"
                          data-prompt-position="topRight:-150"/>
        </div>

        <div class="row-fluid controls-row" style="display:none;">
            <fc:textField data-bind="value:geometry().uncertainty, enable: hasCoordinate()" outerClass="span4"
                          label="${message(code:'site.poi.uncertainty')}"/>
            <fc:textField data-bind="value:geometry().precision, enable: hasCoordinate()" outerClass="span4"
                          label="${message(code:'site.poi.precision')}"/>
            <fc:textField data-bind="value:geometry().datum, enable: hasCoordinate()" outerClass="span4"
                          label="${message(code:'site.poi.datum')}"
                          placeholder="e.g. WGS84"/>
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
        drawOptions: {
            polyline: false
        }
    };

    var savedSiteData = {
        siteId: "${site?.siteId}",
        name : "${site?.name?.encodeAsJavaScript()}",
        externalId : "${site?.externalId}",
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
