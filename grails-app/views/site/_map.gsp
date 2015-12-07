<!-- ko stopBinding: true -->
<div id="sitemap" class="well">
    <div class="row-fluid">
        <h2>Site create/edit</h2>

        <p class="media-heading">
            A site should represent the smallest area which contains all of the data collected in a single activity or survey event.
            To create or edit a site, please complete at least all mandatory fields (shown with <span
                class="req-field"></span> ).
        </p>
    </div>

    <div class="row-fluid">
<g:hiddenField name="id" value="${site?.siteId}"/>
<div>
    <label for="name">Site name <fc:iconHelp
            title="Site name">The name of the site at which a survey or activity is undertaken. This should be short and uniquely identifiable.</fc:iconHelp>
        <span class="req-field"></span>
    </label>
    <input data-bind="value: site().name" data-validation-engine="validate[required]"
           class="span8" id="name" type="text" value="${site?.name?.encodeAsHTML()}"
           placeholder="Enter a name for the new site"/>
</div>
</div>

<g:if test="${project && controllerName.equals('site')}">
    <div class="row-fluid" style="padding-bottom:15px;">
        <span>Project name:</span>
        <g:link controller="project" action="index"
                id="${project?.projectId}">${project?.name?.encodeAsHTML()}</g:link>
    </div>
</g:if>

<div class="row-fluid">
    <div class="span3">
        <label for="externalId">External Id
        <fc:iconHelp title="External id">Identifier code for the site - used in external documents.</fc:iconHelp>
        </label>
        <input data-bind="value: site().externalId" id="externalId" type="text" class="span12"/>
    </div>

    <div class="span3">
        <label for="siteType">Type <fc:iconHelp
                title="Type">A categorisation for the type of site being mapped.</fc:iconHelp></label>
        <g:select id="siteType"
                  data-bind="value: site().type"
                  class="span12"
                  name='type'
                  from="['Survey Area', 'Monitoring Point', 'Works Area']"
                  keys="['surveyArea', 'monitoringPoint', 'worksArea']"/>
    </div>

    <div class="span3">
        <label for="siteArea">Area (decimal hectares)
            <fc:iconHelp
                    title="Area of site">The area in decimal hectares (4dp) enclosed within the boundary of the shape file.</fc:iconHelp></label>
        <input data-bind="value: site().area" id="siteArea" type="text" class="span12"/>
    </div>
</div>

<div class="row-fluid">
    <div class="span6">
        <g:set var="helpDesc" value="${fc.iconHelp(title: 'Description', {
            'A long description of the site. This may include distance and bearing relative to a fixed known location, size, shape, distinctive characteristics, etc.'
        })}"/>
        <fc:textArea data-bind="value: site().description" id="description" label="Description ${helpDesc}" class="span12"
                     rows="3" cols="50"/>
    </div>

    <div class="span6">
        <g:set var="helpNotes" value="${fc.iconHelp(title: 'Notes', {
            'Additional notes about the site such as setting/surroundings, aspect, special/notable features, boundary/corner markers, etc.'
        })}"/>
        <fc:textArea data-bind="value: site().notes" id="notes" label="Notes ${helpNotes}" class="span12" rows="3"
                     cols="50"/>
    </div>
</div>

<h2>Create a spatial representation of this site</h2>
<fc:iconHelp title="Extent of the site">The extent of the site can be represented by
                a polygon, radius or point. KML, WKT and shape files are supported for uploading polygons.
                As are PID's of existing features in the Atlas Spatial Portal.</fc:iconHelp>

<div class="row-fluid">

    <div class="span7">
        <m:map id="mapForExtent" width="100%"/>
    </div>

    <div class="span5">
        <div data-bind="visible: showPointAttributes(), template: { name: 'point'}"></div>

        <div class="well well-small" data-bind="visible: site().extent().geometry().type">
            <!-- ko if:site().extent().geometry().type() == 'pid' -->
            <div class="row-fluid controls-row">
                <span class="label label-success">Name</span> <span data-bind="text: site().extent().geometry().name"></span>
            </div>
            <div class="row-fluid controls-row">
                <span class="label label-success">Layer</span> <span data-bind="text: site().extent().geometry().layerName"></span>
            </div>
            <div class="row-fluid controls-row">
                <span class="label label-success">Area (km&sup2;)</span> <span data-bind="text: site().extent().geometry().areaKmSq"></span>
            </div>
            <!-- /ko -->

            <!-- ko if:site().extent().geometry().type() != 'pid' -->
            <div class="row-fluid controls-row" data-bind="visible: site().extent().geometry().areaKmSq">
                <span class="label label-success">Area (km&sup2;)</span> <span data-bind="text: site().extent().geometry().areaKmSq"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().state">
                <span class="label label-success">State/territory</span> <span data-bind="text: site().extent().geometry().state"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().lga">
                <span class="label label-success">Local Gov. Area</span> <span data-bind="text: site().extent().geometry().lga"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().nrm">
                <span class="label label-success">NRM</span> <span data-bind="text: site().extent().geometry().nrm"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().locality">
                <span class="label label-success">Locality</span> <span data-bind="text: site().extent().geometry().locality"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().mvg">
                <span class="label label-success">NVIS major vegetation group:</span> <span data-bind="text: site().extent().geometry().mvg"></span>
            </div>

            <div class="row-fluid controls-row gazProperties" data-bind="visible: site().extent().geometry().mvs">
                <span class="label label-success">NVIS major vegetation subgroup:</span> <span data-bind="text: site().extent().geometry().mvs"></span>
            </div>

            <div class="row-fluid controls-row" data-bind="visible: site().extent().geometry().centre">
                <span class="label label-success">Centre</span> <span data-bind="text: site().extent().geometry().centre"></span>
            </div>
            <div class="row-fluid controls-row circleProperties propertyGroup" data-bind="visible: site().extent().geometry().radius">
                <span class="label label-success">Radius (m)</span> <span data-bind="text: site().extent().geometry().radius"></span>
            </div>
            <!-- /ko -->
        </div>

        <div class="well well-small">
            <h4>Points of interest
            <fc:iconHelp title="Points of interest">You can specify any number of points
                            of interest with a site. Points of interest may include photo points
                            or the locations of previous survey work.</fc:iconHelp>
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
                        class="btn">Add <span data-bind="visible: pointsOfInterest.length > 0">another&nbsp;</span>POI
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
                <fc:textField data-bind="value: site().extent().geometry().decimalLatitude" data-validation-engine="validate[required,custom[number],min[-90],max[0]]" outerClass="span6" label="Latitude"/>
                <fc:textField data-bind="value: site().extent().geometry().decimalLongitude" data-validation-engine="validate[required,custom[number],min[-180],max[180]]" data-prompt-position="topRight:-150" outerClass="span6" label="Longitude"/>
            </div>
            <div class="row-fluid controls-row">
                <fc:textField data-bind="value: site().extent().geometry().uncertainty" outerClass="span4" label="Uncertainty"/>
                <fc:textField data-bind="value: site().extent().geometry().precision" outerClass="span4" label="Precision"/>
                %{-- CG - only supporting WGS84 at the moment --}%
                <fc:textField data-bind="value: site().extent().geometry().datum" outerClass="span4" label="Datum" placeholder="WGS84" readonly="readonly"/>
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
            This point of interest has documents attached and cannot be removed.
        </div>
        <div class="row-fluid controls-row">
            <fc:textField data-bind="value:name" outerClass="span6" label="Name" data-validation-engine="validate[required]"/>
            <div class="span6">
                <label for="type">Point type</label>
                <g:select data-bind="value: type"
                          name='type'
                          from="['choose type','photopoint', 'location of previous surveys', 'other']"
                          keys="['none','photopoint', 'survey', 'other']"/>
            </div>
        </div>
        <div class="row-fluid controls-row">
            <fc:textArea rows="2" data-bind="value:description" outerClass="span12" class="span12" label="Description"/>
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

<!-- /ko -->
<r:script>
function initSiteViewModel() {
    // server side generated paths & properties
    var SERVER_CONF = {
        siteData: ${site ?: [] as grails.converters.JSON},
        spatialService: '${createLink(controller: 'proxy', action: 'feature')}',
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
        projects : ${site?.projects?:'[]'}
    </g:else>
    };

    var siteViewModel = new SiteViewModel("mapForExtent", savedSiteData, SERVER_CONF)

    ko.applyBindings(siteViewModel, document.getElementById("sitemap"));

    return siteViewModel;
}
</r:script>
