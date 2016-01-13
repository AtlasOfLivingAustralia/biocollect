<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Organisations | Field Capture</title>
    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <r:script disposition="head">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            createOrganisationUrl: "${createLink(controller: 'organisation', action: 'create')}",
            viewOrganisationUrl: "${createLink(controller: 'organisation', action: 'index')}",
            organisationSearchUrl: "${createLink(controller: 'organisation', action: 'search')}",
            noLogoImageUrl: "${r.resource(dir:'images', file:'no-image-2.png')}"
            };
    </r:script>
    <r:require modules="knockout,amplify,organisation"/>

</head>

<body>
<div class="container-fluid">
    <ul class="breadcrumb">
        <li>
            <g:link controller="home">Home</g:link><span class="divider">/</span>
        </li>
        <li class="active">Organisations<span class="divider"></span></li>
    </ul>
    <g:if test="${allowOrganisationRegistration}">
        <div>
            <h2 style="display:inline">Registered

            Organisations</h2>

            <g:if test="${user}">
                <button class="btn btn-success pull-right" data-bind="click:addOrganisation">Register new organisation</button>
            </g:if>
        </div>
    </g:if>
    <fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.ORGANISATION_LIST_PAGE_HEADER}"/>
    <g:if test="${fc.userIsAlaOrFcAdmin()}">
        <a href="${g.createLink(action:'create')}"><button class="btn btn-info pull-right">Create Organisation</button></a>
    </g:if>

    <div class="row-fluid">
        <div class="span6 input-append">
            <input id="searchText" data-bind="value:searchTerm, valueUpdate:'keyup'" class="span12" placeholder="Search organisations..." />
            <span class="add-on"><i class="fa fa-search"></i> </span>
        </div>
    </div>

    <h4>Found <span data-bind="text:pagination.totalResults"></span> organisations</h4>

    <hr/>

    <!-- ko foreach : organisations -->
    <div class="row-fluid organisation">
        <div class="organisation-logo"><img class="logo" data-bind="attr:{'src':logoUrl()?logoUrl():fcConfig.noLogoImageUrl}"></div>
        <div class="organisation-text">
            <h4>
                <a data-bind="visible:organisationId,attr:{href:fcConfig.viewOrganisationUrl+'/'+organisationId}"><span
                        data-bind="text:name"></span></a>
                <span data-bind="visible:!organisationId,text:name"></span>
            </h4>
            <div data-bind="html:description.markdownToHtml()"></div>
        </div>
    </div>
    <hr/>

    <!-- /ko -->

    <div class="row-fluid">
        <g:render template="/shared/pagination"/>
    </div>

</div>


<r:script>

    $(function () {
        var organisationsViewModel = new OrganisationsViewModel();
        ko.applyBindings(organisationsViewModel);
    });

</r:script>

</body>

</html>