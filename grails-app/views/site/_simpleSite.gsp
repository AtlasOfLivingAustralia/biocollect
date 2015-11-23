<%@ page import="grails.converters.JSON" %>
<!-- ko stopBinding: true -->
<div id="sitemap">
    <script type="text/javascript" src="${grailsApplication.config.google.drawmaps.url}"></script>

    <div class="row-fluid">

        <div class="span7">
            <div id="mapForExtent" class="smallMap span6" style="width:100%;height:${mapHeight?:'600px'};"></div>
        </div>

        <div class="span5">

            <div class="well well-small">

                <div>
                    <h4>Define extent using:
                    <g:select class="input-medium" data-bind="value: extentSource" data-validation-engine="validate[funcCall[validateSiteExtent]]"
                              name='extentSource'
                              from="['choose type','point','known shape','draw a shape']"
                              keys="['none','point','pid','drawn']"/>
                    </h4>
                </div>

                <div id="map-controls" data-bind="visible: extent().source() == 'drawn' ">
                    <ul id="control-buttons">
                        <li class="active" id="pointer" title="Drag to move. Double click or use the zoom control to zoom.">
                            <a href="javascript:void(0);" class="btn active draw-tool-btn">
                                %{--<img src="${resource(dir:'bootstrap/img',file:'pointer.png')}" alt="pointer"/>--}%
                                <img src="${resource(dir:'images',file:'glyphicons_347_hand_up.png')}" alt="center and radius"/>
                                <span class="drawButtonLabel">Move & zoom</span>
                            </a>
                        </li>
                        <li id="circle" title="Click at centre and drag the desired radius. Values can be adjusted in the boxes.">
                            <a href="javascript:void(0);" class="btn draw-tool-btn">
                                %{--<img src="${resource(dir:'images/map',file:'circle.png')}" alt="center and radius"/>--}%
                                <img src="${resource(dir:'images',file:'glyphicons_095_vector_path_circle.png')}" alt="center and radius"/>
                                <span class="drawButtonLabel">Draw circle</span>
                            </a>
                        </li>
                        <li id="rectangle" title="Click and drag a rectangle.">
                            <a href="javascript:void(0);" class="btn draw-tool-btn">
                                %{--<img src="${resource(dir:'images/map',file:'rectangle.png')}" alt="rectangle"/>--}%
                                <img src="${resource(dir:'images',file:'glyphicons_094_vector_path_square.png')}" alt="rectangle"/>
                                <span class="drawButtonLabel">Draw rect</span>
                            </a>
                        </li>
                        <li id="polygon" title="Click any number of times to draw a polygon. Double click to close the polygon.">
                            <a href="javascript:void(0);" class="btn draw-tool-btn">
                                %{--<img src="${resource(dir:'images/map',file:'polygon.png')}" alt="polygon"/>--}%
                                <img src="${resource(dir:'images',file:'glyphicons_096_vector_path_polygon.png')}" alt="polygon"/>
                                <span class="drawButtonLabel">Draw polygon</span>
                            </a>
                        </li>
                        <li id="clear" title="Clear the region from the map.">
                            <a href="javascript:void(0);" class="btn draw-tool-btn">
                                %{--<img src="${resource(dir:'images/map',file:'clear.png')}" alt="clear"/>--}%
                                <img src="${resource(dir:'images',file:'glyphicons_016_bin.png')}" alt="clear"/>
                                <span class="drawButtonLabel">Clear</span>
                            </a>
                        </li>
                        <li id="zoomToExtent" title="Zoom to extent of drawn shape.">
                            <a href="javascript:zoomToShapeBounds();" class="btn draw-tool-btn">
                                <img src="${resource(dir:'images',file:'glyphicons_186_move.png')}" alt="zoom to extent of drawn shape"/>
                                <span class="drawButtonLabel">Zoom</span>
                            </a>
                        </li>
                    </ul>
                </div>

                <div style="padding-top:10px;" data-bind="template: { name: extent().source, data: extent }"></div>
            </div>

            <div data-bind="visible: extentSource() != 'none'">
                <a id="reset" title="Zoom and centre on Australia." href="javascript:void(0);" class="btn draw-tool-btn">
                    <img src="${resource(dir:'images',file:'reset.png')}" alt="reset map"/>
                    <span class="drawButtonLabel">Reset</span>
                </a>
            </div>
        </div>
    </div>

    <!-- templates -->
    <script type="text/html" id="none">
    %{--<span>Choose a type</span>--}%
    </script>

    <script type="text/html" id="point">
    <div class="drawLocationDiv row-fluid">
        <div class="span12">
            <g:if test="${siteOptions?.additionalPointText}">
                <div class="margin-bottom-1">
                    ${siteOptions.additionalPointText}
                </div>
            </g:if>
            <div class="row-fluid controls-row">
                <fc:textField data-bind="value:geometry().decimalLatitude" data-validation-engine="validate[required,custom[number],min[-90],max[0]]" outerClass="span6" label="Latitude" labelClass="left-aligned"/>
                <fc:textField data-bind="value:geometry().decimalLongitude" data-validation-engine="validate[required,custom[number],min[-180],max[180]]" data-prompt-position="topRight:-150" outerClass="span6" label="Longitude" labelClass="left-aligned"/>
            </div>
            <g:if test="${siteOptions ? siteOptions.showUncertainty : true}">
                <div class="row-fluid controls-row margin-top-1">
                    <fc:textField data-bind="value:geometry().uncertainty, enable: hasCoordinate()" outerClass="span4" label="Uncertainty" labelClass="left-aligned"/>
                    <fc:textField data-bind="value:geometry().precision, enable: hasCoordinate()" outerClass="span4" label="Precision" labelClass="left-aligned"/>
                    %{-- CG - only supporting WGS84 at the moment --}%
                    <fc:textField data-bind="value:geometry().datum, enable: hasCoordinate()" outerClass="span4" label="Datum" placeholder="WGS84" readonly="readonly" labelClass="left-aligned"/>
                </div>
            </g:if>
        </div>
        <g:if test="${siteOptions ? siteOptions.showSiteSummary : true}">
            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">State/territory</span> <span data-bind="text:geometry().state"></span>
            </div>
            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">Local Gov. Area</span> <span data-bind="text:geometry().lga"></span>
            </div>
            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">NRM</span> <span data-bind="text:geometry().nrm"></span>
            </div>
            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">Locality</span> <span data-bind="text:geometry().locality"></span>
            </div>
            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">NVIS major vegetation group:</span> <span data-bind="text:geometry().mvg"></span>
            </div>

            <div class="row-fluid controls-row gazProperties">
                <span class="label label-success">NVIS major vegetation subgroup:</span> <span data-bind="text:geometry().mvs"></span>
            </div>
        </g:if>
    </div>
    </script>

    <script type="text/html" id="poi">
    <div class="drawLocationDiv row-fluid">
        <div class="span12">
            <div class="row-fluid alert" style="box-sizing:border-box;" data-bind="visible:hasPhotoPointDocuments">
                This point of interest has documents attached and cannot be removed.
            </div>
            <div class="row-fluid controls-row">
                <fc:textField data-bind="value:name" outerClass="span6" label="Name" data-validation-engine="validate[required]"/>
            </div>
            <div class="row-fluid controls-row">
                <fc:textArea rows="2" data-bind="value:description" outerClass="span12" class="span12" label="Description"/>
            </div>
            <div class="row-fluid controls-row">
                <label for="type">Point type</label>
                <g:select data-bind="value: type"
                          name='type'
                          from="['choose type','photopoint', 'location of previous surveys', 'other']"
                          keys="['none','photopoint', 'survey', 'other']"/>
            </div>
            <div class="row-fluid controls-row">
                <fc:textField data-bind="value:geometry().decimalLatitude" outerClass="span4" label="Latitude" data-validation-engine="validate[required,custom[number],min[-90],max[0]]" data-prompt-position="topRight:-150"/>
                <fc:textField data-bind="value:geometry().decimalLongitude" outerClass="span4" label="Longitude" data-validation-engine="validate[required,custom[number],min[-180],max[180]]"/>
                <fc:textField data-bind="value:geometry().bearing" outerClass="span4" label="Bearing (degrees)" data-validation-engine="validate[custom[number],min[0],max[360]]" data-prompt-position="topRight:-150"/>
            </div>
            <div class="row-fluid controls-row" style="display:none;">
                <fc:textField data-bind="value:geometry().uncertainty, enable: hasCoordinate()" outerClass="span4" label="Uncertainty"/>
                <fc:textField data-bind="value:geometry().precision, enable: hasCoordinate()" outerClass="span4" label="Precision"/>
                <fc:textField data-bind="value:geometry().datum, enable: hasCoordinate()" outerClass="span4" label="Datum" placeholder="e.g. WGS84"/>
            </div>
        </div>
    </div>
    </script>

    <script type="text/html" id="pid">
    <div id="pidLocationDiv" class="drawLocationDiv row-fluid">
        <div class="span12">
            <select data-bind="
            options: layers(),
            optionsCaption:'Choose a layer...',
            optionsValue: 'id',
            optionsText:'name',
            value: chosenLayer"></select>
            <select data-bind="options: layerObjects, disable: layerObjects().length == 0,
            optionsCaption:'Choose shape ...',
            optionsValue: 'pid',
            optionsText:'name', value: layerObject"></select>

            <g:if test="${siteOptions ? siteOptions.showSiteSummary : true}">
                <div class="row-fluid controls-row" style="display:none;">
                    <span class="label label-success">PID</span> <span data-bind="text:geometry().pid"></span>
                </div>
                <div class="row-fluid controls-row">
                    <span class="label label-success">Name</span> <span data-bind="text:geometry().name"></span>
                </div>
                <div class="row-fluid controls-row" style="display:none;">
                    <span class="label label-success">LayerID</span> <span data-bind="text:geometry().fid"></span>
                </div>
                <div class="row-fluid controls-row">
                    <span class="label label-success">Layer</span> <span data-bind="text:geometry().layerName"></span>
                </div>
                <div class="row-fluid controls-row">
                    <span class="label label-success">Area (km&sup2;)</span> <span data-bind="text:geometry().area"></span>
                </div>
            </g:if>
        </div>
    </div>
    </script>

    <script type="text/html" id="upload">
    <h3> Not implemented - waiting on web services...</h3>
    </script>

    <script type="text/html" id="drawn">
    <g:if test="${siteOptions ? siteOptions.showSiteSummary : true}">
        <div id="drawnLocationDiv" class="drawLocationDiv row-fluid">
            <div class="span12">

                <div class="row-fluid controls-row" style="display:none;">
                    <span class="label label-success">Type</span> <span data-bind="text:geometry().type"></span>
                </div>
                <div class="row-fluid controls-row" data-bind="visible: geometry!=null && geometry().areaKmSq!=null && geometry().areaKmSq != '' ">
                    <span class="label label-success">Area (km&sup2;)</span> <span data-bind="text:geometry().areaKmSq"></span>
                </div>

                <div class="row-fluid controls-row gazProperties" data-bind="visible: geometry!=null && geometry().state!=null && geometry().state!=''">
                    <span class="label label-success">State/territory</span> <span data-bind="text:geometry().state"></span>
                </div>

                <div class="row-fluid controls-row gazProperties" data-bind="visible: geometry!=null && geometry().lga!=null && geometry().lga!=''">
                    <span class="label label-success">Local Gov. Area</span> <span data-bind="text:geometry().lga"></span>
                </div>

                <div class="row-fluid controls-row gazProperties">
                    <span class="label label-success">NRM</span> <span data-bind="text:geometry().nrm"></span>
                </div>

                <div class="row-fluid controls-row gazProperties">
                    <span class="label label-success">Locality</span> <span data-bind="text:geometry().locality"></span>
                </div>

                <div class="row-fluid controls-row gazProperties">
                    <span class="label label-success">NVIS major vegetation group:</span> <span data-bind="text:geometry().mvg"></span>
                </div>

                <div class="row-fluid controls-row gazProperties">
                    <span class="label label-success">NVIS major vegetation subgroup:</span> <span data-bind="text:geometry().mvs"></span>
                </div>

                <div style="display:none;" class="row-fluid controls-row">
                    <span class="label label-success">Center</span> <span data-bind="text:geometry().centre"></span>
                </div>
                <div class="row-fluid controls-row circleProperties propertyGroup">
                    <span class="label label-success">Radius (m)</span> <span data-bind="text:geometry().radius"></span>
                </div>

                <div style="display:none;" class="row-fluid controls-row  propertyGroup">
                    <span class="label">GeoJSON</span> <span data-bind="text:ko.toJSON(geometry())"></span>
                </div>

                <div class="row-fluid controls-row rectangleProperties propertyGroup">
                    <span class="label label-success">Latitude (SW)</span> <span data-bind="text:geometry().minLat"></span>
                    <span class="label label-success">Longitude (SW)</span> <span data-bind="text:geometry().minLon"></span>
                </div>
                <div class="row-fluid controls-row rectangleProperties propertyGroup">
                    <span class="label label-success">Latitude (NE)</span> <span data-bind="text:geometry().maxLat"></span>
                    <span class="label label-success">Longitude (NE)</span> <span data-bind="text:geometry().maxLon"></span>
                </div>
            </div>
        </div>
    </g:if>
    </script>
</div>
<!-- /ko -->

<r:script>
var siteOptions = ${siteOptions as grails.converters.JSON ?: '{}'};

function initSiteViewModel() {
    var siteViewModel;

    // server side generated paths & properties
    var SERVER_CONF = {
        siteData: ${site?:[] as grails.converters.JSON},
        spatialService: '${createLink(controller:'proxy',action:'feature')}',
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: '${grailsApplication.config.spatial.geoserverUrl}'
    };

    var savedSiteData = {
        siteId: "${site?.siteId}",
        name : "${site?.name?.encodeAsJavaScript()}",
        externalId : "${site?.externalId}",
        context : "${site?.context}",
        type : "${site?.type}",
        extent: ${site?.extent?:'null'},
        poi: ${site?.poi?:'[]'},
        area : "${site?.area}",
        description : "${site?.description?.encodeAsJavaScript()}",
        notes : "${site?.notes?.encodeAsJavaScript()}",
        documents : JSON.parse('${(siteDocuments?:documents).encodeAsJavaScript() ?: '{}'}'),
    <g:if test="${project}">
        projects : ['${project.projectId}'],
    </g:if>
    <g:else>
        projects : ${site?.projects?:'[]'}
    </g:else>
    };


    (function(){

        <g:if test="${loadMapOnDocumentReady}">
            //retrieve serialised model
            siteViewModel = new SiteViewModelWithMapIntegration(savedSiteData, ${siteOptions as grails.converters.JSON ?: '{}'});
            window.validateSiteExtent = siteViewModel.attachExtentValidation();

            ko.applyBindings(siteViewModel, document.getElementById("sitemap"));

            siteViewModel.initialiseMap(SERVER_CONF);
        </g:if>

    }());

    return siteViewModel;
}
</r:script>
