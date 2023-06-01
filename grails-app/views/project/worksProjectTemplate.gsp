<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="grails.converters.JSON" %>
<g:set var="mapService" bean="mapService"></g:set>
<g:set var="utilService" bean="utilService"></g:set>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="bs4"/>
    <title>${project?.name.encodeAsHTML()} | Project | <g:message code="g.biocollect"/></title>
    <meta name="breadcrumbParent1" content="${createLink(uri: '/'+ hubConfig.urlPath)},Home"/>
    <meta name="breadcrumb" content="${project?.name}"/>
    <meta name="bannerURL" content="${utilService.getMainImageURL(project.documents)}"/>
    <meta name="bannerClass" content="project-banner"/>
    <asset:script type="text/javascript">
    var fcConfig = {
        <g:applyCodec encodeAs="none">
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        homePagePath: "${createLink(controller: 'home', action: 'index')}",
        projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
        projectUpdateUrl:"${createLink(action:'ajaxUpdate', id:project.projectId)}",
        saveMeriPlanUrl:"${createLink(action:'updateProjectPlan', id:project.projectId)}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        sitesDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSitesFromProject', id:project.projectId)}",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSiteFromProject', id:project.projectId)}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        siteEditUrl: "${createLink(controller: 'site', action: 'edit')}",
        removeSiteUrl: "${createLink(controller: 'site', action: '')}",
        activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
        activityEnterDataUrl: "${createLink(controller: 'activity', action: 'enterData')}",
        activityPrintUrl: "${createLink(controller: 'activity', action: 'print')}",
        activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
        activityDeleteUrl: "${createLink(controller: 'activity', action: 'ajaxDelete')}",
        // a hack to not add action name after activity - /activity
        activityJsonUrl: "${createLink(controller: 'activity', action: ' ')}",
        activityViewUrl: "${createLink(controller: 'activity', action: 'index')}",
        speciesPage: "${grailsApplication.config.bie.baseURL}/species/",
        searchProjectActivitiesUrl: "${raw(createLink(controller: 'bioActivity', action: 'searchProjectActivities',params: [projectId:project.projectId, version: params.version]))}",
        downloadProjectDataUrl: "${raw(createLink(controller: 'bioActivity', action: 'downloadProjectData',params: [projectId:project.projectId]))}",
        getRecordsForMapping: "${raw(createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params:[version: params.version]))}",
        siteCreateUrl: "${raw(createLink(controller: 'site', action: 'createForProject', params: [projectId:project.projectId]))}",
        siteSelectUrl: "${raw(createLink(controller: 'site', action: 'select', params:[projectId:project.projectId]))}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        siteUploadUrl: "${raw(createLink(controller: 'site', action: 'uploadShapeFile', params:[projectId:project.projectId]))}&returnTo=${createLink(controller: 'project', action: 'index', id: project.projectId)}",
        starProjectUrl: "${createLink(controller: 'project', action: 'starProject')}",
        addUserRoleUrl: "${createLink(controller: 'user', action: 'addUserAsRoleToProject')}",
        removeUserWithRoleUrl: "${createLink(controller: 'user', action: 'removeUserWithRole')}",
        projectMembersUrl: "${createLink(controller: 'project', action: 'getMembersForProjectId')}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        organisationLinkBaseUrl: "${createLink(controller: 'organisation', action: 'index')}",
        projectActivityCreateUrl: "${raw(createLink(controller: 'projectActivity', action: 'ajaxCreate', params: [projectId:project.projectId]))}",
        projectActivityUpdateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxUpdate')}",
        projectActivityDeleteUrl: "${createLink(controller: 'projectActivity', action: 'delete')}",
        projectActivityUnpublishUrl: "${createLink(controller: 'projectActivity', action: 'unpublish')}",
        addNewSpeciesListsUrl: "${raw(createLink(controller: 'projectActivity', action: 'ajaxAddNewSpeciesLists', params: [projectId:project.projectId]))}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'search', action: 'searchSpeciesList')}",
        speciesListsServerUrl: "${grailsApplication.config.lists.baseURL}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'species')}",
        imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        bieWsUrl: "${grailsApplication.config.bieWs.baseURL}",
        documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
        documentDeleteUrl: "${g.createLink(controller:"proxy", action:"deleteDocument")}",
        imageLocation:"${asset.assetPath(src:'')}",
        pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
        pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
        imgViewer: "${createLink(controller: 'resource', action: 'imageviewer')}",
        audioViewer: "${createLink(controller: 'resource', action: 'audioviewer')}",
        videoViewer: "${createLink(controller: 'resource', action: 'videoviewer')}",
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
        aekosSubmissionPostUrl: "${createLink(controller: 'projectActivity', action: 'aekosSubmission')}",
        createBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'create', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)]))}",
        editBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'edit', params:[projectId:project.projectId, returnTo:createLink(controller: 'project', action: 'index', id: project.projectId)]))}",
        deleteBlogEntryUrl: "${raw(createLink(controller: 'blog', action:'delete', params:[projectId:project.projectId]))}",
        shapefileDownloadUrl: "${createLink(controller:'project', action:'downloadShapefile', id:project.projectId)}",
        sitesPhotoPointsUrl:"${createLink(controller:'project', action:'projectSitePhotos', id:project.projectId)}",
        getMembersForProjectIdPaginatedUrl: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}",
        removeUserRoleUrl:"${createLink(controller:'user', action:'removeUserWithRoleFromProject')}",
        getProjectMembersURL: "${createLink(controller: 'project', action: 'getMembersForProjectIdPaginated')}/${project.projectId}",
        absenceIconUrl:"${asset.assetPath(src: 'triangle.png')}",
        isAdmin: ${user?.isAdmin ? 'true' : 'false'},
        isEditor: ${user?.isEditor ? 'true' : 'false'},
        isCaseManager: ${user?.isCaseManager ? 'true' : 'false'},
        canAddActivity: ${user?.isAdmin ? 'true' : 'false'},
        canAddSite: ${projectContent?.site?.canEditSites? 'true' : 'false'},
        worksScheduleIntroUrl: "${raw(createLink(controller: 'staticPage', action:'index', params: [page:"workScheduleHelp"]))}",
        outputTargetMetadata: ${((outputTargetMetadata?:[]) as grails.converters.JSON).toString()},
        activityTypes: ${raw(((activityTypes?:[]) as JSON).toString())},
        themes: ${raw(((themes?:[]) as JSON).toString())},
        sites: ${raw(((project?.sites ?: []) as JSON).toString())},
        siteIds: ${raw(((project.mapConfiguration?.sites ?: []) as JSON).toString())},
        project: ${raw(((project?: [:]) as JSON).toString())},
        commonKeysUrl: "${createLink(controller: 'search', action: 'getCommonKeys')}",
        searchBieUrl: "${raw(createLink(controller: 'project', action: 'searchSpecies', params: [id: project.projectId, limit: 10]))}",
        defaultSpeciesConfiguration: ${raw((grailsApplication.config.speciesConfiguration.default as JSON).toString())},
        intersectService: "${createLink(controller: 'proxy', action: 'intersect')}",
        featuresService: "${createLink(controller: 'proxy', action: 'features')}",
        featureService: "${createLink(controller: 'proxy', action: 'feature')}",
        spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
        layersStyle: "${createLink(controller: 'regions', action: 'layersStyle')}",
        allBaseLayers: ${grailsApplication.config.map.baseLayers as grails.converters.JSON},
        allOverlays: ${grailsApplication.config.map.overlays as grails.converters.JSON},
        mapLayersConfig: ${mapService.getMapLayersConfig(project, pActivity) as JSON},
        sitesWithDataForProject: "${createLink(controller: 'bioActivity', action: 'getSitesWithDataForProject')}",
        financeDataDisplay: ${financeDataDisplay as JSON}
        </g:applyCodec>
        },
        here = window.location.href;

    </asset:script>

    <style type="text/css">

    </style>

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
    <script src="${grailsApplication.config.google.maps.url}"></script>
    <asset:stylesheet src="projects-manifest.css"/>
    <asset:stylesheet src="project-index-manifest.css"/>
    <asset:javascript src="common-bs4.js"/>
    <asset:javascript src="project-activity-manifest.js"/>
    <asset:javascript src="projects-manifest.js"/>
    <asset:javascript src="wms.js"/>
    <asset:javascript src="mapWithFeatures.js"/>
</head>
<body>

<bc:koLoading>
    <div class="container-fluid">
        <g:render template="/shared/backToSearchResults"/>
    </div>

    <g:render template="banner"/>

    <div class="container-fluid" id="worksProjectContent">
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
   </div>

    <g:render template="/shared/markdownEditorModal"/>
</bc:koLoading>

<asset:script type="text/javascript" asset-defer="true">
        $(function () {
            // set project tab selection if a 'tab' parameter is set
            var projectTab = getUrlParameterValue('tab');
            if(projectTab && (typeof projectTab == 'string')){
                amplify.store('ul-main-project-state', projectTab);
            }

            $('.helphover').popover({animation: true, trigger:'hover'});

            var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
            var project = <fc:modelAsJavascript model="${project}"/>;
            var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
            var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
            var viewModel = new WorksProjectViewModel(project, ${user?.isEditor?:false}, organisations, {});

            viewModel.loadPrograms(<fc:modelAsJavascript model="${programs}"/>);
            var map

            ko.applyBindings(viewModel);

            // retain tab state for future re-visits
            // and handle tab-specific initialisations
            var planTabInitialised = false;

            var dashboardInitialised = false;

            $('#ul-main-project a[data-toggle="tab"]').on('show.bs.tab', function (e) {
                var tab = e.currentTarget.hash;
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

                    map = init_map_with_features({
                            mapContainer: "map",
                            scrollwheel: false,
                            featureService: "${createLink(controller: 'proxy', action:'feature')}",
                            wmsServer: "${grailsApplication.config.spatial.geoserverUrl}"
                        },
                        mapOptions
                    );
                    var mapFeatures = $.parseJSON('${mapFeatures?.encodeAsJavaScript()}');
                    var sitesViewModel = new SitesViewModel(project.sites, map, mapFeatures, ${user?.isEditor?:false}, project.projectId, project.mapConfiguration.defaultZoomArea);
                    ko.applyBindings(sitesViewModel, document.getElementById('sitesList'));
                    var tableApi = $('#sites-table').DataTable( {
                        "columnDefs": [
                        {
                            "targets": 0,
                            "orderable": false,
                            "searchable": false,
                            "width":"1.2em"
                        },
                        {
                            "targets": 1,
                            "orderable": false,
                            "searchable": false,
                            "width":"7em"
                        },
                        {
                            "targets":3,
                            "sort":4

                        },
                        {
                            "targets":4,
                            "visible":false,
                            "width":"8em"

                        }
                        ],
                        "order":[3, "desc"],
                        "language": {
                            "search": '<div class="input-group"><div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-search"></i></span></div>_INPUT_</div>',
                            "searchPlaceholder":"Search sites..."

                        },
                        "searchDelay":350
                        }
                    );

                    var visibleIndicies = function() {
                        var settings = tableApi.settings()[0];
                        var start = settings._iDisplayStart;
                        var count = settings._iDisplayLength;

                        var visibleIndicies = [];
                        for (var i=start; i<Math.min(start+count, settings.aiDisplay.length); i++) {
                            visibleIndicies.push(settings.aiDisplay[i]);
                        }
                        return visibleIndicies;
                    };
                    $('#sites-table').dataTable().on('draw.dt', function(e) {
                        sitesViewModel.sitesFiltered(visibleIndicies());
                    });
                    $('#sites-table tbody').on( 'mouseenter', 'td', function () {
                            var table = $('#sites-table').DataTable();
                            var rowIdx = table.cell(this).index().row;
                            sitesViewModel.highlightSite(rowIdx);

                        } ).on('mouseleave', 'td', function() {
                            var table = $('#sites-table').DataTable();
                            var rowIdx = table.cell(this).index().row;
                            sitesViewModel.unHighlightSite(rowIdx);
                        });
                    $('#select-all-sites').on('change',function() {
                        var checkbox = this;
                        // This lets knockout update the bindings correctly.
                        $('#sites-table tbody tr :checkbox').trigger('click');
                    });
                    sitesViewModel.sitesFiltered(visibleIndicies());

                    $('#site-photo-points a').on('click',function(e) {
                        e.preventDefault();
                        $('#site-photo-points').html('<span class="search-spinner spinner margin-left-1"> <i class="fa fa-spin fa-spinner"></i> Loading...</span>');
                        $.get(fcConfig.sitesPhotoPointsUrl).done(function(data) {

                            $('#site-photo-points').html($(data));
                            $('#site-photo-points img').on('load', function() {

                                var parent = $(this).parents('.thumb');
                                var $caption = $(parent).find('.caption');
                                $caption.outerWidth($(this).width());

                            });
                            $( '.photo-slider' ).mThumbnailScroller({theme:'hover-classic'});
                            $('.photo-slider .fancybox').fancybox({
                                helpers : {
                                    title: {
                                        type: 'inside'
                                    }
                                },
                                beforeLoad: function() {
                                    var el, id = $(this.element).data('caption');

                                    if (id) {
                                        el = $('#' + id);

                                        if (el.length) {
                                            this.title = el.html();
                                        }
                                    }
                                },
                                nextEffect:'fade',
                                previousEffect:'fade'
                            });
                            // todo: is this needed?
                            $(window).on('load',function() {

                            });
                        });
                    });
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

            // Non-editors should get tooltip and popup when trying to click other tabs
            $('#projectTabs li a').not('[data-toggle="tab"]').css('cursor', 'not-allowed') //.data('placement',"right")
            .attr('title','Only available to project members').addClass('tooltips');

            new RestoreTab('ul-main-project', 'about-tab');

            // Star button click event
            $("#starBtn").on('click',function(e) {
                var isStarred = ($("#starBtn i").attr("class") == "icon-star");
                toggleStarred(isStarred);
            });

            // BS tooltip
            $('.tooltips').tooltip();

            $('#gotoEditBlog').on('click',function () {
                amplify.store('project-admin-tab-state', '#editProjectBlog');
                $('#admin-tab').tab('show');
            });


    <g:if test="${user?.isAdmin || user?.isCaseManager}">


        // Admin JS code only exposed to admin users

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

//            var project = <fc:modelAsJavascript model="${project}"/>;
//            var viewModel = new WorksProjectViewModel(project, ${user?.isEditor?:false}, {}, {});
            var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
            var projectStoriesViewModel = new window.projectStoriesViewModel(viewModel, projectStoriesMarkdown);
            ko.cleanNode($('#editprojectStoriesContent')[0]);
            ko.applyBindings(projectStoriesViewModel, $('#editprojectStoriesContent')[0]);

            var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
            var newsAndEventsViewModel = new window.newsAndEventsViewModel(viewModel, newsAndEventsMarkdown);
            ko.cleanNode($('#editnewsAndEventsContent')[0]);
            ko.applyBindings(newsAndEventsViewModel, $('#editnewsAndEventsContent')[0]);


    </g:if>

    });// end window.load

</asset:script>
</body>
</html>
