<h4>Project info</h4>

<div class="row-fluid">
    <div class="span4 text-left" >
        <p>
            Edit project details and content
        </p>
    </div>
    <div class="span4 text-left" >
        <button class="btn btn-sm admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit </button>
    </div>
</div>

<g:if test="${fc.userIsAlaOrFcAdmin()}">
    <div class="margin-bottom-20"></div>
    <div class="row-fluid">
        <div class="span4 text-left" >
            <p>
                Harvest records to ALA
            </p>
        </div>
        <div class="span4 text-left" >
            <select data-bind="options: transients.yesNoOptions, value: transients.alaHarvest, optionsCaption: 'Please select'"></select>
        </div>
    </div>
    <div class="margin-bottom-20"></div>
    <div class="row-fluid">
        <div class="span4 text-left" >
                <p>Delete project</p>
        </div>
        <div class="span4 text-left" >
            <button class="admin-action btn btn-sm btn-danger" data-bind="click:deleteProject"> <i class="icon-remove icon-white"></i> Delete Project</button>
        </div>
    </div>
</g:if>