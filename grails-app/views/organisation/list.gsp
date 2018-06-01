<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>Organisations | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="Organisations"/>

    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}" async defer></script>
    <asset:script type="text/javascript">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            createOrganisationUrl: "${createLink(controller: 'organisation', action: 'create')}",
            viewOrganisationUrl: "${createLink(controller: 'organisation', action: 'index')}",
            organisationSearchUrl: "${createLink(controller: 'organisation', action: 'search')}",
            noLogoImageUrl: "${asset.assetPath(src:'no-image-2.png')}"
            };
    </asset:script>
    <asset:stylesheet src="organisation.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="organisation.js"/>
</head>

<body>
    <g:render template="organisationListing"></g:render>

</body>

</html>