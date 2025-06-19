<!DOCTYPE html>
<html>
<head>
    <g:set var="title" value="${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}"/>
    <title>${title}</title>
    <meta name="layout" content="bs4"/>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/')},Home"/>
    <meta name="breadcrumb" content="${title}"/>
    <script>
        var fcConfig = {
            pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
            pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
            documentSearchUrl: "${createLink(controller: 'document', action: 'allDocumentsSearch')}",
            documentDownloadUrl: "${createLink(controller: 'document', action: 'allDocumentsSearch', params: [format: 'zip'])}",
            imageLocation:"${asset.assetPath(src: '')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            version: "${params.version}"
        }
    </script>

    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="document.js"/>
</head>

<body>
<content tag="bannertitle">
    ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}
</content>

<div id="documentSearch">
    <g:render template="/shared/listAllDocuments"
              model="[useExistingModel: false, editable: false, filterBy: 'all', ignore: 'programmeLogic', imageUrl:asset.assetPath(src:'filetypes'),containerId:'overviewDocumentList']"/>
</div>

</body>
</html>
