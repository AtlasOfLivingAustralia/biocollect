<div class="tab-pane">
    <div class="row">
        <div class="col-12 col-lg-2">
            <ul id="adminNav" class="nav flex-row flex-lg-column nav-pills nav-fil">
                <g:if test="${params.userIsProjectAdmin}">
                    <li ${activeClass} class="nav-item text-left"><a href="#settings" id="settings-tab" data-toggle="tab" class="nav-link active"><i class="fas fa-chevron-right"></i> Project settings</a></li>
                    <g:set var="activeClass" value=""/>
                </g:if>
                <li class="nav-item text-left"><a href="#reports" id="reports-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Project Reports</a> </li>
                <li class="nav-item text-left"><a href="#editMeriPlan" id="editMeriPlan-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Edit Project Plan</a></li>
                <li class="nav-item text-left"><a href="#editProjectBlog" id="editProjectBlog-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Edit Blog</a></li>
                <g:if test="${hasLegacyNewsAndEvents}">
                    <li class="nav-item text-left"><a href="#editNewsAndEvents" id="editnewsandevents-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> News and events</a></li>
                </g:if>
                <g:if test="${hasLegacyProjectStories}">
                    <li class="nav-item text-left"><a href="#editProjectStories" id="editprojectstories-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Project stories</a></li>
                </g:if>
                <li ${activeClass} class="nav-item text-left"><a href="#permissions" id="permissions-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Project access</a></li>
                <g:if test="${params.userIsProjectAdmin}">
                    <li ${activeClass} class="nav-item text-left"><a href="#mapConfiguration" id="mapConfiguration-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Sites</a></li>
                </g:if>
                <li class="nav-item text-left"><a href="#edit-documents" id="documents-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Resources</a></li>
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <li class="nav-item text-left"><a href="#project-audit" id="project-audit-tab" data-toggle="tab" class="nav-link"><i class="fas fa-chevron-right"></i> Audit</a></li>
                </g:if>
            </ul>
        </div>
        <div class="col-12 col-lg-10">
            <div class="tab-content">
                <g:set var="activeClass" value="active"/>
                <!-- PROJECT SETTINGS -->
                <div id="settings" class="tab-pane ${activeClass}">
                    <g:render template="editOrDeleteProject"/>
                </div>
                <g:set var="activeClass" value=""/>
                <div id="reports" class="tab-pane">
                    <g:render template="worksProjectReports"/>
                </div>
                <div id="editMeriPlan" class="tab-pane">
                    <h3>Edit Project Plan</h3>
                    <g:render template="editMeriPlan"></g:render>
                </div>
                <div id="editProjectBlog" class="tab-pane">
                    <h3>Edit Project Blog</h3>
                    <g:render template="/blog/blogSummary" model="${[blog:project.blog?:[]]}"/>
                </div>

                <div id="editNewsAndEvents" class="tab-pane">
                    <g:render template="editProjectContent" model="${[attributeName:'newsAndEvents', header:'News and events']}"/>
                </div>

                <div id="editProjectStories" class="tab-pane">
                    <g:render template="editProjectContent" model="${[attributeName:'projectStories', header:'Project stories']}"/>
                </div>

                <div id="permissions" class="tab-pane ${activeClass}">
                    <h3>Project Members</h3>
                    <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
                    <g:render template="/admin/permissionTablePaginated"/>
                </div>
                <div id="mapConfiguration" class="tab-pane validationEngineContainer">
                    <g:render template="worksMapConfiguration"></g:render>
                </div>
                <!-- DOCUMENTS -->
                <div id="edit-documents" class="tab-pane">
                    <h3>Resources</h3>
                    <div class="row">
                        <div class="col-sm-10">
                            <g:render template="/shared/editDocuments"
                                      model="[useExistingModel: true,editable:true, filterBy: 'all', ignore: '', imageUrl:asset.assetPath(src:'filetypes'),containerId:'adminDocumentList']"/>
                        </div>
                    </div>
                    %{--The modal view containing the contents for a modal dialog used to attach a document--}%
                    <g:render template="/shared/attachDocument"/>
                    <div class="row attachDocumentModal">
                        <button class="btn btn-small btn-primary" id="doAttach" data-bind="click:attachDocument"><i class="fas fa-plus"></i>  Attach Document</button>
                    </div>
                </div>
                <!--AUDIT-->
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <div id="project-audit" class="tab-pane">
                        <g:render template="/admin/auditProject"/>
                    </div>
                </g:if>
            </div>
        </div>
    </div>
</div>