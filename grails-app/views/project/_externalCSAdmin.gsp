<div class="tab-pane" id="admin">
    <!-- ADMIN -->
    <div class="row-fluid">
        <div class="span2 large-space-before">
            <ul id="ul-cs-external-project-admin" class="nav nav-tabs nav-stacked">
                <li><a href="#project-settings" id="project-settings-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project info</a></li>
                <li><a href="#permissions" id="permissions-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Members</a></li>
            </ul>
        </div>
        <div class="span10">
            <div class="pill-content">

                <!-- PROJECT info -->
                <div id="project-settings" class="pill-pane">
                    <h4>Project info</h4>

                    <div class="row-fluid">
                        <div class="span12 text-left" >
                            <p>
                                Edit project details and content
                                <button class="btn btn-small admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit </button>
                           </p>
                        </div>

                    </div>

                    <div class="row-fluid">
                        <div class="span12 text-right" >
                            <g:if test="${fc.userIsAlaOrFcAdmin()}">
                                <p>
                                    <button class="admin-action btn btn-small btn-danger" data-bind="click:deleteProject"> <i class="icon-remove icon-white"></i> Delete Project</button>
                                </p>
                            </g:if>
                        </div>
                    </div>
                </div>
                <div id="permissions" class="pill-pane ${activeClass}">
                    <h3>Members</h3>
                    <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
                    <g:render template="/admin/permissionTable" model="[loadPermissionsUrl:g.createLink(controller:'project', action:'getMembersForProjectId', id:project.projectId), removeUserUrl:g.createLink(controller:'user', action:'removeUserWithRoleFromProject'), entityId:project.projectId, user:user]"/>
                </div>
            </div>
        </div>
    </div>
</div>

<r:script>
    function initialiseExternalCSAdmin(){
        new RestoreTab('ul-cs-external-project-admin', 'project-settings-tab');
    }
</r:script>