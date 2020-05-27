<div id="sitedef" class="row-fluid">
    <div class="span7">
        <m:map id="mapForSystematic" width="100%"/>
    </div>

    <div class="span5">
        <div data-bind="visible: showPointAttributes(), template: { name: 'point'}"></div>

        <div class="well well-small" data-bind="visible: allowPointsOfInterest()">
            <h4><g:message code="site.transect.title"/>
            <fc:iconHelp title="${message(code: 'site.transect.title')}"><g:message code="site.transect.help"/></fc:iconHelp>
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
                        <div class="row-fluid" id="transectParts">
                <div class="span12" data-bind="foreach: transectParts">
                    <div>
                        <div data-bind="template: { name: 'poi'}"></div>
                        <button type="button" class="btn btn-danger" style="margin-bottom:20px;"
                                data-bind="click: $parent.removeTransectPart, visible:!hasPhotoPointDocuments">Remove</button>
                    </div>
                    <hr/>
                </div>
            </div>

            <div class="row-fluid">
                <%-- <button type="button" data-bind="click: newPointOfInterest"
                        class="btn">Add <span
                        data-bind="visible: pointsOfInterest.length > 0">another&nbsp;</span>POI
                </button> --%>
                <button type="button" data-bind="click: newTransectPart"
                        class="btn"><g:message code="site.transect.addSegment"/>
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

            <div class="row-fluid  controls-row">
                <button type="button" data-bind="click: refreshCoordinates"
                        class="btn">Refresh Coordinates
                </button>
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
            <%-- <div class="span6">
                <label for="type"><g:message code="site.poi.type"/></label>
                <g:select data-bind="value: type"
                          name='type'
                          from="['choose type', 'photopoint', 'location of previous surveys', 'other']"
                          keys="['none', 'photopoint', 'survey', 'other']"/>
            </div> --%>
        </div>      
        <div class="row-fluid controls-row">
            <div class="span6">
                <label for="habitat"><g:message code="site.transect.transectPart.habitat"/></label>
                <select data-bind="options: habitatList, selectedOptions: habitat" multiple="true" size="6"></select>
            </div>
            <div class="span6">
                <label for="detail"><g:message code="site.transect.transectPart.detail"/></label>
                <select data-bind="options: detailList, selectedOptions: detail" multiple="true" size="6"></select>
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
        singleDraw: false,
        markerOrShapeNotBoth: false,
        useMyLocation: ${showMyLocation ?: false},
        allowSearchLocationByAddress: ${showAllowSearchLocationByAddress ?: false},
        allowSearchRegionByAddress: ${showAllowSearchRegionByAddress ?: true},
        drawOptions: {
            polyline: ${showLine ?: true},
            marker:  ${showMarker ?: true}
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
        transectParts: ${site?.transectParts ?: '[]'},
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

    var siteViewModel = new SystematicSiteViewModel("mapForSystematic", savedSiteData, SERVER_CONF)
    var map = siteViewModel.map;
<!-- temporary fix to be zoomed in on Sweden - should be done in map-plugin!-->
    <%-- <g:if  test="${project?.projectSite?.extent?.geometry}">
        var source = "${project.projectSite.extent.source}"
        var projectArea = <fc:modelAsJavascript model="${project.projectSite.extent.geometry}"/>;
        var geometry = Biocollect.MapUtilities.featureToValidGeoJson(projectArea);
        if(source != 'none'){
            map.setGeoJSON(geometry);
        }
    </g:if> --%>


    ko.applyBindings(siteViewModel, document.getElementById("sitemap"));

    return siteViewModel;
}
</asset:script>
