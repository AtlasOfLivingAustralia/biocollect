<div>
    <!-- ADMIN -->
    <div class="row mt-4">
        <div class="col-12 col-lg-2">
            <ul id="ul-cs-internal-project-admin" class="nav flex-row flex-lg-column nav-pills nav-fill">
                <li class="nav-item text-left"><a class="nav-link active" href="#project-settings" id="project-settings-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.information"/></a></li>
                <li class="nav-item text-left"><a class="nav-link" href="#editProjectBlog" id="editProjectBlog-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.blog"/></a></li>
                <li class="nav-item text-left"><a class="nav-link" href="#edit-documents" id="edit-documents-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}</a></li>

                <g:if test="${!project.isExternal}">
                    <li class="nav-item text-left"><a class="nav-link" href="#project-activity" id="project-activity-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.settings"/></a></li>
                    <g:if test="${hasLegacyNewsAndEvents}">
                        <li class="nav-item text-left"><a class="nav-link" href="#edit-news-and-events" id="editnewsandevents-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.news"/></a></li>
                    </g:if>
                    <g:if test="${hasLegacyProjectStories}">
                        <li class="nav-item text-left"><a class="nav-link" href="#edit-project-stories" id="editprojectstories-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.stories"/></a></li>
                    </g:if>
                    <li class="nav-item text-left"><a class="nav-link" href="#project-reference-assessment" id="project-reference-assessment-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.referenceAssessment"/></a></li>
                </g:if>

                <li class="nav-item text-left"><a class="nav-link" href="#permissions" id="permissions-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.members"/></a></li>
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <g:if test="${grailsApplication.config.notification.enabled?.toBoolean()}">
                    <li class="nav-item text-left"><a class="nav-link" href="#project-notification" id="project-notification-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="notification.tabTitle"/></a></li>
                    </g:if>
                    <li class="nav-item text-left"><a class="nav-link" href="#project-audit" id="project-audit-tab" data-toggle="tab"><i class="fas fa-chevron-right"></i> <g:message code="project.admin.audit"/></a></li>
                </g:if>
            </ul>
        </div>
        <div class="col-12 col-lg-10">
            <div class="tab-content">

                <!-- PROJECT info -->
                <div id="project-settings" class="tab-pane active" role="tabpanel">
                    <g:render template="editOrDeleteProject"/>
                </div>
                <div id="editProjectBlog" class="tab-pane" role="tabpanel">
                    <h4 class="mt-3 mt-lg-0"><g:message code="project.admin.editblog"/></h4>
                    <g:render template="/blog/blogSummary" model="${[blog:project.blog?:[]]}"/>
                </div>

                <!-- DOCUMENTS -->
                <div id="edit-documents" class="tab-pane" role="tabpanel">
                    <h4 class="mt-3 mt-lg-0">Project ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}</h4>
                    <div class="row">
                        <div class="col-12">
                            <g:render template="/shared/editDocuments"
                                      model="[useExistingModel: true,editable:true, filterBy: 'all', ignore: '', imageUrl:asset.assetPath(src:'filetypes'),containerId:'adminDocumentList']"/>
                        </div>
                    </div>

                    <div class="row attachDocumentModal">
                        <div class="col-12">
                            <button class="btn btn-sm btn-primary-dark" id="doAttach" data-bind="click:attachDocument"><i class="fas fa-plus"></i> <g:message code="project.admin.attachdoc"/></button>
                        </div>
                    </div>
                </div>

                <g:if test="${!project.isExternal}">
                    <div id="edit-news-and-events" class="tab-pane" role="tabpanel">
                        <g:render template="editProjectContent" model="${[attributeName:'newsAndEvents', header: message(code: 'project.admin.news')]}"/>
                    </div>

                    <div id="edit-project-stories" class="tab-pane" role="tabpanel">
                        <g:render template="editProjectContent" model="${[attributeName:'projectStories', header: message(code:'project.admin.stories')]}"/>
                    </div>

                    <div id="project-activity" class="tab-pane" role="tabpanel">
                        <g:render template="/projectActivity/settings" model="[projectActivities:projectActivities]" />
                    </div>

                    <div id="project-reference-assessment" class="tab-pane" role="tabpanel">
                        <g:render template="/referenceAssessment/settings" model="[projectActivities:projectActivities]" />
                    </div>
                </g:if>

                <div id="permissions" class="tab-pane" role="tabpanel">
                    <h4 class="mt-3 mt-lg-0"><g:message code="project.admin.members"/></h4>
                    <g:render template="/admin/addPermissions" model="[addUserUrl:g.createLink(controller:'user', action:'addUserAsRoleToProject'), entityId:project.projectId]"/>
                    <g:render template="/admin/permissionTablePaginated"/>
                </div>

                <!--AUDIT-->
                <g:if test="${fc.userInRole(role: grailsApplication.config.security.cas.alaAdminRole) || fc.userInRole(role: grailsApplication.config.security.cas.adminRole) || user.isAdmin}">
                    <div id="project-audit" class="tab-pane" role="tabpanel">
                        <g:render template="/admin/auditProject"/>
                    </div>
                    <g:if test="${grailsApplication.config.notification.enabled?.toBoolean()}">
                    <div id="project-notification" class="tab-pane" role="tabpanel">
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