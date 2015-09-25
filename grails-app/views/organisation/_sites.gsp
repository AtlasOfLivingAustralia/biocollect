<g:if test="${showShapefileDownload}">
    <div class="row-fluid">
        <a style="margin-bottom:10px; float:right;" target="_blank" href="${g.createLink(controller: 'organisation', action: 'downloadShapefile', id:organisation.organisationId)}">
            <button class="btn btn-info">Download Shapefile</button>
        </a>
    </div>
</g:if>
<g:render template="/shared/sites"/>

