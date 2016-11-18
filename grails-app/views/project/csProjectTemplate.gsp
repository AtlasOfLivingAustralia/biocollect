<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        homePagePath: "${createLink(controller: 'home', action: 'index')}",
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        projectUpdateUrl:"${createLink(action:'ajaxUpdate', id:project.projectId)}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        sitesDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSitesFromProject', id:project.projectId)}",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSiteFromProject', id:project.projectId)}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        siteEditUrl: "${createLink(controller: 'site', action: 'edit')}",
        removeSiteUrl: "${createLink(controller: 'site', action: '')}",
        activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
        activityCreateUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
        activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
        activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
        activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
        activityListUrl : "${createLink(controller: 'bioActivity', action: 'ajaxListForProject', params: [id:project.projectId])}",
        activiyCountUrl: "${createLink(controller: 'bioActivity', action: 'getProjectActivityCount')}",
        speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
        searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities',params: [projectId:project.projectId, version: params.version])}",
        downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData',params: [projectId:project.projectId])}",
        getRecordsForMapping: "${createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params:[version: params.version])}",
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
        projectActivityCreateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxCreate', params: [projectId:project.projectId])}",
        projectActivityUpdateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxUpdate')}",
        projectActivityDeleteUrl: "${createLink(controller: 'projectActivity', action: 'delete')}",
        projectActivityUnpublishUrl: "${createLink(controller: 'projectActivity', action: 'unpublish')}",
        addNewSpeciesListsUrl: "${createLink(controller: 'projectActivity', action: 'ajaxAddNewSpeciesLists', params: [projectId:project.projectId])}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'search', action: 'searchSpeciesList')}",
        speciesListsServerUrl: "${grailsApplication.config.lists.baseURL}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'species')}",
        imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        imageLocation:"${resource(dir:'/images')}",
        pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
        pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
        imgViewer: "${createLink(controller: 'resource', action: 'imageviewer')}",
        audioViewer: "${createLink(controller: 'resource', action: 'audioviewer')}",
        videoViewer: "${createLink(controller: 'resource', action: 'videoviewer')}",
        recordListUrl: "${createLink(controller: 'record', action: 'ajaxListForProject', params: [id:project.projectId])}",
        recordDeleteUrl:"${createLink(controller: 'record', action: 'delete')}",
        projectDeleteUrl:"${createLink(action:'delete', id:project.projectId)}",
        errorViewer: "${createLink(controller: 'resource', action: 'error')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        auditMessageUrl: "${createLink( controller: 'project', action:'auditMessageDetails', params:[projectId: project.projectId])}",
        projectId: "${project.projectId}",
        projectLinkPrefix: "${createLink(controller: 'project')}/",
        recordImageListUrl: '${createLink(controller: "project", action: "listRecordImages", params:[version: params.version])}',
        view: 'project',
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        version: "${params.version}",
        aekosSubmissionPostUrl: "${createLink(controller: 'projectActivity', action: 'aekosSubmission')}",
        createBlogEntryUrl: "${createLink(controller: 'blog', action:'create', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}%23overview",
        editBlogEntryUrl: "${createLink(controller: 'blog', action:'edit', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}%23overview",
        deleteBlogEntryUrl: "${createLink(controller: 'blog', action:'delete', params:[projectId:project.projectId])}",
        downloadTemplateFormUrl: "${createLink(controller: 'proxy', action: 'excelOutputTemplate')}"
        },
        here = window.location.href;

    </r:script>

    <style type="text/css">

    </style>

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
    <r:require modules="knockout,datepicker, jqueryValidationEngine, projects, attachDocuments, wmd, projectActivity, restoreTab, myActivity, map"/>
</head>
<body>

<bc:koLoading>
    <g:render template="banner"/>
    <div class="container-fluid">
        <div id="project-results-placeholder"></div>
        <g:render template="../shared/flashScopeMessage"/>

        <g:if test="${params?.version}">
            <div class="well">
                <h4>
                    Version:
                    <span id="versionMsg"></span>
                </h4>
            </div>
        </g:if>

        <div class="row-fluid">
            <!-- content  -->
            <ul id="ul-main-project" class="nav nav-pills">
                <fc:tabList tabs="${projectContent}"/>
        </div>
        <div class="pill-content">
            <fc:tabContent tabs="${projectContent}" tabClass="pill-pane"/>
        </div>
   </div>
</bc:koLoading>

<r:script>
    $(function() {
        // set project tab selection if a 'tab' parameter is set
        var projectTab = getUrlParameterValue('tab');
        if(projectTab && (typeof projectTab == 'string')){
            amplify.store('ul-main-project-state', projectTab);
        }

        $(".main-content").show();
        var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
        var project = <fc:modelAsJavascript model="${project}"/>;
        var pActivities = <fc:modelAsJavascript model="${projectActivities}"/>;
        var pActivityForms = <fc:modelAsJavascript model="${pActivityForms}"/>;
        var projectViewModel = new ProjectViewModel(project, ${user?.isEditor?:false}, organisations);
        var user = <fc:modelAsJavascript model="${user}"/>;

        var ViewModel = function() {
            var self = this;
            $.extend(this, projectViewModel);
            self.transients = self.transients || {};
            self.transients.resultsHolder = 'project-results-placeholder';
        };
        var viewModel = new ViewModel()
        viewModel.loadPrograms(<fc:modelAsJavascript model="${programs}"/>);
        ko.applyBindings(viewModel);

        var params = {};
        params.projectId = project.projectId;
        params.sites = project.sites;
        params.pActivities = pActivities;
        params.user = user;
        params.projectStartDate = project.plannedStartDate;
        params.pActivityForms = pActivityForms;
        params.organisationName = project.organisationName;
        params.project = projectViewModel;

        var pActivitiesVM = new ProjectActivitiesViewModel(params);
        initialiseProjectActivitiesList(pActivitiesVM);
        initialiseData('project');

        //Main tab selection
        new RestoreTab('ul-main-project', 'about-tab');
        if(amplify.store('traffic-from-project-finder-page')){
            amplify.store('traffic-from-project-finder-page',false)
            $('#about-tab').tab('show');
        }
        <g:if test="${projectContent.admin.visible}">
            initialiseProjectActivitiesSettings(pActivitiesVM);

            var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
            var projectStoriesViewModel = new window.projectStoriesViewModel(projectViewModel, projectStoriesMarkdown);
            ko.applyBindings(projectStoriesViewModel, $('#editprojectStoriesContent')[0]);

            var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
            var newsAndEventsViewModel = new window.newsAndEventsViewModel(projectViewModel, newsAndEventsMarkdown);
            ko.applyBindings(newsAndEventsViewModel, $('#editnewsAndEventsContent')[0]);

            populatePermissionsTable();

            initialiseInternalCSAdmin();
        </g:if>

        $('.validationEngineContainer').validationEngine();
        $('.helphover').popover({animation: true, trigger:'hover'})    });


</r:script>
</body>
</html>