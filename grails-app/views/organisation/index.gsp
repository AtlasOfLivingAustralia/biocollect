<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${organisation.name.encodeAsHTML()} | Field Capture</title>
    <meta name="breadcrumbParent1" content="${createLink(controller: 'project', action: 'projectFinder')},Home"/>
    <meta name="breadcrumbParent2"
          content="${createLink(controller: 'organisation', action: 'list')},Organisations"/>
    <meta name="breadcrumb" content="${organisation.name}"/>

    <g:set var="loadPermissionsUrl" value="${createLink(controller: 'organisation', action: 'getMembersForOrganisation', id:organisation.organisationId)}"/>

    <r:script disposition="head">
        var fcConfig = {
            serverUrl: "${grailsApplication.config.grails.serverURL}",
            viewProjectUrl: "${createLink(controller:'project', action:'index')}",
            updateProjectUrl: "${createLink(controller: 'project', action:'ajaxUpdate')}",
            documentUpdateUrl: '${g.createLink(controller:"proxy", action:"documentUpdate")}',
            documentDeleteUrl: '${g.createLink(controller:"proxy", action:"deleteDocument")}',
            organisationDeleteUrl: '${g.createLink(action:"ajaxDelete", id:"${organisation.organisationId}")}',
            organisationEditUrl: '${g.createLink(action:"edit", id:"${organisation.organisationId}")}',
            organisationListUrl: '${g.createLink(action:"list")}',
            organisationViewUrl: '${g.createLink(action:"index", id:"${organisation.organisationId}")}',
            organisationMembersUrl: "${loadPermissionsUrl}",
            regionListUrl: "${createLink(controller: 'regions', action: 'regionsList')}",
            featuresService: "${createLink(controller: 'proxy', action: 'features')}",
            featureService: "${createLink(controller: 'proxy', action: 'feature')}",
            imageLocation:"${resource(dir:'/images')}",
            logoLocation:"${resource(dir:'/images/filetypes')}",
            adHocReportsUrl: '${g.createLink(action:"getAdHocReportTypes")}',
            dashboardUrl: "${g.createLink(controller: 'report', action: 'loadReport', params:[fq:'organisationFacet:'+organisation.name])}",
            reportCreateUrl: '${g.createLink( action:'createAdHocReport')}',
            submitReportUrl: '${g.createLink( action:'ajaxSubmitReport', id:"${organisation.organisationId}")}',
            approveReportUrl: '${g.createLink( action:'ajaxApproveReport', id:"${organisation.organisationId}")}',
            spatialService: '${createLink(controller:'proxy',action:'feature')}',
            spatialWms: "${grailsApplication.config.spatial.geoserverUrl}",
            spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
            rejectReportUrl: '${g.createLink( action:'ajaxRejectReport', id:"${organisation.organisationId}")}',
            defaultSearchRadiusMetersForPoint: "${grailsApplication.config.defaultSearchRadiusMetersForPoint ?: "100km"}",
            returnTo: '${g.createLink(action:'index', id:"${organisation.organisationId}")}',
            projects : <fc:modelAsJavascript model="${organisation.projects}"/>,
            projectListUrl: "${createLink(controller: 'project', action: 'search',params:[initiator:'biocollect'])}",
            projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
            organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
            organisation : <fc:modelAsJavascript model="${organisation}"/>,
            organisationName : "${organisation.name}",
            showAllProjects: true,
            meritProjectLogo:"${resource(dir:'/images', file:'merit_project_logo.jpg')}",
            meritProjectUrl: "${grailsApplication.config.merit.project.url}",

            searchProjectActivitiesUrl: "${createLink(controller: 'bioActivity', action: 'searchProjectActivities')}",
            projectLinkPrefix: "${createLink(controller: 'project')}/",
            bieUrl: "${grailsApplication.config.bie.baseURL}",
            siteViewUrl: "${createLink(controller: 'site', action: 'index')}",
            projectIndexUrl: "${createLink(controller: 'project', action: 'index')}",
            getRecordsForMapping: "${createLink(controller: 'bioActivity', action: 'getProjectActivitiesRecordsForMapping', params:[version: params.version])}",
            downloadProjectDataUrl: "${createLink(controller: 'bioActivity', action: 'downloadProjectData')}",
            activityUpdateUrl: "${createLink(controller: 'activity', action: 'ajaxUpdate')}",
            activityViewUrl: "${createLink(controller: 'bioActivity', action: 'index')}",
            activityEditUrl: "${createLink(controller: 'bioActivity', action: 'edit')}",
            activityDeleteUrl: "${createLink(controller: 'bioActivity', action: 'delete')}",
            activityAddUrl: "${createLink(controller: 'bioActivity', action: 'create')}",
            activityListUrl: "${createLink(controller: 'bioActivity', action: 'ajaxList')}",
            recordImageListUrl: '${createLink(controller: "project", action: "listRecordImages")}',
            imageLeafletViewer: '${createLink(controller: 'resource', action: 'imageviewer', absolute: true)}',
            organisationName: '${organisation.name}',
            version: "${params.version?:''}",
            hideWorldWideBtn: true,
            flimit: ${grailsApplication.config.facets.flimit},
            occurrenceUrl: "",
            spatialUrl: "",
            absenceIconUrl:"${resource(dir: 'images', file: 'triangle.png')}"
        };
    </r:script>
    <style type="text/css">
        #projectList th {
            white-space: normal;
        }
        .admin-action {
            width:7em;
        }
        .smallFont {
            margin: 5px 0;
        }
    </style>
    <r:require modules="wmd,knockout,amplify,organisation,projects,jquery_bootstrap_datatable,datepicker,jqueryValidationEngine,slickgrid,projectFinder,map,siteDisplaysiteDispl,myActivity, activities"/>
</head>
<body>

    <g:render template="banner" model="${[imageUrl:resource(dir:'/images/filetypes')]}"/>

    <div id="organisationDetails" class="container-fluid">

        <g:render template="/shared/flashScopeMessage"/>

        <div class="row-fluid">
            <ul class="nav nav-tabs" data-tabs="tabs">
                <fc:tabList tabs="${content}"/>
            </ul>

            <div class="tab-content">
                <fc:tabContent tabs="${content}"/>
            </div>
        </div>
        <div id="loading" class="text-center">
            <r:img width="50px" dir="images" file="loading.gif" alt="loading icon"/>
        </div>
    </div>

<g:render template="/shared/declaration"/>

<r:script>

    $(function () {

        var organisation =<fc:modelAsJavascript model="${organisation}"/>;
        var organisationViewModel = new OrganisationViewModel(organisation);

        ko.applyBindings(organisationViewModel);
        $('#loading').hide();

        var SELECTED_REPORT_KEY = 'selectedOrganisationReport';
        var selectedReport = amplify.store(SELECTED_REPORT_KEY);
        var $dashboardType = $('#dashboardType');
        // This check is to prevent errors when a particular organisation is missing a report or the user
        // permission set if different when viewing different organisations.
        if (!$dashboardType.find('option[value='+selectedReport+']')[0]) {
           selectedReport = 'dashboard';
        }
        $dashboardType.val(selectedReport);
        $dashboardType.change(function(e) {
            var $content = $('#dashboard-content');
            var $loading = $('.loading-message');
            $content.hide();
            $loading.show();

            var reportType = $dashboardType.val();

            $.get(fcConfig.dashboardUrl, {report:reportType}).done(function(data) {
                $content.html(data);
                $loading.hide();
                $content.show();
                $('#dashboard-content .helphover').popover({animation: true, trigger:'hover', container:'body'});
                amplify.store(SELECTED_REPORT_KEY, reportType);
            });

        }).trigger('change');

        var organisationTabStorageKey = 'organisation-page-tab';
        var initialisedSites = false;
        $('a[data-toggle="tab"]').on('shown', function (e) {
            var tab = e.currentTarget.hash;
            amplify.store(organisationTabStorageKey, tab);
            if (!initialisedSites && tab == '#sites') {
                generateMap(['organisationFacet:'+organisation.name]);
                initialisedSites = true;
            }
        });

        var storedTab = amplify.store(organisationTabStorageKey);

        if (storedTab) {
            $(storedTab + '-tab').tab('show');
        }
        <g:if test="${content.admin.visible}">
        populatePermissionsTable(fcConfig.organisationMembersUrl);
        </g:if>

        initialiseData("allrecords");
    });
    $(function() {
        var projectFinder = new ProjectFinder();
    });
</r:script>

</body>


</html>