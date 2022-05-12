<g:if test="${(hubConfig?.content?.hideProjectBackButton != true) && showBackButton}">
<div class="row ml-4 mb-4">
    <div class="col-12">
        <button class="btn btn-dark d-none" onclick="window.history.back()" data-bind="css :{'d-none': !transients.canShowBackButton()}">
            <i class="far fa-arrow-alt-circle-left"></i> <g:message code="project.display.backbutton"/>
        </button>
    </div>
</div>
</g:if>