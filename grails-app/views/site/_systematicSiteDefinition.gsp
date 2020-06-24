<div id="sitedef" class="row-fluid">
    <div class="span7">
        <m:map id="mapForSystematic" width="100%"/>
    </div>

    <div class="span5">
        <div class="well well-small" data-bind="visible: allowPointsOfInterest()">
            <div class="row-fluid">
                <button type="button" data-bind="click: addTransectPartFromMap"
                        class="btn"><g:message code="site.transect.transectPart.saveFromMap"/> 
                </button>
            </div>
            <div class="row-fluid" id="transectParts">
                <div class="row-fluid">
                    <h4><g:message code="site.transect.transectPart.name.help"/></h4>
                </div>
                <div data-bind="visible: transectParts().length > 0">
                    <div class="row-fluid">
                        <h4><g:message code="site.transect.step.title" /> 3</h4>
                        <label for="name"><g:message code="site.transect.step3"/></label>
                    </div>
                </div>
                <div class="span12" data-bind="foreach: transectParts">
                    <div>
                        <div data-bind="template: { name: 'poi'}"></div>
                        <button type="button" class="btn btn-danger" style="margin-bottom:20px;"
                                data-bind="click: $parent.removeTransectPart, visible:true"><g:message code="g.remove"/></button>
                    </div>
                    <hr/>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Template containing Transect part form fields -->
<script type="text/html" id="poi">
<div class="drawLocationDiv row-fluid">
    <div class="span12">
    <!-- This error message should only come up if no features are drawn on map -->
        <div class="row-fluid alert" style="box-sizing:border-box;" data-bind="visible:false">
            <g:message code="site.transect.transectPart.tip"/>
        </div>
        <div class="row-fluid controls-row">
        <h4 data-bind="text: nameToDisplay"></h4>
        </div>
        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:name" outerClass="span6" label="${message(code:'site.poi.name')}"
                          data-validation-engine="validate[required]"/>
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
        <div class="row-fluid controls-row">
            <div class="span6">
                <label for="habitatAddedByUser"><g:message code="g.other"/></label>
                <input type="text" data-bind="value:habitatAddedByUser" multiple="true" size="6">
                <button data-bind="click: addHabitat"><g:message code="g.add"/></button>
                <label for="habitatAddedByUser"><g:message code="site.transect.transectPart.attributes" />: </label>
                <textarea data-bind="value:habitat"></textarea>
            </div>
            <div class="span6">
                <label for="detailAddedByUser"><g:message code="g.other"/></label>
                <input type="text" data-bind="value:detailAddedByUser, valueUpdate: 'afterkeydown'" multiple="true" size="6">
                <button data-bind="click: addDetail"><g:message code="g.add"/></button>
                <label for="habitatAddedByUser"><g:message code="site.transect.transectPart.attributes" />: </label>
                <div data-bind="foreach: detail">
                <li data-bind="text: $data"></li><a href="#" data-bind="click: $parent.removeDetail"><i class="fa fa-remove"></i></a>
                </div>
            </div>
        </div>
        <div>
            <fc:textField disabled data-bind="value:geometry().coordinates" outerClass="span10" label="${message(code:'g.coordinates')}"/>
        </div>
    </div>
</div>
</script>


<asset:script type="text/javascript">
var transectFeatureGroup = new L.FeatureGroup();
function initSiteViewModel(allowPointsOfInterest, edit) {
    // server side generated paths & properties
    var SERVER_CONF = {
        siteData: ${site ?: [] as grails.converters.JSON},
        spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
        regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: '${grailsApplication.config.spatial.geoserverUrl}',
        maxAutoZoom: 14,
        maxZoom: 17,
        allowPointsOfInterest: allowPointsOfInterest,
        readonly: edit? true : false,
        singleDraw: false,
        markerOrShapeNotBoth: false,
        singleMarker: false,
        useMyLocation: ${showMyLocation ?: false},
        allowSearchLocationByAddress: ${showAllowSearchLocationByAddress ?: false},
        allowSearchRegionByAddress: ${showAllowSearchRegionByAddress ?: true},
        drawOptions: {
            polyline: ${showLine ?: true},
            marker:  ${showMarker ?: true},
            circle: false
        },
        editOptions: {
            featureGroup: transectFeatureGroup
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
