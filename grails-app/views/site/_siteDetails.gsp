<!-- ko stopBinding: true -->
<div id="sitemap">
    <div class="row">
        <div class="col-12">
            <h2>Site create/edit</h2>

            <p class="lead">
                <g:message code="site.details.help"/>
            </p>
        </div>
    </div>

    <div class="row">
        <div class="col-12 col-md-6">
            <div class="form-group">
                <label for="name"><g:message code="site.details.siteName"/>
                    <fc:iconHelp title="Site name"><g:message code="site.details.siteName.help"/></fc:iconHelp>
                    <span class="req-field"></span>
                </label>
                <input class="form-control" id="name" data-bind="value: site().name" data-validation-engine="validate[required]"
                       type="text" value="${site?.name?.encodeAsHTML()}"
                       placeholder="${message(code: 'site.details.siteName.placeholder')}"/>
            </div>
        </div>
        <g:if test="${hideSiteMetadata != true}">
        <div class="col-12 col-md-6">
            <div class="form-group">
                <label for="siteArea"><g:message code="site.details.area"/>
                    <fc:iconHelp
                            title="${message(code: 'site.details.area')}"><g:message code="site.details.area.help"/></fc:iconHelp></label>
                <label class="form-control" readonly data-bind="html: displayAreaInReadableFormat" id="siteArea"></label>
            </div>
        </div>
        </g:if>
    </div>

    <g:if test="${project && controllerName.equals('site')}">
    <div class="row">
        <div class="col-12">
            <div class="form-group">
                <label for="projectName"><g:message code="site.details.projectName"/></label>
                <label class="form-control" id="projectName" readonly>
                    <g:link controller="project" action="index"
                            id="${project?.projectId}">${project?.name?.encodeAsHTML()}</g:link>
                </label>
            </div>
        </div>
    </div>
    </g:if>

    <g:if test="${hideSiteMetadata != true}">

    <div class="row">
        <div class="col-12 col-md-3">
            <div class="form-group">
                <label for="externalId"><g:message code="site.details.externalId"/>
                <fc:iconHelp title="${message(code: 'site.details.externalId')}"><g:message code="site.details.externalId.help"/></fc:iconHelp>
                </label>
                <input class="form-control" id="externalId" data-bind="value: site().externalId" type="text"/>
            </div>
        </div>

        <div class="col-12 col-md-3">
            <div class="form-group">
                <label for="siteType"><g:message code="site.details.type"/> <fc:iconHelp
                        title="${message(code: 'site.details.type')}"><g:message code="site.details.type.help"/></fc:iconHelp></label>
                <g:select class="form-control"
                          id="siteType"
                          data-bind="value: site().type"
                          name="type"
                          from="['Survey Area', 'Monitoring Point', 'Works Area']"
                          keys="['surveyArea', 'monitoringPoint', 'worksArea']"/>
            </div>
        </div>

        <div class="col-12 col-md-6">
            <div class="form-group">
                <label for="catchment"><g:message code="site.details.catchment"/><fc:iconHelp
                        title="${message(code: 'site.details.catchment')}"><g:message code="site.details.catchment.help"/></fc:iconHelp></label>
                <input class="form-control" id="catchment" data-bind="value: site().catchment" type="text"/>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12 col-md-6">
            <g:set var="helpDesc" value="${fc.iconHelp(title: message(code: 'site.details.description'), {
                message(code: 'site.details.description.help')
            })}"/>
            <fc:textArea outerClass="form-group" data-bind="value: site().description" id="description" label="${message(code: 'site.details.description')} ${helpDesc}"
                         rows="3" cols="50"/>
        </div>

        <div class="col-12 col-md-6">
            <g:set var="helpNotes" value="${fc.iconHelp(title: message(code: 'site.details.notes'), {
                message(code: 'site.details.notes.help')
            })}"/>
            <fc:textArea outerClass="form-group" data-bind="value: site().notes" id="notes" label="${message(code: 'site.details.notes')} ${helpNotes}" rows="3"
                         cols="50"/>
        </div>
    </div>

    </g:if>
    <div class="row">
        <div class="col-12">
            <h2><g:message code="site.details.extent.heading"/></h2>
            <fc:iconHelp title="Extent of the site"><g:message code="site.details.extent.help"/></fc:iconHelp>
            <g:render template="/site/siteDefinition" model="${[showLine: true, showMyLocation: true, showAllowSearchLocationByAddress: false, showAllowSearchRegionByAddress: true, showMarker: true]}"/>
        </div>
    </div>
</div>
<!-- /ko -->
