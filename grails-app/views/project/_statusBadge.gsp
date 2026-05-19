<span class="float-end">
    <g:if test="${project.projLifecycleStatus == 'published'}">
        <span class="badge text-bg-success">Published</span>
    </g:if>
    <g:elseif test="${project.projLifecycleStatus == 'unpublished'}">
        <span class="badge text-bg-info">Draft</span>
    </g:elseif>
</span>