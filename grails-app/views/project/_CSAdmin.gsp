<div class="tab-pane" id="admin">
    <!-- ADMIN -->
    <div class="row-fluid">
        <div class="span2 large-space-before">
            <ul id="ul-cs-internal-project-admin" class="nav nav-tabs nav-stacked ">
                <li><a href="#project-settings" id="project-settings-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project info</a></li>
                <li><a href="#editProjectBlog" id="editProjectBlog-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Edit Blog</a></li>
                <li><a href="#edit-documents" id="edit-documents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Resources</a></li>

                <g:if test="${!project.isExternal}">
                    <li><a href="#project-activity" id="project-activity-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Survey settings</a></li>
                    <g:if test="${hasLegacyNewsAndEvents}">
                        <li><a href="#edit-news-and-events" id="editnewsandevents-tab" data-toggle="tab"><i class="icon-chevron-right"></i> News and events</a></li>
                    </g:if>
                    <g:if test="${hasLegacyProjectStories}">
                        <li><a href="#edit-project-stories" id="editprojectstories-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Project stories</a></li>
                    </g:if>
                </g:if>

                <li><a href="#permissions" id="permissions-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Members</a></li>
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <g:if test="${grailsApplication.config.notification.enabled?.toBoolean()}">
                    <li><a href="#project-notification" id="project-notification-tab" data-toggle="tab"><i class="icon-chevron-right"></i> <g:message code="notification.tabTitle"/></a></li>
                    </g:if>
                    <li><a href="#project-audit" id="project-audit-tab" data-toggle="tab"><i class="icon-chevron-right"></i> Audit</a></li>
                </g:if>
            </ul>
        </div>
        <div class="span10">
            <div class="pill-content">

                <!-- PROJECT info -->
                <div id="project-settings" class="pill-pane">
                    <g:render template="editOrDeleteProject"/>
                </div>
                <div id="editProjectBlog" class="pill-pane">
                    <h3>Edit Project Blog</h3>
                    <g:render template="/blog/blogSummary" model="${[blog:project.blog?:[]]}"/>
                </div>

                <!-- DOCUMENTS -->
                <div id="edit-documents" class="pill-pane">
                    <h3>Project Resources</h3>
                    <div class="row-fluid">
                        <div class="span10">
                            <g:render template="/shared/editDocuments"
                                      model="[useExistingModel: true,editable:true, filterBy: 'all', ignore: '', imageUrl:asset.assetPath(src:'filetypes'),containerId:'adminDocumentList']"/>
                        </div>
                    </div>

                    <div class="row-fluid attachDocumentModal">
                        <button class="btn btn-small btn-primary" id="doAttach" data-bind="click:attachDocument"><i class="icon-white icon-plus"></i> Attach Document</button>
                    </div>
                </div>

                <g:if test="${!project.isExternal}">
                    <div id="edit-news-and-events" class="pill-pane">
                        <g:render template="editProjectContent" model="${[attributeName:'newsAndEvents', header:'News and events']}"/>
                    </div>

                    <div id="edit-project-stories" class="pill-pane">
                        <g:render template="editProjectContent" model="${[attributeName:'projectStories', header:'Project stories']}"/>
                    </div>

                    <div id="project-activity" class="pill-pane">
                        <g:render template="/projectActivity/settings" model="[projectActivities:projectActivities]" />
                    </div>
                </g:if>

                <div id="permissions" class="pill-pane">
                    <h3>Members</h3>
                    <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
                    <g:render template="/admin/permissionTablePaginated"/>
                </div>

                <!--AUDIT-->
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <div id="project-audit" class="pill-pane">
                        <g:render template="/admin/auditProject"/>
                    </div>
                    <g:if test="${grailsApplication.config.notification.enabled?.toBoolean()}">
                    <div id="project-notification" class="pill-pane">
                        <g:render template="/project/notification"/>
                    </div>
                    </g:if>
                </g:if>

            </div>
        </div>
    </div>
</div>

<g:render template="/shared/attachDocument"/>

<asset:script type="text/javascript">
    function initialiseInternalCSAdmin() {
        new RestoreTab('ul-cs-internal-project-admin', 'project-settings-tab');
    }
</asset:script>