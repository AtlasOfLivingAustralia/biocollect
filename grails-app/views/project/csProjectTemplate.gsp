<%@ page contentType="text/html;charset=UTF-8" import="grails.converters.JSON;"%>
<g:set var="mapService" bean="mapService"></g:set>
<g:set var="utilService" bean="utilService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${mobile ? 'mobile' : 'bs4'}"/>
    <title>${project?.name.encodeAsHTML()} | Project | BioCollect</title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/')},Home"/>
    <meta name="breadcrumb" content="${project?.name}"/>
    <meta name="bannerURL" content="${utilService.getMainImageURL(project.documents)}"/>
    <meta name="bannerClass" content="project-banner"/>
%{--    <meta name="logo" content="${utilService.getLogoURL(project.documents)}"/>--}%
    <asset:stylesheet src="project-index-manifest.css"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
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
        activityListUrl : "${raw(createLink(controller: 'bioActivity', action: 'ajaxListForProject', params: [id:project.projectId]))}",
        activiyCountUrl: "${createLink(controller: 'bioActivity', action: 'getProjectActivityCount')}",
        sitesWithDataForProjectActivity: "${createLink(controller: 'bioActivity', action: 'getSitesWithDataForProjectActivity')}",
        speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
        searchProjectActivitiesUrl: "${raw(createLink(controller: 'bioActivity', action: 'searchProjectActivities',params: [projectId:project.projectId, version: params.version]))}",
        downloadProjectDataUrl: "${raw(createLink(controller: 'bioActivity', action: 'downloadProjectData',params: [projectId:project.projectId]))}",
        getRecordsForMapping: "${raw(createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params:[version: params.version]))}",
        siteCreateUrl: "${raw(createLink(controller: 'site', action: 'createForProject', params: [projectId:project.projectId]))}",
        siteSelectUrl: "${raw(createLink(controller: 'site', action: 'select', params:[projectId:project.projectId]))}&returnTo=${raw(createLink(controller: 'project', action: 'index', id: project.projectId))}",
        siteUploadUrl: "${raw(createLink(controller: 'site', action: 'uploadShapeFile', params:[projectId:project.projectId]))}&returnTo=${raw(createLink(controller: 'project', action: 'index', id: project.projectId))}",
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
        projectActivityCreateUrl: "${raw(createLink(controller: 'projectActivity', action: 'ajaxCreate', params: [projectId:project.projectId]))}",
        projectActivityUpdateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxUpdate')}",
        projectActivityGetUrl: "${createLink(controller: 'projectActivity', action: 'ajaxGet')}",
        projectActivityDeleteUrl: "${createLink(controller: 'projectActivity', action: 'delete')}",
        projectActivityUnpublishUrl: "${createLink(controller: 'projectActivity', action: 'unpublish')}",
        deleteAllDataForProjectActivityUrl: "${createLink(controller: 'projectActivity', action: 'deleteAllDataForProjectActivity')}",
        addNewSpeciesListsUrl: "${raw(createLink(controller: 'projectActivity', action: 'ajaxAddNewSpeciesLists', params: [projectId:project.projectId]))}",
        getSpeciesFieldsForSurveyUrl: "${createLink(controller: 'projectActivity', action: 'ajaxGetSpeciesFieldsForSurvey')}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'search', action: 'searchSpeciesList')}",
        speciesListsServerUrl: "${grailsApplication.config.lists.baseURL}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'species')}",
        searchBieUrl: "${raw(createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10]))}",
        imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
        methoddocumentUpdateUrl: "${raw(createLink(controller:"image", action:"upload", params:[role: "methodDoc"]))}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        imageLocation:"${asset.assetPath(src:'')}",
        documentSearchUrl: "${createLink(controller: 'document', action: 'allDocumentsSearch')}",
        pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
        pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
        imgViewer: "${createLink(controller: 'resource', action: 'imageviewer')}",
        audioViewer: "${createLink(controller: 'resource', action: 'audioviewer')}",
        videoViewer: "${createLink(controller: 'resource', action: 'videoviewer')}",
        list: "${createLink(controller: 'resource', action: 'list')}",
        recordListUrl: "${raw(createLink(controller: 'record', action: 'ajaxListForProject', params: [id:project.projectId]))}",
        recordDeleteUrl:"${createLink(controller: 'record', action: 'delete')}",
        projectDeleteUrl:"${createLink(action:'delete', id:project.projectId)}",
        errorViewer: "${createLink(controller: 'resource', action: 'error')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        auditMessageUrl: "${raw(createLink( controller: 'project', action:'auditMessageDetails', params:[projectId: project.projectId]))}",
        projectId: "${project.projectId}",
        projectLinkPrefix: "${createLink(controller: 'project')}/",
        recordImageListUrl: '${raw(createLink(controller: "project", action: "listRecordImages", params:[version: params.version]))}',
        view: 'project',
        imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
        version: "${params.version}",
        aekosSubmissionUrl: "${createLink(controller: 'bioActivity', action: 'aekosSubmission')}",
        createBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'create', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)]))}",
        editBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'edit', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)]))}",
        deleteBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'delete', params:[projectId:project.projectId]))}",
        downloadTemplateFormUrl: "${createLink(controller: 'proxy', action: 'excelOutputTemplate')}",
        flimit: ${grailsApplication.config.facets.flimit},
        commonKeysUrl: "${createLink(controller: 'search', action: 'getCommonKeys')}",
        defaultCommonFields: <fc:modelAsJavascript model="${grailsApplication.config.lists.commonFields}"/>,
        occurrenceUrl: "${raw(occurrenceUrl)}",
        spatialUrl: "${spatialUrl}",
        getMembersForProjectIdPaginatedUrl: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}",
        getProjectMembersURL: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}/${project.projectId}",
        removeUserRoleUrl:"${createLink(controller:'user', action:'removeUserWithRoleFromProject')}",
        absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}",
        projectNotificationUrl: "${raw(createLink(controller: 'project', action: 'sendEmailToMembers', params: [id: project.projectId]))}",
        projectTestNotificationUrl: "${raw(createLink(controller: 'project', action: 'sendTestEmail', params: [id: project.projectId]))}",
        opportunisticDisplayName: "<g:message code="facets.methodType.opportunistic"/>",
        mapLayersConfig: ${mapService.getMapLayersConfig(project, null) as JSON},
        allBaseLayers: ${grailsApplication.config.map.baseLayers as grails.converters.JSON},
        allOverlays: ${grailsApplication.config.map.overlays as grails.converters.JSON},
        surveyMethods: <fc:getSurveyMethods/>
        </g:applyCodec>
        },
        here = window.location.href;

    </asset:script>
%{--    todo delete? --}%
%{--    <!--[if gte IE 8]>--}%
%{--        <style>--}%
%{--           .thumbnail > img {--}%
%{--                max-width: 400px;--}%
%{--            }--}%
%{--            .thumbnail {--}%
%{--                max-width: 410px;--}%
%{--            }--}%
%{--        </style>--}%
%{--    <![endif]-->--}%
%{--    <asset:stylesheet src="projects-manifest.css"/>--}%
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="project-activity-manifest.js"/>
    <asset:javascript src="projects-manifest.js"/>
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>
<body>

<bc:koLoading>
    <div class="container-fluid">
        <g:render template="/shared/backToSearchResults"/>
    </div>

    <g:render template="banner"/>

    <div class="container-fluid" id="csProjectContent">
        <div id="project-results-placeholder"></div>
        <g:render template="/shared/flashScopeMessage"/>

        <g:if test="${params?.version}">
            <div>
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
            <content tag="tab">
                <ul class="nav nav-tabs" id="ul-main-project" data-tabs="tabs" role="tablist">
                    <fc:tabList tabs="${projectContent}"/>
                </ul>
            </content>
            <div class="row" id="heading">
                <div class="col-12">
                    <div class="tab-content">
                        <fc:tabContent tabs="${projectContent}"/>
                    </div>
                </div>
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

        <g:if test="${(fc.userIsAlaOrFcAdmin() || projectContent.admin.visible) && !project.isExternal}">
            projectViewModel.showBushfireBanner()
        </g:if>
    });
</asset:script>
</body>
</html>