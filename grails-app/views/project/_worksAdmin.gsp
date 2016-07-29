<div class="row-fluid">
    <div class="span2 large-space-before">
        <ul id="adminNav" class="nav nav-tabs nav-stacked ">
            <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                <li ${activeClass}><a href="#settings" id="settings-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project settings</a></li>
                <g:set var="activeClass" value=""/>
            </g:if>
            <li><a href="#editProjectBlog" id="editProjectBlog-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Edit Project Blog</a></li>
            <li><a href="#editNewsAndEvents" id="editnewsandevents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> News and events</a></li>
            <li><a href="#editProjectStories" id="editprojectstories-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project stories</a></li>

            <li ${activeClass}><a href="#permissions" id="permissions-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project access</a></li>
            <li><a href="#species" id="species-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Species of interest</a></li>
            <li><a href="#edit-documents" id="documents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Documents</a></li>
        </ul>
    </div>
    <div class="span10">
        <div class="pill-content">
            <g:set var="activeClass" value="active"/>
            <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole)}">
                <!-- PROJECT SETTINGS -->
                <div id="settings" class="pill-pane ${activeClass}">
                    <g:render template="editOrDeleteProject"/>
                </div>
                <g:set var="activeClass" value=""/>
            </g:if>
            <div id="editProjectBlog" class="pill-pane">
                <h3>Edit Project Blog</h3>
                <g:render template="/blog/blogSummary" model="${[blog:project.blog?:[]]}"/>
            </div>
            <div id="editNewsAndEvents" class="pill-pane">

                <g:render template="editProjectContent" model="${[attributeName:'newsAndEvents', header:'News and events']}"/>
            </div>

            <div id="editProjectStories" class="pill-pane">
                <g:render template="editProjectContent" model="${[attributeName:'projectStories', header:'Project stories']}"/>
            </div>

            <div id="permissions" class="pill-pane ${activeClass}">
                <h3>Project Access</h3>
                <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
                <g:render template="/admin/permissionTable" model="[loadPermissionsUrl:g.createLink(controller:'project', action:'getMembersForProjectId', id:project.projectId), removeUserUrl:g.createLink(controller:'user', action:'removeUserWithRoleFromProject'), entityId:project.projectId, user:user]"/>

            </div>
            <!-- SPECIES -->
            %{--<div class="border-divider large-space-before">&nbsp;</div>--}%
            <div id="species" class="pill-pane">
                %{--<a name="species"></a>--}%
                <g:render template="/species/species" model="[project:project, activityTypes:activityTypes]"/>
            </div>
            <!-- DOCUMENTS -->
            <div id="edit-documents" class="pill-pane">
                <h3>Project Documents</h3>
                <div class="row-fluid">
                    <div class="span10">
                        <g:render template="/shared/editDocuments"
                                  model="[useExistingModel: true,editable:true, filterBy: 'all', ignore: '', imageUrl:resource(dir:'/images/filetypes'),containerId:'adminDocumentList']"/>
                    </div>
                </div>
                %{--The modal view containing the contents for a modal dialog used to attach a document--}%
                <g:render template="/shared/attachDocument"/>
                <div class="row-fluid attachDocumentModal">
                    <button class="btn btn-small btn-primary" id="doAttach" data-bind="click:attachDocument"><i class="icon-white icon-plus"></i> Attach Document</button>
                </div>
            </div>
        </div>
    </div>
</div>