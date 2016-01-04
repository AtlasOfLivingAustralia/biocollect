<!-- ko stopBinding: true -->
<div class="well">
    <div class="row-fluid">
        <h2>Site create/edit</h2>

        <p class="media-heading">
            A site should represent the smallest area which contains all of the data collected in a single activity or survey event.
            To create or edit a site, please complete at least all mandatory fields (shown with <span
                class="req-field"></span> ).
        </p>
    </div>

    <div class="row-fluid">
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

    <g:if test="${hideSiteMetadata != true}">

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
                <fc:textArea data-bind="value: site().description" id="description" label="Description ${helpDesc}"
                             class="span12"
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

    </g:if>

    <h2>Create a spatial representation of this site</h2>
    <fc:iconHelp title="Extent of the site">The extent of the site can be represented by
                a polygon, radius or point. KML, WKT and shape files are supported for uploading polygons.
                As are PID's of existing features in the Atlas Spatial Portal.</fc:iconHelp>

    <g:render template="/site/siteMap"/>
</div>
<!-- /ko -->
