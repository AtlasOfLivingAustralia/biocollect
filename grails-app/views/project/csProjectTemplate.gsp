<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${mobile ? 'mobile' : hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'homePage')},Home"/>
    <meta name="breadcrumb" content="${project?.name}"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400italic,600,700"/>
    <link rel="stylesheet" src="https://fonts.googleapis.com/css?family=Oswald:300"/>
    <asset:stylesheet src="forms-manifest.css"/>
    <asset:stylesheet src="projects.css"/>
    <asset:script type="text/javascript">
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
        activityBulkDeleteUrl: "${createLink(controller: 'bioActivity', action: 'bulkDelete')}",
        activityBulkEmbargoUrl: "${createLink(controller: 'bioActivity', action: 'bulkEmbargo')}",
        activityBulkReleaseUrl: "${createLink(controller: 'bioActivity', action: 'bulkRelease')}",
        activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
        activityCreateUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
        activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
        activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
        activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
        activityListUrl : "${createLink(controller: 'bioActivity', action: 'ajaxListForProject', params: [id:project.projectId])}",
        activiyCountUrl: "${createLink(controller: 'bioActivity', action: 'getProjectActivityCount')}",
        sitesWithDataForProjectActivity: "${createLink(controller: 'bioActivity', action: 'getSitesWithDataForProjectActivity')}",
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
        wmsFeaturesUrl: "${createLink(controller: 'proxy', action: 'feature')}?featureId=", //"http://devt.ala.org.au:8087/biocollect/proxy/feature?featureId=",
        wmsLayerUrl: "${grailsApplication.config.spatial.geoserverUrl}/wms/reflect?",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        projectActivityCreateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxCreate', params: [projectId:project.projectId])}",
        projectActivityUpdateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxUpdate')}",
        projectActivityGetUrl: "${createLink(controller: 'projectActivity', action: 'ajaxGet')}",
        projectActivityDeleteUrl: "${createLink(controller: 'projectActivity', action: 'delete')}",
        projectActivityUnpublishUrl: "${createLink(controller: 'projectActivity', action: 'unpublish')}",
        deleteAllDataForProjectActivityUrl: "${createLink(controller: 'projectActivity', action: 'deleteAllDataForProjectActivity')}",
        addNewSpeciesListsUrl: "${createLink(controller: 'projectActivity', action: 'ajaxAddNewSpeciesLists', params: [projectId:project.projectId])}",
        getSpeciesFieldsForSurveyUrl: "${createLink(controller: 'projectActivity', action: 'ajaxGetSpeciesFieldsForSurvey')}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'search', action: 'searchSpeciesList')}",
        speciesListsServerUrl: "${grailsApplication.config.lists.baseURL}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'species')}",
        searchBieUrl: "${createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10])}",
        imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
        methoddocumentUpdateUrl: "${createLink(controller:"image", action:"upload", params:[role: "methodDoc"])}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        imageLocation:"${asset.assetPath(src:'')}",
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
        aekosSubmissionUrl: "${createLink(controller: 'bioActivity', action: 'aekosSubmission')}",
        createBlogEntryUrl: "${createLink(controller: 'blog', action:'create', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}",
        editBlogEntryUrl: "${createLink(controller: 'blog', action:'edit', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)])}",
        deleteBlogEntryUrl: "${createLink(controller: 'blog', action:'delete', params:[projectId:project.projectId])}",
        downloadTemplateFormUrl: "${createLink(controller: 'proxy', action: 'excelOutputTemplate')}",
        flimit: ${grailsApplication.config.facets.flimit},
        commonKeysUrl: "${createLink(controller: 'search', action: 'getCommonKeys')}",
        defaultCommonFields: <fc:modelAsJavascript model="${grailsApplication.config.lists.commonFields}"/>,
        occurrenceUrl: "${occurrenceUrl}",
        spatialUrl: "${spatialUrl}",
        getMembersForProjectIdPaginatedUrl: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}",
        getProjectMembersURL: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}/${project.projectId}",
        removeUserRoleUrl:"${createLink(controller:'user', action:'removeUserWithRoleFromProject')}",
        absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}",
        projectNotificationUrl: "${createLink(controller: 'project', action: 'sendEmailToMembers', params: [id: project.projectId])}",
        projectTestNotificationUrl: "${createLink(controller: 'project', action: 'sendTestEmail', params: [id: project.projectId])}",
        opportunisticDisplayName: "<g:message code="facets.methodType.opportunistic"/>",
        surveyMethods: <fc:getSurveyMethods/>
        },
        here = window.location.href;

    </asset:script>

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
    <asset:stylesheet src="projects-manifest.css"/>
    <asset:javascript src="common.js"/>
    <asset:javascript src="project-activity-manifest.js"/>
    <asset:javascript src="projects-manifest.js"/>
</head>
<body>

<bc:koLoading>
    <g:render template="/shared/backToSearchResults"/>
    <g:if test="${!mobile}">
        <g:render template="banner"/>
    </g:if>

    <div class="container-fluid">
        <div id="project-results-placeholder"></div>
        <g:render template="/shared/flashScopeMessage"/>

        <g:if test="${params?.version}">
            <div class="well">
                <h4>
                    Version:
                    <span id="versionMsg"></span>
                </h4>
            </div>
        </g:if>

        <g:if test="${mobile}">
            <g:render template="/project/mobile"/>
        </g:if>
        <g:else>
            <div class="row-fluid">
                <!-- content  -->
                <ul id="ul-main-project" class="nav nav-pills">
                    <fc:tabList tabs="${projectContent}"/>
            </div>
            <div class="pill-content">
                <fc:tabContent tabs="${projectContent}" tabClass="pill-pane"/>
            </div>
        </g:else>

   </div>
</bc:koLoading>

<asset:script type="text/javascript">
    $(function() {
        // set project tab selection if a 'tab' parameter is set
        var projectTab = getUrlParameterValue('tab');
        if(projectTab && (typeof projectTab == 'string')){
            amplify.store('ul-main-project-state', projectTab);
        }

        $(".main-content").show();
        var project = <fc:modelAsJavascript model="${project}"/>;
        var pActivities = <fc:modelAsJavascript model="${projectActivities}"/>;
        var pActivityForms = <fc:modelAsJavascript model="${pActivityForms}"/>;
        var projectViewModel = new ProjectViewModel(project, ${user?.isEditor?:false});
        var user = <fc:modelAsJavascript model="${user}"/>;
        var vocabList = <fc:modelAsJavascript model="${vocabList}" />;
        var projectArea = <fc:modelAsJavascript model="${projectSite?.extent?.geometry}"/>;
        var licences = <fc:modelAsJavascript model="${licences}"/>;

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
        params.vocabList = vocabList;
        params.projectArea = projectArea;
        params.licences = licences;

        <g:if test="${!project.isExternal}">
            var pActivitiesVM = new ProjectActivitiesViewModel(params, projectViewModel);
            initialiseProjectActivitiesList(pActivitiesVM);
            initialiseData('project');
            <g:if test="${projectContent.admin.visible}">initialiseProjectActivitiesSettings(pActivitiesVM);</g:if>
        </g:if>
        <g:if test="${projectContent.admin.visible}">
            <g:if test="${!project.isExternal}">
                var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
                var projectStoriesViewModel = new window.projectStoriesViewModel(projectViewModel, projectStoriesMarkdown);
                ko.applyBindings(projectStoriesViewModel, $('#editprojectStoriesContent')[0]);

                var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
                var newsAndEventsViewModel = new window.newsAndEventsViewModel(projectViewModel, newsAndEventsMarkdown);
                ko.applyBindings(newsAndEventsViewModel, $('#editnewsAndEventsContent')[0]);
            </g:if>

            initialiseInternalCSAdmin();
        </g:if>


        $('.validationEngineContainer').validationEngine({promptPosition: 'topLeft'});
        $('.helphover').popover({animation: true, trigger:'hover'})

        //Main tab selection
        new RestoreTab('ul-main-project', 'about-tab');
        if(amplify.store('traffic-from-project-finder-page')) {
            amplify.store('traffic-from-project-finder-page',false)
            $('#about-tab').tab('show');
        }
    });
</asset:script>
</body>
</html>