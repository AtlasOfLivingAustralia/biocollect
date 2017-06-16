<h2>Points of interest on project sites</h2>
<g:each in="${project.sites}" var="site">
    <g:if test="${site.poi}">
        <h3>Site: ${site.name}</h3>
        <g:each in="${site.poi}" var="poi">
            <div class="row-fluid">
                <h4>Photopoint: ${poi.name?.encodeAsHTML()}</h4>
            <g:if test="${poi.description}">${poi.description}</g:if>
            <g:if test="${poi.photos}">
                <g:render template="/site/sitePhotos" model="${[photos:poi.photos]}"></g:render></g:if> </h4>

            </div>
        </g:each>
    </g:if>
</g:each>