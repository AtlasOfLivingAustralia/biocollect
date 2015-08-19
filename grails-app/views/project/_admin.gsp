<h4>Administrator actions</h4>
<div class="row-fluid">
    <p><button class="btn btn-small admin-action" data-bind="click:editProject"><i class="icon-edit"></i> Edit</button> Edit the project details and content</p>
    <g:if test="${fc.userIsAlaOrFcAdmin()}"><p><button class="admin-action btn btn-small btn-danger" data-bind="click:deleteProject"><i class="icon-remove icon-white"></i> Delete</button> Delete this project. <strong>This cannot be undone</strong></p></g:if>
</div>

<h3>Project Access</h3>
<g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
<g:render template="/admin/permissionTable" model="[loadPermissionsUrl:g.createLink(controller:'project', action:'getMembersForProjectId', id:project.projectId), removeUserUrl:g.createLink(controller:'user', action:'removeUserWithRoleFromProject'), entityId:project.projectId, user:user]"/>

