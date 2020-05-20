<div id="sitedef" class="row-fluid">
    <div class="span7">
        <m:map id="mapForSystematic" width="100%"/>
    </div>

    <div class="span5">
        <div data-bind="visible: showPointAttributes(), template: { name: 'additionalAttributes'}"></div>

        <div class="well well-small" data-bind="visible: allowPointsOfInterest()">
            <h4><g:message code="site.transect.title"/>
            <fc:iconHelp title="${message(code: 'site.transect.title')}"><g:message code="site.transect.help"/></fc:iconHelp>
            </h4>

            <div class="row-fluid">
                <button type="button" data-bind="click: newTransectPart"
                        class="btn"><g:message code="site.transect.addSegment"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Template containing additional attributes for a Point shape type -->
<%-- <script type="text/html" id="point">
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
</script> --%>

<!-- Template containing Point of Interest form fields -->
<script type="text/html" id="additionalAttributes">
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
            <div class="span6">
                <label for="habitat"><g:message code="site.transect.transectPart.habitat"/></label>
                <g:select data-bind="value: habitat"
                          name='habitat'
                          from="['choose habitat type', 'Lövskog', 'Blandskog', 'Barrskog', 'Hygge', 'other']"
                          keys="['none', '1', '2', '3', '4', 'other']"/>
            </div>
            <div class="span6">
                <label for="detail"><g:message code="site.transect.transectPart.detail"/></label>
                <g:select data-bind="value: detail"
                          name='detail'
                          from="['choose detaljkoder', 'Kraftledningsgata', 'Grusväg', 'other']"
                          keys="['none', '1', '2', 'other']"/>
            </div>
        </div>

        <%-- <div class="row-fluid controls-row">
            <fc:textArea rows="2" data-bind="value:description" outerClass="span12" class="span12"
                         label="${message(code:'site.poi.description')}"/>
        </div> --%>
<%-- 
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
        </div> --%>
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
