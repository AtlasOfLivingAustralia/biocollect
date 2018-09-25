<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="${project?.name}"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400italic,600,700"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Oswald:300"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        projectUpdateUrl: "${createLink(action: 'ajaxUpdate', id: project.projectId)}",
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        sitesDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSitesFromProject', id:project.projectId)}",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSiteFromProject', id:project.projectId)}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        siteEditUrl: "${createLink(controller: 'site', action: 'edit')}",
        removeSiteUrl: "${createLink(controller: 'site', action: '')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        activityBulkDeleteUrl: "${createLink(controller: 'bioActivity', action: 'bulkDelete')}",
        activityBulkEmbargoUrl: "${createLink(controller: 'bioActivity', action: 'bulkEmbargo')}",
        activityBulkReleaseUrl: "${createLink(controller: 'bioActivity', action: 'bulkRelease')}",
        activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
        activityEnterDataUrl: "${createLink(controller: 'activity', action: 'enterData')}",
        activityPrintUrl: "${createLink(controller: 'activity', action: 'print')}",
        activityCreateUrl: "${createLink(controller: 'activity', action: 'create')}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        activityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
        siteCreateUrl: "${createLink(controller: 'site', action: 'createForProject', params: [projectId:project.projectId])}",
        siteSelectUrl: "${createLink(controller: 'site', action: 'select', params:[projectId:project.projectId])}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        siteUploadUrl: "${createLink(controller: 'site', action: 'uploadShapeFile', params:[projectId:project.projectId])}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        starProjectUrl: "${createLink(controller: 'project', action: 'starProject')}",
        addUserRoleUrl: "${createLink(controller: 'user', action: 'addUserAsRoleToProject')}",
        removeUserWithRoleUrl: "${createLink(controller: 'user', action: 'removeUserWithRole')}",
        projectMembersUrl: "${createLink(controller: 'project', action: 'getMembersForProjectId')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        documentUpdateUrl: "${g.createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        imageLocation:"${asset.assetPath(src:'')}",
        pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
        pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
        imgViewer: "${createLink(controller: 'resource', action: 'imageviewer')}",
        audioViewer: "${createLink(controller: 'resource', action: 'audioviewer')}",
        videoViewer: "${createLink(controller: 'resource', action: 'videoviewer')}",
        errorViewer: "${createLink(controller: 'resource', action: 'error')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        auditMessageUrl: "${createLink( controller: 'project', action:'auditMessageDetails', params:[projectId: project.projectId])}",
        createBlogEntryUrl: "${createLink(controller: 'blog', action:'create', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}",
        editBlogEntryUrl: "${createLink(controller: 'blog', action:'edit', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}",
        deleteBlogEntryUrl: "${createLink(controller: 'blog', action:'delete', params:[projectId:project.projectId])}",
        flimit: ${grailsApplication.config.facets.flimit}
        },
        here = window.location.href;

    </asset:script>

    <!--[if gte IE 8]>
        <style>
           .thumbnail > img {
                max-width: 400px;
            }
            .thumbnail {
                max-width: 410px;
            }
        </style>
    <![endif]-->
    <asset:javascript src="common.js"/>
    <asset:javascript src="projects-manifest.js"/>
</head>
<body>
<div class="container-fluid">
    <g:if test="${!user?.isEditor}">
        <div class="alert alert-info">
            This project is funded by a federal government programme and can only be edited in the <a href="${g.createLink(id:project.projectId, base:grailsApplication.config.merit.url)}">MERIT system</a>
        </div>
    </g:if>

    <div class="row-fluid">
        <div class="row-fluid">
            <div class="clearfix">
                <h1 class="pull-left" data-bind="text:name"></h1>
                <g:if test="${flash.errorMessage || flash.message}">
                    <div class="span5">
                        <div class="alert alert-error">
                            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                            ${flash.errorMessage?:flash.message}
                        </div>
                    </div>
                </g:if>
                <div class="pull-right">
                    <g:set var="disabled">${(!user) ? "disabled='disabled' title='login required'" : ''}</g:set>
                    <g:if test="${isProjectStarredByUser}">
                        <button class="btn" id="starBtn"><i class="icon-star"></i> <span>Remove from favourites</span></button>
                    </g:if>
                    <g:else>
                        <button class="btn" id="starBtn" ${disabled}><i class="icon-star-empty"></i> <span>Add to favourites</span></button>
                    </g:else>
                </div>
            </div>
        </div>
    </div>

    <!-- content tabs -->
    <g:set var="tabIsActive"><g:if test="${user?.hasViewAccess}">tab</g:if></g:set>
    <ul id="projectTabs" class="nav nav-tabs big-tabs">
        <li class="active"><a href="#overview" id="overview-tab" data-toggle="tab">Overview</a></li>
        <li><a href="#document" id="document-tab" data-toggle="${tabIsActive}">Documents</a></li>
        <li><a href="#plan" id="plan-tab" data-toggle="${tabIsActive}">Activities</a></li>
        %{--<g:if test="${!hubConfig?.defaultFacetQuery.contains('isWorks:true')}">--}%
            %{--<li><a href="#site" id="site-tab" data-toggle="${tabIsActive}">Sites</a></li>--}%
        %{--</g:if>--}%
        <li><a href="#dashboard" id="dashboard-tab" data-toggle="${tabIsActive}">Dashboard</a></li>
        <g:if test="${(user?.isAdmin || user?.isCaseManager) && user?.isEditor}"><li><a href="#admin" id="admin-tab" data-toggle="tab">Admin</a></li></g:if>
    </ul>
    <div class="tab-content" style="overflow:visible;">
        <div class="tab-pane active" id="overview">
            <!-- OVERVIEW -->
            <div class="row-fluid">
                <div class="clearfix" data-bind="visible:organisationId()||organisationName()">
                    <h4>
                        Recipient:
                        <a data-bind="visible:organisationId(),text:organisationName,attr:{href:fcConfig.organisationLinkBaseUrl + '/' + organisationId()}"></a>
                        <span data-bind="visible:!organisationId(),text:organisationName"></span>
                    </h4>
                </div>
                <div class="clearfix" data-bind="visible:serviceProviderName()">
                    <h4>
                        Service provider:
                        <span data-bind="text:serviceProviderName"></span>
                    </h4>
                </div>
                <div class="clearfix" data-bind="visible:associatedProgram()">
                    <h4>
                        Programme:
                        <span data-bind="text:associatedProgram"></span>
                        <span data-bind="text:associatedSubProgram"></span>
                    </h4>
                </div>
                <div class="clearfix" data-bind="visible:funding()">
                    <h4>
                        Approved funding (GST inclusive): <span data-bind="text:funding.formattedCurrency"></span>
                    </h4>

                </div>

                <div class="clearfix" data-bind="visible:plannedStartDate()">
                    <h4>
                        Project start: <span data-bind="text:plannedStartDate.formattedDate"></span>
                        <span data-bind="visible:plannedEndDate()">Project finish: <span data-bind="text:plannedEndDate.formattedDate"></span></span>
                    </h4>
                </div>

                <div class="clearfix" style="font-size:14px;">
                    <div class="span3" data-bind="visible:status" style="margin-bottom: 0">
                        <span data-bind="if: status().toLowerCase() == 'active'">
                            Project Status:
                            <span style="text-transform:uppercase;" data-bind="text:status" class="badge badge-success" style="font-size: 13px;"></span>
                        </span>
                        <span data-bind="if: status().toLowerCase() == 'completed'">
                            Project Status:
                            <span style="text-transform:uppercase;" data-bind="text:status" class="badge badge-info" style="font-size: 13px;"></span>
                        </span>

                    </div>
                    <div class="span4" data-bind="visible:grantId" style="margin-bottom: 0">
                        Grant Id:
                        <span data-bind="text:grantId"></span>
                    </div>
                    <div class="span4" data-bind="visible:externalId" style="margin-bottom: 0">
                        External Id:
                        <span data-bind="text:externalId"></span>
                    </div>
                    <div class="span4" data-bind="visible:manager" style="margin-bottom: 0">
                        Manager:
                        <span data-bind="text:manager"></span>
                    </div>
                </div>
                <g:render template="/shared/listDocumentLinks"
                          model="${[transients:transients,imageUrl:asset.assetPath(src:'filetypes')]}"/>

                <div class="clearfix" data-bind="visible:description()">
                    <p class="well well-small more" data-bind="text:description"></p>
                </div>
            </div>
            <div class="row-fluid">
                <!-- show any primary images -->
                <div data-bind="visible:primaryImages() !== null,foreach:primaryImages,css:{span5:primaryImages()!=null}">
                    <div class="thumbnail with-caption space-after">
                        <img class="img-rounded" data-bind="attr:{src:url, alt:name}" alt="primary image"/>
                        <p class="caption" data-bind="text:name"></p>
                        <p class="attribution" data-bind="visible:attribution"><small><span data-bind="text:attribution"></span></small></p>
                    </div>
                </div>

                <div class="span10">
                    <h4>Project Blog</h4>
                    <div class="well">
                        <g:render template="/shared/blog" model="${[blog:project.blog?:[]]}"/>
                    </div>
                    <div data-bind="visible:newsAndEvents()">
                        <h4>News and events</h4>
                        <div id="newsAndEventsDiv" data-bind="html:newsAndEvents" class="well"></div>
                    </div>
                    <div data-bind="visible:projectStories()">
                        <h4>Project stories</h4>
                        <div id="projectStoriesDiv" data-bind="html:projectStories" class="well"></div>
                    </div>
                </div>
            </div>
        </div>

        <g:if test="${user?.hasViewAccess}">
            <div class="tab-pane" id="document">
                <!-- DOCUMENTS -->
                <g:render template="docs" />
            </div>

            <div class="tab-pane" id="plan">
                <!-- PLANS -->
                <g:render template="/shared/activitiesWorks"
                          model="[activities:activities ?: [], sites:project.sites ?: [], showSites:true]"/>
            </div>

            <div class="tab-pane" id="dashboard">
                <!-- DASHBOARD -->
                <g:render template="dashboard"/>
            </div>
        </g:if>
        %{-- A user can be an admin but not an editor if this is a MERIT project --}%
        <g:if test="${(user?.isAdmin || user?.isCaseManager) && user?.isEditor}">
            <g:set var="activeClass" value="class='active'"/>
            <div class="tab-pane" id="admin">
            <!-- ADMIN -->
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
                                                  model="[useExistingModel: true,editable:true, filterBy: 'all', ignore: '', imageUrl:asset.assetPath(src:'filetypes'),containerId:'adminDocumentList']"/>
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
            </div>
        </g:if>
    </div>

    <g:if env="development">
    <hr />
    <div class="expandable-debug">
        <h3>Debug</h3>
        <div>
            <h4>KO model</h4>
            <pre data-bind="text:ko.toJSON($root,null,2)"></pre>
            <h4>Activities</h4>
            <pre>${activities?.encodeAsHTML()}</pre>
            <h4>Sites</h4>
            <pre>${project.sites?.encodeAsHTML()}</pre>
            <h4>Project</h4>
            <pre>${project?.encodeAsHTML()}</pre>
            <h4>Features</h4>
            <pre>${mapFeatures}</pre>
            <h4>activityTypes</h4>
            <pre>${activityTypes}</pre>
        </div>
    </div>
    </g:if>
</div>
    <asset:script type="text/javascript">
        $(window).load(function () {
            var map;
            // setup 'read more' for long text
            $('.more').shorten({
                moreText: 'read more',
                showChars: '1000'
            });
            // setup confirm modals for deletions
            $(document).on("click", "a[data-bb]", function(e) {
                e.preventDefault();
                var type = $(this).data("bb"),
                    href = $(this).attr('href');
                if (type === 'confirm') {
                    bootbox.confirm("Delete this entire project? Are you sure?", function(result) {
                        if (result) {
                            document.location.href = href;
                        }
                    });
                }
            });

            $('#settings-validation').validationEngine();

            $('.helphover').popover({animation: true, trigger:'hover'});

            $('#cancel').click(function () {
                document.location.href = "${createLink(action: 'index', id: project.projectId)}";
            });

            var project = <fc:modelAsJavascript model="${project}"/>;
            var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
            var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
            var viewModel = new ProjectViewModel(project, ${user?.isEditor?:false});

            viewModel.loadPrograms(<fc:modelAsJavascript model="${programs}"/>);
            ko.applyBindings(viewModel);

            // retain tab state for future re-visits
            // and handle tab-specific initialisations
            var planTabInitialised = false;

            var dashboardInitialised = false;

            $('#projectTabs a[data-toggle="tab"]').on('shown', function (e) {
                var tab = e.currentTarget.hash;
                amplify.store('project-tab-state', tab);
                // only init map when the tab is first shown
                if (tab === '#site' && map === undefined) {
                    var mapOptions = {
                        zoomToBounds:true,
                        zoomLimit:16,
                        highlightOnHover:true,
                        features:[],
                        featureService: "${createLink(controller: 'proxy', action:'feature')}",
                        wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
                    };

                    map = new ALA.Map("map", {});
                    var mapFeatures = ${mapFeatures};
                    var sitesViewModel = new SitesViewModel(project.sites, map, mapFeatures, ${user?.isEditor?:false});
                    ko.applyBindings(sitesViewModel, document.getElementById('sitesList'));

                    // set trigger for site reverse geocoding
                    sitesViewModel.triggerGeocoding();
                    sitesViewModel.displaySites();
                }
                if (tab === '#plan' && !planTabInitialised) {
                    $.event.trigger({type:'planTabShown'});
                    planTabInitialised = true;
                }
                if (tab == '#dashboard' && !dashboardInitialised) {
                    $.event.trigger({type:'dashboardShown'});
                    dashboardInitialised;
                }
            });

            var newsAndEventsInitialised = false;
            $('#editnewsandevents-tab').on('shown', function() {
                if (!newsAndEventsInitialised) {
                    var newsAndEventsViewModel = new window.newsAndEventsViewModel(viewModel, newsAndEventsMarkdown);
                    ko.applyBindings(newsAndEventsViewModel, $('#editnewsAndEventsContent')[0]);
                    newsAndEventsInitialised = true;
                }

            });
            var projectStoriesInitialised = false;
            $('#editprojectstories-tab').on('shown', function() {
                if (!projectStoriesInitialised) {
                    var projectStoriesViewModel = new window.projectStoriesViewModel(viewModel, projectStoriesMarkdown);
                    ko.applyBindings(projectStoriesViewModel, $('#editprojectStoriesContent')[0]);
                    projectStoriesInitialised = true;
                }
            });

            // re-establish the previous tab state
            var storedTab = amplify.store('project-tab-state');
            var isEditor = ${user?.isEditor?:false};
            if (storedTab === '') {
                $('#overview-tab').tab('show');
            } else if (isEditor) {
                $(storedTab + '-tab').tab('show');
            }

            // Non-editors should get tooltip and popup when trying to click other tabs
            $('#projectTabs li a').not('[data-toggle="tab"]').css('cursor', 'not-allowed') //.data('placement',"right")
            .attr('title','Only available to project members').addClass('tooltips');

            // Star button click event
            $("#starBtn").click(function(e) {
                var isStarred = ($("#starBtn i").attr("class") == "icon-star");
                toggleStarred(isStarred);
            });

            // BS tooltip
            $('.tooltips').tooltip();

            $('#gotoEditBlog').click(function () {
                amplify.store('project-admin-tab-state', '#editProjectBlog');
                $('#admin-tab').tab('show');
            });

        });// end window.load

       /**
        * Star/Unstar project for user - send AJAX and update UI
        *
        * @param boolean isProjectStarredByUser
        */
        function toggleStarred(isProjectStarredByUser) {
            var basUrl = fcConfig.starProjectUrl;
            var query = "?userId=${user?.userId}&projectId=${project?.projectId}";
            if (isProjectStarredByUser) {
                // remove star
                $.getJSON(basUrl + "/remove" + query, function(data) {
                    if (data.error) {
                        alert(data.error);
                    } else {
                        $("#starBtn i").removeClass("icon-star").addClass("icon-star-empty");
                        $("#starBtn span").text("Add to favourites");
                    }
                }).fail(function(j,t,e){ alert(t + ":" + e);}).done();
            } else {
                // add star
                $.getJSON(basUrl + "/add" + query, function(data) {
                    if (data.error) {
                        alert(data.error);
                    } else {
                        $("#starBtn i").removeClass("icon-star-empty").addClass("icon-star");
                        $("#starBtn span").text("Remove from favourites");
                    }
                }).fail(function(j,t,e){ alert(t + ":" + e);}).done();
            }
        }

        // select about tab when coming from project finder
        if(amplify.store('traffic-from-project-finder-page')){
            amplify.store('traffic-from-project-finder-page',false)
            $('#about-tab').tab('show');
        }
    </asset:script>
    <g:if test="${user?.isAdmin || user?.isCaseManager}">
        <asset:script type="text/javascript">
            // Admin JS code only exposed to admin users
            $(window).load(function () {

                // remember state of admin nav (vertical tabs)
                $('#adminNav a[data-toggle="tab"]').on('shown', function (e) {
                    var tab = e.currentTarget.hash;
                    amplify.store('project-admin-tab-state', tab);
                });
                var storedAdminTab = amplify.store('project-admin-tab-state');
                // restore state if saved
                if (storedAdminTab === '') {
                    $('#permissions-tab').tab('show');
                } else {
                    $(storedAdminTab + "-tab").tab('show');
                }
            }); // end window.load

        </asset:script>
    </g:if>
</body>
</html>
