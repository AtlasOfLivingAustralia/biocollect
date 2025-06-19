<span class="float-right">
    <g:if test="${project.projLifecycleStatus == 'published'}">
        <span class="badge badge-success">Published</span>
    </g:if>
    <g:elseif test="${project.projLifecycleStatus == 'unpublished'}">
        <span class="badge badge-info">Draft</span>
    </g:elseif>
</span>