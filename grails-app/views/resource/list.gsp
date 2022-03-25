<%@ page import="grails.converters.JSON;" contentType="text/html;charset=UTF-8" %>
<g:set var="mapService" bean="mapService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <g:set var="title" value="${myFavourites? message(code: "site.myFavouriteSites.heading") : message(code: "resource.allResources.heading")}"/>
    <title>${title}</title>
    %{--    <meta name="layout" content="${hubConfig.skin}"/>--}%
    <meta name="layout" content="bs4"/>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script>
        var fcConfig = {
            listDocumentsUrl: '${createLink(controller: 'document', action: 'elasticsearch')}',
            pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
            documentSearchUrl: "${createLink(controller: 'document', action: 'allDocumentsSearch')}"
        }
    </script>

    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="document.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body>

<div id="documentSearch">
    <g:render template="/shared/listAllDocuments"
              model="[useExistingModel: true, editable: false, filterBy: 'all', ignore: 'programmeLogic', imageUrl:asset.assetPath(src:'filetypes'),containerId:'overviewDocumentList']"/>
</div>

</body>
</html>