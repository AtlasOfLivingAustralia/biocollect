<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${project?.name.encodeAsHTML()} | Project | Field Capture</title>
    <r:script disposition="head">
    var fcConfig = {
        serverUrl: "${grailsApplication.config.grails.serverURL}",
        projectUpdateUrl:"${createLink(action:'ajaxUpdate', id:project.projectId)}",
        projectEditUrl:"${createLink(action:'edit', id:project.projectId)}",
        sitesDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSitesFromProject', id:project.projectId)}",
        siteDeleteUrl: "${createLink(controller: 'site', action: 'ajaxDeleteSiteFromProject', id:project.projectId)}",
        siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
        siteEditUrl: "${createLink(controller: 'site', action: 'edit')}",
        removeSiteUrl: "${createLink(controller: 'site', action: '')}",
        activityEditUrl: "${createLink(controller: 'activity', action: 'edit')}",
        activityEnterDataUrl: "${createLink(controller: 'activity', action: 'enterData')}",
        activityPrintUrl: "${createLink(controller: 'activity', action: 'print')}",
        activityCreateUrl: "${createLink(controller: 'activity', action: 'createPlan')}",
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
        projectActivityCreateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxCreate', params: [projectId:project.projectId])}",
        projectActivityUpdateUrl: "${createLink(controller: 'projectActivity', action: 'ajaxUpdate', params: [projectId:project.projectId])}",
        addNewSpeciesListsUrl: "${createLink(controller: 'projectActivity', action: 'ajaxAddNewSpeciesLists', params: [projectId:project.projectId])}",
        speciesProfileUrl: "${createLink(controller: 'proxy', action: 'speciesProfile')}",
        speciesListUrl: "${createLink(controller: 'search', action: 'searchSpeciesList')}",
        speciesListsServerUrl: "${grailsApplication.config.lists.baseURL}",
        speciesSearchUrl: "${createLink(controller: 'search', action: 'species')}",
        imageUploadUrl: "${createLink(controller: 'image', action: 'upload')}",
        bioActiviyCreateUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
        bieUrl: "${grailsApplication.config.bie.baseURL}",
        documentUpdateUrl: "${createLink(controller:"proxy", action:"documentUpdate")}",
        imageLocation:"${resource(dir:'/images')}",
        pdfgenUrl: "${createLink(controller: 'resource', action: 'pdfUrl')}",
        pdfViewer: "${createLink(controller: 'resource', action: 'viewer')}",
        imgViewer: "${createLink(controller: 'resource', action: 'imageviewer')}",
        audioViewer: "${createLink(controller: 'resource', action: 'audioviewer')}",
        videoViewer: "${createLink(controller: 'resource', action: 'videoviewer')}",
        ßerrorViewer: "${createLink(controller: 'resource', action: 'error')}",
        returnTo: "${createLink(controller: 'project', action: 'index', id: project.projectId)}"
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
    <r:require modules="gmap3,mapWithFeatures,knockout,datepicker, jqueryValidationEngine, projects, attachDocuments, wmd, sliderpro, projectActivity, restoreTab"/>
</head>
<body>

<g:render template="banner"/>
<div class="container-fluid">
    <div class="row-fluid">
        <div class="row-fluid">
            <div class="clearfix">
                <g:if test="${flash.errorMessage || flash.message}">
                    <div class="span5">
                        <div class="alert alert-error">
                            <button class="close" onclick="$('.alert').fadeOut();" href="#">×</button>
                            ${flash.errorMessage?:flash.message}
                        </div>
                    </div>
                </g:if>

            </div>
        </div>
    </div>
    <div class="row-fluid">
        <!-- content  -->
        <ul id="ul-main-project" class="nav nav-pills">
        <fc:tabList tabs="${projectContent}"/>
    </div>
    <div class="pill-content">
        <fc:tabContent tabs="${projectContent}" tabClass="pill-pane"/>

    </div>

</div>
<r:script>
    $(function() {

        var organisations = <fc:modelAsJavascript model="${organisations?:[]}"/>;
        var project = <fc:modelAsJavascript model="${project}"/>;
        var pActivities = <fc:modelAsJavascript model="${projectActivities}"/>;
        var pActivityForms = <fc:modelAsJavascript model="${pActivityForms}"/>;
        var projectViewModel = new ProjectViewModel(project, ${user?.isEditor?:false}, organisations);
        var user = <fc:modelAsJavascript model="${user}"/>;

        var ViewModel = function() {
            var self = this;
            $.extend(this, projectViewModel);

            self.editProject = function() {
                window.location.href = fcConfig.projectEditUrl;
            };
            self.deleteProject = function() {
                var message = "<span class='label label-important'>Important</span><p><b>This cannot be undone</b></p><p>Are you sure you want to delete this project?</p>";
                bootbox.confirm(message, function(result) {
                    if (result) {
                        console.log("not implemented!");
                    }
                });
            };

        };
        ko.applyBindings(new ViewModel());

        if (projectViewModel.mainImageUrl()) {
            $( '#carousel' ).sliderPro({
                width: '100%',
                height: 'auto',
                autoHeight: true,
                arrows: false, // at the moment we only support 1 image
                buttons: false,
                waitForLayers: true,
                fade: true,
                autoplay: false,
                autoScaleLayers: false,
                touchSwipe:false // at the moment we only support 1 image
            });
        }

        initialiseProjectArea();
        var pActivitiesVM = new ProjectActivitiesViewModel(pActivities, pActivityForms, project.projectId, project.sites, user);
        initialiseProjectActivitiesList(pActivitiesVM);
        initialiseProjectActivitiesData(pActivitiesVM);

        //Main tab selection
        new RestoreTab('ul-main-project', 'about-tab');

        <g:if test="${projectContent.admin.visible}">
            initialiseProjectActivitiesSettings(pActivitiesVM);

            var projectStoriesMarkdown = '${(project.projectStories?:"").markdownToHtml().encodeAsJavaScript()}';
            var projectStoriesViewModel = new window.projectStoriesViewModel(projectViewModel, projectStoriesMarkdown);
            ko.applyBindings(projectStoriesViewModel, $('#editprojectStoriesContent')[0]);

            var newsAndEventsMarkdown = '${(project.newsAndEvents?:"").markdownToHtml().encodeAsJavaScript()}';
            var newsAndEventsViewModel = new window.newsAndEventsViewModel(projectViewModel, newsAndEventsMarkdown);
            ko.applyBindings(newsAndEventsViewModel, $('#editnewsAndEventsContent')[0]);

            populatePermissionsTable();

            //Citizen- Science admin
            new RestoreTab('ul-project-admin-citizen-science', 'project-settings-tab');
            new RestoreTab('ul-survey-constraint-citizen-science', 'survey-info-tab');
        </g:if>

        $('.validationEngineContainer').validationEngine();
        $('.helphover').popover({animation: true, trigger:'hover'})    });



</r:script>
</body>
</html>