<h4>Project info</h4>

<div class="row-fluid">
    <div class="span12 text-left" >
        <p>
            Edit project details and content
            <button class="btn admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit </button>
        </p>
    </div>

</div>

<div class="row-fluid">
    <div class="span12 text-left" >
        <g:if test="${fc.userIsAlaOrFcAdmin()}">
            <p>
                <button class="admin-action btn btn-danger" data-bind="click:deleteProject"> <i class="icon-remove icon-white"></i> Delete Project</button>
            </p>
        </g:if>
    </div>
</div>