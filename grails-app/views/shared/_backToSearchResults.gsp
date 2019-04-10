<g:if test="${(hubConfig?.content?.hideProjectBackButton != true) && showBackButton}">
<div class="row padding-10 margin-bottom-20">
    <div class="span12">
        <button class="btn btn-default" onclick="window.history.back()" data-bind="visible: amplify.store('traffic-from-project-finder-page')">
            <i class="icon-arrow-left"></i> <g:message code="project.display.backbutton"/>
        </button>
    </div>
</div>
</g:if>