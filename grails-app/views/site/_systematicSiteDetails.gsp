<!-- ko stopBinding: true -->
<div class="well" id="sitemap">
    <div class="row-fluid">
        <h2><g:message code="site.details.title"/></h2>

        <p class="media-heading">
            <g:message code="site.transect.help"/>
        </p>
    </div>

    <div class="row-fluid">
        <div class="span6">
            <h4><g:message code="site.transect.step.title" /> 1</h4>
            <label for="name"><g:message code="site.transect.step1"/></label>
            <label for="name"><g:message code="site.details.siteName"/> <fc:iconHelp
                    title="Site name"><g:message code="site.details.siteName.help"/></fc:iconHelp>
                <span class="req-field"></span>
            </label>
            <input data-bind="value: site().name" data-validation-engine="validate[required]"
                   class="span12" id="name" type="text" value="${site?.name?.encodeAsHTML()}"
                   placeholder="${message(code: 'site.details.siteName.placeholder')}"/>
        </div>
    </div>

    <%-- <g:if test="${project && controllerName.equals('site')}">
        <div class="row-fluid" style="padding-bottom:15px;">
            <span><g:message code="site.details.projectName"/></span>
            <g:link controller="project" action="index"
                    id="${project?.projectId}">${project?.name?.encodeAsHTML()}</g:link>
        </div>
    </g:if> --%>
    <div class="row-fluid">
        <div class="span6">
            <g:set var="helpDesc" value="${fc.iconHelp(title: message(code: 'site.details.description'), {
                message(code: 'site.details.description.help')
            })}"/>
            <fc:textArea data-bind="value: site().description" id="description" label="${message(code: 'site.details.description')} ${helpDesc}"
                            class="span12"
                            rows="3" cols="50"/>
                        
        </div>
    </div>

    <h4><g:message code="site.transect.step.title" /> 2</h4>
    <label for="name"><g:message code="site.transect.step2"/></label>
    <g:render template="/site/systematicSiteDefinition" model="${[showLine: true, showMyLocation: true, showAllowSearchLocationByAddress: false, showAllowSearchRegionByAddress: true, showMarker: true]}"/>

</div>
<!-- /ko -->
