<!-- ko stopBinding: true -->
<div class="well" id="sitemap">
    <div class="row-fluid">
        <h2>Site create/edit</h2>

        <p class="media-heading">
            <g:message code="site.details.help"/>
        </p>
    </div>

    <div class="row-fluid">
        <div>
            <label for="name"><g:message code="site.details.siteName"/> <fc:iconHelp
                    title="Site name"><g:message code="site.details.siteName.help"/></fc:iconHelp>
                <span class="req-field"></span>
            </label>
            <input data-bind="value: site().name" data-validation-engine="validate[required]"
                   class="span8" id="name" type="text" value="${site?.name?.encodeAsHTML()}"
                   placeholder="${message(code: 'site.details.siteName.placeholder')}"/>
        </div>
    </div>

    <g:if test="${project && controllerName.equals('site')}">
        <div class="row-fluid" style="padding-bottom:15px;">
            <span><g:message code="site.details.projectName"/></span>
            <g:link controller="project" action="index"
                    id="${project?.projectId}">${project?.name?.encodeAsHTML()}</g:link>
        </div>
    </g:if>

    <g:if test="${hideSiteMetadata != true}">

        <div class="row-fluid">
            <div class="span3">
                <label for="externalId"><g:message code="site.details.externalId"/>
                <fc:iconHelp title="${message(code: 'site.details.externalId')}"><g:message code="site.details.externalId.help"/></fc:iconHelp>
                </label>
                <input data-bind="value: site().externalId" id="externalId" type="text" class="span12"/>
            </div>

            <div class="span3">
                <label for="siteType"><g:message code="site.details.type"/> <fc:iconHelp
                        title="${message(code: 'site.details.type')}"><g:message code="site.details.type.help"/></fc:iconHelp></label>
                <g:select id="siteType"
                          data-bind="value: site().type"
                          class="span12"
                          name='type'
                          from="['Survey Area', 'Monitoring Point', 'Works Area']"
                          keys="['surveyArea', 'monitoringPoint', 'worksArea']"/>
            </div>

            <div class="span3">
                <label for="siteArea"><g:message code="site.details.area"/>
                    <fc:iconHelp
                            title="${message(code: 'site.details.area')}"><g:message code="site.details.area.help"/></fc:iconHelp></label>
                    <label readonly data-bind="html: displayAreaInReadableFormat" id="siteArea" type="text" class="span12"/>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span6">
                <g:set var="helpDesc" value="${fc.iconHelp(title: message(code: 'site.details.description'), {
                    message(code: 'site.details.description.help')
                })}"/>
                <fc:textArea data-bind="value: site().description" id="description" label="${message(code: 'site.details.description')} ${helpDesc}"
                             class="span12"
                             rows="3" cols="50"/>
            </div>

            <div class="span6">
                <g:set var="helpNotes" value="${fc.iconHelp(title: message(code: 'site.details.notes'), {
                    message(code: 'site.details.notes.help')
                })}"/>
                <fc:textArea data-bind="value: site().notes" id="notes" label="${message(code: 'site.details.notes')} ${helpNotes}" class="span12" rows="3"
                             cols="50"/>
            </div>
        </div>

    </g:if>

    <h2><g:message code="site.details.extent.heading"/></h2>
    <fc:iconHelp title="Extent of the site"><g:message code="site.details.extent.help"/></fc:iconHelp>

    <g:render template="/site/siteDefinition"/>
</div>
<!-- /ko -->
