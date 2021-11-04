<h4 class="mt-3 mt-lg-0">Project info</h4>

<div class="row">
    <div class="col-4" >
        <p>
            Edit project details and content
        </p>
    </div>
    <div class="col-4" >
        <button class="btn btn-sm btn-primary-dark admin-action" data-bind="click:editProject"><i class="fas fa-pencil-alt"></i> Edit</button>
    </div>
</div>

<g:if test="${fc.userIsAlaOrFcAdmin()}">
    <div class="row mt-2">
        <div class="col-4" >
            <p>
                Harvest records to ALA
            </p>
        </div>
        <div class="col-4" >
            <select data-bind="options: transients.yesNoOptions, value: transients.alaHarvest, optionsCaption: 'Please select'"></select>
        </div>
    </div>
    <div class="row mt-2">
        <div class="col-4">
                <p>Delete project</p>
        </div>
        <div class="col-4" >
            <button class="admin-action btn btn-sm btn-danger" data-bind="click:deleteProject"><i class="far fa-trash-alt"></i> Delete Project</button>
        </div>
    </div>
</g:if>