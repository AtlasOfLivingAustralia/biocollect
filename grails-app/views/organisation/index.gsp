<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title>${organisation.name.encodeAsHTML()} | Field Capture</title>
    <script type="text/javascript" src="${grailsApplication.config.google.maps.url}"></script>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
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
            imageLocation:"${resource(dir:'/images')}",
            logoLocation:"${resource(dir:'/images/filetypes')}",
            adHocReportsUrl: '${g.createLink(action:"getAdHocReportTypes")}',
            dashboardUrl: "${g.createLink(controller: 'report', action: 'loadReport', params:[fq:'organisationFacet:'+organisation.name])}",
            activityViewUrl: '${g.createLink(controller: 'activity', action:'index')}',
            activityEditUrl: '${g.createLink(controller: 'activity', action:'enterData')}',
            reportCreateUrl: '${g.createLink( action:'createAdHocReport')}',
            submitReportUrl: '${g.createLink( action:'ajaxSubmitReport', id:"${organisation.organisationId}")}',
            approveReportUrl: '${g.createLink( action:'ajaxApproveReport', id:"${organisation.organisationId}")}',
            rejectReportUrl: '${g.createLink( action:'ajaxRejectReport', id:"${organisation.organisationId}")}',
            returnTo: '${g.createLink(action:'index', id:"${organisation.organisationId}")}',
            projects : <fc:modelAsJavascript model="${organisation.projects}"/>,
            projectListUrl: "${createLink(controller: 'project', action: 'getProjectList')}",
            projectIndexBaseUrl : "${createLink(controller:'project',action:'index')}/",
            organisationBaseUrl : "${createLink(controller:'organisation',action:'index')}/",
            organisation : <fc:modelAsJavascript model="${organisation}"/>,
            organisationName : "${organisation.name}",
            isOrganisationPage: true
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
    <r:require modules="wmd,knockout,mapWithFeatures,amplify,organisation,projects,jquery_bootstrap_datatable,datepicker,jqueryValidationEngine,slickgrid,sliderpro,projectFinder"/>
</head>
<body>

    <g:render template="banner" model="${[imageUrl:resource(dir:'/images/filetypes')]}"/>

    <div id="organisationDetails" class="container-fluid" style="display:none;">

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
        $('#organisationDetails').show({complete:function() {
            if (organisationViewModel.mainImageUrl()) {
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
        }});

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
            if (!initialisedSites && tab == '#sites') { // Google maps doesn't initialise well unless it is visible.
                generateMap(['organisationFacet:'+organisation.name], false, {includeLegend:false});
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
    });

</r:script>

</body>


</html>