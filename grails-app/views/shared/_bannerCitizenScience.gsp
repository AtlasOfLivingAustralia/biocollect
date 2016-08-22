<g:if test="${!hubConfig.bannerUrl}">
    <div class="jumbotron ala-header">
        <div class="container-fluid no-gutter">
            <g:render template="/shared/projectFinderQueryInput" class="pull-right"></g:render>
        </div>
    </div>
</g:if>

<g:elseif test="${hubConfig.bannerUrl}">
    <div class="jumbotron" style="background: url(${hubConfig.bannerUrl}) no-repeat center top; height: 225px; background-size: cover; background-position-y: -54px;">
        <div class="container-fluid no-gutter">
            <g:render template="/shared/projectFinderQueryInput" class="pull-right"></g:render>
        </div>
    </div>
</g:elseif>


