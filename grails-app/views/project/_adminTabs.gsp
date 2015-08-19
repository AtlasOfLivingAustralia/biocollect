<div class="tab-pane" id="admin">
    <!-- ADMIN -->
    <div class="row-fluid">
        <div class="span2 large-space-before">
            <ul id="adminNav" class="nav nav-tabs nav-stacked ">
                <li class='active'><a href="#projectSettings" id="projectDetails-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project info</a></li>
                <li><a href="#projectActivity" id="projectActivity-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Survey settings</a></li>
                <li><a href="#editNewsAndEvents" id="editnewsandevents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> News and events</a></li>
                <li><a href="#editProjectStories" id="editProjectStories-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project stories</a></li>
                <li><a href="#edit-documents" id="documents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Resources</a></li>
                <li><a href="#permissions" id="permissions-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Members</a></li>

            </ul>
        </div>
        <div class="span10">
            <div class="pill-content">

                <!-- PROJECT info -->
                <div id="projectSettings" class="pill-pane active">
                    <h4>Project info</h4>

                    <div class="row-fluid">
                        <div class="span12 text-left" >
                            <p>Edit project details and content </p> <p><button class="btn btn-small admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit </button>
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

                <div id="editNewsAndEvents" class="pill-pane">
                    <g:render template="editProjectContent" model="${[attributeName:'newsAndEvents', header:'News and events']}"/>
                </div>

                <div id="editProjectStories" class="pill-pane">
                    <g:render template="editProjectContent" model="${[attributeName:'projectStories', header:'Project stories']}"/>
                </div>

                <div id="projectActivity" class="pill-pane">
                    <g:render template="/projectActivity/settings" model="[projectActivities : projectActivities]" />
                </div>

                <!-- DOCUMENTS -->
                <div id="edit-documents" class="pill-pane">
                    <h3>Project Documents</h3>
                    <div class="row-fluid">
                        <div class="span10">
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