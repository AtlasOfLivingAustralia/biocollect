<!-- ko stopBinding: true -->
<div id="sitemap" class="well">
            <script type="text/javascript" src="${grailsApplication.config.google.drawmaps.url}"></script>
            <div class="row-fluid">
                <h2>Create or edit Site</h2>
                <p class="media-heading">
                    A site should represent the smallest area which contains all of the data collected in a single activity or survey event.
                    To create or edit a site, please complete at least all mandatory fields (shown with <span class="req-field"></span> ).
                </p>
            </div>
            <div class="row-fluid">
                <g:hiddenField name="id" value="${site?.siteId}"/>
                <div>
                    <label for="name">Site name <fc:iconHelp title="Site name">The name of the site at which a survey or activity is undertaken. This should be short and uniquely identifiable.</fc:iconHelp>
                        <span class="req-field"></span>
                    </label>
                    <h1>
                        <input data-bind="value: name" data-validation-engine="validate[required]"
                               class="span8" id="name" type="text" value="${site?.name?.encodeAsHTML()}"
                               placeholder="Enter a name for the new site"/>
                    </h1>
                </div>
            </div>
            <g:if test="${project && controllerName.equals('site')}">
            <div class="row-fluid" style="padding-bottom:15px;">
                <span>Project name:</span>
                <g:link controller="project" action="index" id="${project?.projectId}">${project?.name?.encodeAsHTML()}</g:link>
            </div>
            </g:if>
            <div class="row-fluid">
                <div class="span3">
                    <label for="externalId">External Id
                        <fc:iconHelp title="External id">Identifier code for the site - used in external documents.</fc:iconHelp>
                    </label>
                    <input data-bind="value:externalId" id="externalId" type="text" class="span12"/>
                </div>
                <div class="span3">
                    <label for="siteType">Type <fc:iconHelp title="Type">A categorisation for the type of site being mapped.</fc:iconHelp> </label>
                    %{--<input data-bind="value: type" id="siteType" type="text" class="span12"/>--}%
                    <g:select id="siteType"
                              data-bind="value: type"
                              class="span12"
                              name='type'
                              from="['Survey Area', 'Monitoring Point', 'Works Area']"
                              keys="['surveyArea', 'monitoringPoint', 'worksArea']"/>
                </div>
                <div class="span3">
                    <label for="siteArea">Area (decimal hectares)
                        <fc:iconHelp title="Area of site">The area in decimal hectares (4dp) enclosed within the boundary of the shape file.</fc:iconHelp></label>
                    <input data-bind="value: area" id="siteArea" type="text" class="span12"/>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span6">
                    <g:set var="helpDesc" value="${fc.iconHelp(title: 'Description', {'A long description of the site. This may include distance and bearing relative to a fixed known location, size, shape, distinctive characteristics, etc.'})}"></g:set>
                    <fc:textArea data-bind="value: description" id="description" label="Description ${helpDesc}" class="span12" rows="3" cols="50"/>
                </div>
                <div class="span6">
                    <g:set var="helpNotes" value="${fc.iconHelp(title: 'Notes', {'Additional notes about the site such as setting/surroundings, aspect, special/notable features, boundary/corner markers, etc.'})}"></g:set>
                    <fc:textArea data-bind="value: notes" id="notes" label="Notes ${helpNotes}" class="span12" rows="3" cols="50"/>
                </div>
            </div>

            <h2>Create a spatial representation of this site</h2>
            <fc:iconHelp title="Extent of the site">The extent of the site can be represented by
                a polygon, radius or point. KML, WKT and shape files are supported for uploading polygons.
                As are PID's of existing features in the Atlas Spatial Portal.</fc:iconHelp>

            <div class="row-fluid">

                <div class="span6">
                    <div id="mapForExtent" class="smallMap span6" style="width:100%;height:600px;"></div>
                </div>

                <div class="span6">

                    <div class="well well-small">

                        <div>
                            <h4>Define extent using: <fc:iconHelp title="Define extent using">Select the method you want to use to define the area of the site</fc:iconHelp> <span class="req-field"></span>
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
                                <li id="reset" title="Zoom and centre on Australia.">
                                    <a href="javascript:void(0);" class="btn draw-tool-btn">
                                    <img src="${resource(dir:'images',file:'reset.png')}" alt="reset map"/>
                                    <span class="drawButtonLabel">Reset</span>
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

                    <div class="well well-small">
                        <h4>Points of interest
                            <fc:iconHelp title="Points of interest">You can specify any number of points
                            of interest with a site. Points of interest may include photo points
                            or the locations of previous survey work.</fc:iconHelp>
                        </h4>
                        <div class="row-fluid" id="pointsOfInterest" >
                            <div class="span12" data-bind="foreach: poi">
                                <div>
                                    <div data-bind="template: { name: 'poi'}" ></div>
                                    <button type="button" class="btn btn-danger" style="margin-bottom:20px;" data-bind="click: $parent.removePOI, visible:!hasPhotoPointDocuments">Remove</button>
                                </div>
                                <hr/>
                            </div>
                        </div>
                        <div class="row-fluid">
                            <button type="button" data-bind="click: newPOI, visible: poi.length == 0" class="btn">Add a POI</button>
                            <button type="button" data-bind="click: newPOI, visible: poi.length > 0" class="btn">Add another POI</button>
                        </div>
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
        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:geometry().decimalLatitude" data-validation-engine="validate[required,custom[number],min[-90],max[0]]" outerClass="span6" label="Latitude"/>
            <fc:textField data-bind="value:geometry().decimalLongitude" data-validation-engine="validate[required,custom[number],min[-180],max[180]]" data-prompt-position="topRight:-150" outerClass="span6" label="Longitude"/>
        </div>
        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:geometry().uncertainty, enable: hasCoordinate()" outerClass="span4" label="Uncertainty"/>
            <fc:textField data-bind="value:geometry().precision, enable: hasCoordinate()" outerClass="span4" label="Precision"/>
            %{-- CG - only supporting WGS84 at the moment --}%
            <fc:textField data-bind="value:geometry().datum, enable: hasCoordinate()" outerClass="span4" label="Datum" placeholder="WGS84" readonly="readonly"/>
        </div>
    </div>
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
        </div>
    </div>
    </script>

    <script type="text/html" id="upload">
    <h3> Not implemented - waiting on web services...</h3>
    </script>

    <script type="text/html" id="drawn">
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
        %{--<div class="smallMap span8" style="width:500px;height:300px;"></div>--}%
    </div>
    </script>
</div>
<!-- /ko -->

<r:script>
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
        documents : JSON.parse('${(siteDocuments?:documents).encodeAsJavaScript()}'),
    <g:if test="${project}">
        projects : ['${project.projectId}'],
    </g:if>
    <g:else>
        projects : ${site?.projects?:'[]'}
    </g:else>
    };


    (function(){

        //retrieve serialised model
        siteViewModel = new SiteViewModelWithMapIntegration(savedSiteData);
        window.validateSiteExtent = siteViewModel.attachExtentValidation()

        ko.applyBindings(siteViewModel, document.getElementById("sitemap"));

        init_map({
            spatialService: SERVER_CONF.spatialService,
            spatialWms: SERVER_CONF.spatialWms,
            mapContainer: 'mapForExtent'
        });

        siteViewModel.mapInitialised(window);

    }());

    return siteViewModel;
}
</r:script>
