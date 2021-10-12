<div class="row">
    <div class="col-3">
        <div class="nav nav-pills flex-column" aria-orientation="vertical">
            <a class="nav-link active" id="org-actions-tab" href="#admin-actions" data-toggle="pill" role="tab"><i class="fa fa-chevron-right"></i> Actions</a>
            <a class="nav-link" id="org-members-tab" href="#admin-members" data-toggle="pill" role="tab"><i class="fa fa-chevron-right"></i> Members</a>
        </div>
    </div>

    <div class="col-9">
        <div class="tab-content">
            <div class="tab-pane active fade show" id="admin-actions" role="tabpanel" aria-labelledby="org-actions-tab">
                <h4>Administrator actions</h4>

                <div class="row mb-2">
                    <div class="col-12">
                        <button class="btn btn-sm btn-dark admin-action" data-bind="click:editOrganisation"><i
                            class="icon-edit"></i> Edit
                        </button>
                        Edit the organisation details and content
                    </div>
                </div>
                <g:if test="${fc.userIsAlaOrFcAdmin()}">
                <div class="row">
                    <div class="col-12">
                        <button class="admin-action btn btn-sm btn-danger" data-bind="click:deleteOrganisation">
                            <i class="icon-remove icon-white"></i> Delete
                        </button>
                        Delete this organisation from the system.
                        <strong>This cannot be undone</strong>
                    </div>
                </div>
                </g:if>
            </div>

            <div class="tab-pane fade" id="admin-members">
                <h4>Add Permissions</h4>

                <div class="row">
                    <div class="col-12 alert alert-info">
                        Any user access assigned to this organisation will automatically be applied to all projects managed by this organisation.
                    </div>
                </div>
                <g:render template="/admin/addPermissions"
                          model="[addUserUrl: g.createLink(controller: 'organisation', action: 'addUserAsRoleToOrganisation'), entityType: 'au.org.ala.ecodata.Organisation', entityId: organisation.organisationId]"/>
                <g:render template="/admin/permissionTable"
                          model="[loadPermissionsUrl: loadPermissionsUrl, removeUserUrl: g.createLink(controller: 'organisation', action: 'removeUserWithRoleFromOrganisation'), entityId: organisation.organisationId, user: user]"/>
            </div>
        </div>
    </div>
</div>