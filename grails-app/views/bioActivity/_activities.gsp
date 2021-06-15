<%@ page import="grails.converters.JSON" %>
<g:set var="noImageUrl" value="${asset.assetPath([src: "no-image-2.png"])}"/>
<g:render template="/shared/legend"/>
<!-- ko stopBinding: true -->
<div id="survey-all-activities-and-records-content">
    <div id="data-result-placeholder"></div>
    <div data-bind="visible: version().length == 0">
        <g:render template="/bioActivity/search"/>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="span3 text-left">

                <div class="well">
                    <g:render template="/shared/simpleFacetsFilterView"></g:render>
                </div>

            </div>
            <div class="span9 text-left well activities-search-panel">
                <g:if test="${hubConfig.content?.showNote}">
                    <div class="alert alert-info">
                        <strong>Note!</strong> ${hubConfig.content?.recordNote?.encodeAsHTML()}
                    </div>
                </g:if>
                <g:if test="${isProjectContributingDataToALA}">
                    <div class="row-fluid margin-bottom-1">
                        <div class="span12">
                            <a class="btn btn-ala" data-bind="attr:{href: biocacheUrl}">
                                View records in occurrence explorer
                            </a>
                            <a class="btn btn-ala" data-bind="attr:{href: spatialUrl}">
                                View records in spatial portal
                            </a>
                        </div>
                    </div>
                </g:if>
                <ul class="nav nav-tabs" id="tabDifferentViews">
                    <li class="active"><a id="recordVis-tab" href="#recordVis" data-toggle="tab" >List</a></li>
                    <li class=""><a href="#mapVis" id="dataMapTab" data-bind="attr:{'data-toggle': activities().length > 0 ? 'tab' : ''}">Map</a></li>
                    <li class=""><a id="dataImageTab" href="#imageGallery" data-toggle="tab">Images</a></li>
                    <li class=""><a id="chartGraphTab" href="#chartGraph" data-toggle="tab">Graphs</a></li>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="recordVis">
                        <!-- ko if: activities().length == 0 -->
                            <div class="row-fluid">
                                <h3 class="text-left margin-bottom-five">
                                    <span data-bind="if: $root.searchTerm() == '' && $root.filterViewModel.selectedFacets().length == 0 && !$root.transients.loading()">
                                        No data has been recorded for this project yet
                                    </span>
                                    <span data-bind="if: $root.searchTerm() != '' || $root.filterViewModel.selectedFacets().length > 0 && !$root.transients.loading()">No results</span>
                                </h3>
                            </div>
                        <!-- /ko -->

                            <!-- ko if: activities().length > 0 -->

                            <div class="alert alert-info hide" id="downloadStartedMsg"><i class="fa fa-spin fa-spinner">&nbsp;&nbsp;</i>Preparing download, please wait...</div>

                            <div class="row-fluid" data-bind="visible: version().length == 0">
                                <div class="span12">
                                    <h3 class="text-left margin-bottom-2">Found <span data-bind="text: total()"></span> record(s)</h3>
                                    <div class="pull-right margin-bottom-2 margin-top-1">
                                        <!-- ko if:  transients.isBulkActionsEnabled -->
                                        <span>Bulk actions -
                                            <div class="btn-group">
                                                <button data-bind="disable: !transients.activitiesToDelete().length, click: bulkDelete" class="btn btn-default"><span class="fa fa-trash">&nbsp;</span> <g:message code="project.bulkactions.delete"/></button>
                                                <button data-bind="disable: !transients.activitiesToDelete().length, click: bulkEmbargo" class="btn btn-default"><span class="fa fa-lock">&nbsp;</span> <g:message code="project.bulkactions.embargo"/></button>
                                                <button data-bind="disable: !transients.activitiesToDelete().length, click: bulkRelease" class="btn btn-default"><span class="fa fa-unlock">&nbsp;</span> <g:message code="project.bulkactions.release"/></button>
                                            </div>
                                        </span>
                                        <!-- /ko -->
                                        <button data-bind="click: download, disable: transients.loading" data-email-threshold="${grailsApplication.config.download.email.threshold ?: 200}" class="btn btn-primary padding-top-1"><span class="fa fa-download">&nbsp;</span>Download</button>
                                    </div>

                                </div>
                            </div>
                        <div class="row-fluid" data-bind="visible: transients.showEmailDownloadPrompt()">
                                <div class="well info-panel">
                                    <div class="margin-bottom-2">
                                        <span class="fa fa-info-circle">&nbsp;&nbsp;</span>This download may take several minutes. Please provide your email address, and we will notify you by email when the download is ready.
                                    </div>

                                    <div class="clearfix control-group">
                                        <label class="control-label span2" for="email">Email address</label>

                                        <div class="controls span10">
                                            <g:textField class="input-xxlarge" type="email" data-bind="value: transients.downloadEmail" name="email"/>
                                        </div>
                                    </div>

                                    <button data-bind="click: asyncDownload" class="btn btn-primary padding-top-1"><span class="fa fa-download">&nbsp;</span>Download</button>
                                </div>
                            </div>

                            <g:render template="/shared/pagination"/>
                            <table class="full-width table table-hover">
                                <thead>
                                    <tr>
                                        <!-- ko foreach : columnConfig -->
                                        <!-- ko if:  type != 'checkbox' -->
                                        <th>
                                            <!-- ko if: isSortable -->
                                            <div class="pointer" data-bind="click: $parent.sortByColumn">
                                                <!-- ko text: displayName --> <!-- /ko -->
                                                <span data-bind="css: $parent.sortClass($data)"></span>
                                            </div>

                                            <!-- /ko -->
                                            <!-- ko ifnot: isSortable -->
                                            <!-- ko text: displayName --><!-- /ko -->
                                            <!-- /ko -->
                                        </th>
                                        <!-- /ko -->
                                        <!-- ko if:  type == 'checkbox' -->
                                        <th data-bind="visible: $parent.transients.isBulkActionsEnabled, text: displayName">
                                        </th>
                                        <!-- /ko -->
                                        <!-- /ko -->
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- ko foreach : activities -->
                                    <!-- ko if: records().length > 0-->
                                    <!-- ko foreach : records -->
                                    <tr>
                                        <!-- ko foreach: $root.columnConfig -->
                                        <!-- ko if: type == 'image' -->
                                        <td>
                                            <div class="projectLogo">
                                                <!--
                                                <a href=""
                                                   data-bind="attr:{href:fcConfig.imageLeafletViewer + '?file=' + encodeURIComponent(($parent.multimedia[0] && $parent.multimedia[0].identifier) || '${noImageUrl}')}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', type: 'iframe', width:'80%'}"
                                                   target="fancybox">
                                                    <img class="image-logo image-window" data-bind="attr:{title:($parent.multimedia[0] && $parent.multimedia[0].title) || 'No Image', src:($parent.multimedia[0] && $parent.multimedia[0].identifier) || '${noImageUrl}'}"  onload="findLogoScalingClass(this, 200, 150)">
                                                </a>
                                                -->
                                                <a data-bind="attr: {href: $parents[1].transients.viewUrl}">
                                                    <img class="image-logo image-window" onload="findLogoScalingClass(this, 200, 150)" data-bind="attr:{src:$parent.thumbnailUrl}"/>
                                                </a>
                                            </div>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if: type == 'recordNameFacet' -->
                                        <td>
                                            <div>
                                                <!-- ko if: $parent.name() -->
                                                <a target="_blank"
                                                   data-bind="visible: $parent.guid, attr:{href: $root.transients.bieUrl + '/species/' + $parent.guid()}">
                                                    <span data-bind="text: $parent.name"></span>
                                                </a>
                                                <span data-bind="visible: !$parent.guid()">
                                                    <span data-bind="text: $parent.name"></span>
                                                </span>
                                                <!-- /ko -->
                                            </div>
                                            <div>
                                                <span data-bind="text: $parent.commonName"></span>
                                            </div>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if: type == 'symbols' -->
                                        <td>
                                            <div>
                                                <!-- ko if: $parents[1].embargoed() -->
                                                <a href="#" class="helphover"
                                                   data-bind="popover: {title:'Embargoed', content:'Indicates that only project members can access the record'}">
                                                    <span class="fa fa-lock"></span>
                                                </a>
                                                <!--/ko -->
                                                &nbsp;&nbsp;
                                                <!-- ko if: $parent.individualCount() === 0 -->
                                                <a href="#" class="helphover"
                                                   data-bind="popover: {content:'The record indicates absence of the species'}">
                                                    <span class="fa fa-caret-up fa-2x" style="vertical-align: -3px;"></span>
                                                </a>
                                                <!--/ko -->
                                            </div>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if: type == 'details' -->
                                        <td>
                                            <div class="row-fluid">
                                                <div class="span12">
                                                    <div data-bind="visible: $parent.eventDate.formattedDate">
                                                        Recorded on: <span
                                                            data-bind="text: $parent.eventDate.formattedDate"></span>
                                                        <span data-bind="visible: $parent.eventTime, text: $parent.eventTime"></span>
                                                    </div>
                                                    <div data-bind="visible: $parents[1].lastUpdated">
                                                        Submitted on: <span
                                                            data-bind="text: $parents[1].lastUpdated.formattedDate"></span>
                                                    </div>
                                                    <div data-bind="visible: $parents[1].ownerName">
                                                        Recorded by: <span
                                                            data-bind="text: $parents[1].ownerName"></span>
                                                    </div>
                                                    <div data-bind="visible: $parent.coordinates && $parent.coordinates[0]">
                                                        Coordinate: <span class="display-inline-block ellipsis-50"
                                                            data-bind="text: $parent.coordinates[0], attr: {title: $parent.coordinates[0]}"></span>
                                                        <span class="display-inline-block ellipsis-50"
                                                            data-bind="text: ',' + $parent.coordinates[1], attr: {title: $parent.coordinates[1]}"></span>
                                                    </div>
                                                    <div data-bind="visible: $parents[1].name() && !fcConfig.hideProjectAndSurvey">
                                                        Survey name:
                                                        <a data-bind="attr:{'href': $parents[1].transients.addUrl}">
                                                            <span data-bind="text: $parents[1].name"></span>
                                                        </a>
                                                    </div>
                                                    <div data-bind="visible: $parents[1].projectName() && !fcConfig.hideProjectAndSurvey">
                                                        Project name: <a
                                                            data-bind="attr:{'href': $parents[1].projectUrl()}"><span
                                                                data-bind="text: $parents[1].projectName"></span></a>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if: type == 'action' -->
                                        <td>
                                            <div>
                                                <span>
                                                    <a data-bind="attr: {href: $parents[1].transients.viewUrl}" title="View record" class="btn btn-small editBtn btn-default margin-top-5"><i class="fa fa-file-o"></i> View</a>
                                                </span>
                                                <span data-bind="visible: !$parents[1].readOnly(), if: $parents[1].showCrud()">
                                                    <a data-bind="attr: {href: $parents[1].transients.editUrl }" title="Edit record" class="btn btn-small editBtn btn-default margin-top-5"><i class="fa fa-pencil"></i> Edit</a>
                                                </span>
                                                <span data-bind="visible: !$parents[1].readOnly(), if: $parents[1].showCrud()">
                                                    <button class="btn btn-small btn-default margin-top-5" data-bind="click: $parents[1].delete" title="Delete record"><i class="fa fa-trash"></i>&nbsp;Delete</button>

                                                </span>
                                            </div>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if: type == 'checkbox' && $parents[1].transients.parent.transients.isBulkActionsEnabled() -->
                                        <td class="text-align-center">
                                            <input type="checkbox" data-bind="visible: $parents[1].transients.parent.transients.isBulkActionsEnabled, disable: !$parents[1].userCanModerate, value: $parents[1].activityId, checked: $parents[1].transients.parent.transients.activitiesToDelete"/>
                                        </td>
                                        <!-- /ko -->
                                        <!-- ko if:  type == 'property' -->
                                        <td>
                                            <!-- ko if: dataType == 'date' -->
                                            <div data-bind="text: $parent.getPropertyValue($data) && moment($parent.getPropertyValue($data)).format('DD/MM/YYYY')"></div>
                                            <!-- /ko -->
                                            <!-- ko ifnot: dataType == 'date' -->
                                            <div data-bind="text: $parent.getPropertyValue($data)"></div>
                                            <!-- /ko -->
                                        </td>
                                        <!-- /ko -->

                                    <!-- /ko -->
                                    </tr>
                                    <!-- /ko -->
                                    <!-- /ko -->
                                    <!-- ko if: !records() || !records().length -->
                                    <tr>
                                        <!-- ko foreach: $root.columnConfig -->
                                            <!-- ko if:  type == 'image' -->
                                            <td>
                                                <div class="projectLogo">
                                                    <img class="image-logo wide" data-bind="attr:{title:$parent.transients.imageTitle, src:$parent.transients.thumbnailUrl} " />
                                                </div>
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if: type == 'recordNameFacet' -->
                                            <td>
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if:  type == 'symbols' -->
                                            <td>
                                                <div>
                                                    <!-- ko if: $parent.embargoed() -->
                                                    <a href="#" class="helphover"
                                                       data-bind="popover: {title:'Embargoed.', content:'Indicates that only project members can access the record'}">
                                                    </a>
                                                    <!--/ko -->
                                                </div>
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if:  type == 'property' -->
                                            <td>
                                                <!-- ko if: dataType == 'date' -->
                                                <div data-bind="text: $parent.getPropertyValue($data) && moment($parent.getPropertyValue($data)).format('DD/MM/YYYY')"></div>
                                                <!-- /ko -->
                                                <!-- ko ifnot: dataType == 'date' -->
                                                <div data-bind="text: $parent.getPropertyValue($data)"></div>
                                                <!-- /ko -->
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if:  type == 'details' -->
                                            <td>
                                                <div class="row-fluid">
                                                    <div class="span12">
                                                        <div data-bind="visible: $parent.lastUpdated">
                                                            Submitted on: <span
                                                                data-bind="text: $parent.lastUpdated.formattedDate"></span>
                                                        </div>
                                                        <div data-bind="visible: $parent.ownerName">
                                                            Recorded by: <span
                                                                data-bind="text: $parent.ownerName"></span>
                                                        </div>
                                                        <div data-bind="visible: $parent.name() && !fcConfig.hideProjectAndSurvey">
                                                            Survey name:
                                                            <a data-bind="attr:{'href': $parent.transients.addUrl}">
                                                                <span data-bind="text: $parent.name"></span>
                                                            </a>
                                                        </div>
                                                        <div data-bind="visible: $parent.projectName() && !fcConfig.hideProjectAndSurvey">
                                                            Project name: <a
                                                                data-bind="attr:{'href': $parent.projectUrl()}"><span
                                                                    data-bind="text: $parent.projectName"></span></a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if:  type == 'action' -->
                                            <td>
                                                <div>
                                                    <span>
                                                        <a data-bind="attr:{'href': $parent.transients.viewUrl}" title="View record" class="btn btn-small editBtn btn-default"><i class="fa fa-file-o"></i> View</a>
                                                    </span>
                                                    <!-- ko if: $parent.showCrud -->
                                                    <span data-bind="visible: !$parent.readOnly()">
                                                        <a data-bind="attr:{'href': $parent.transients.editUrl}" title="Edit record" class="btn btn-small editBtn btn-default"><i class="fa fa-pencil"></i> Edit</a>
                                                    </span>
                                                    <span data-bind="visible: !$parent.readOnly()">
                                                        <button class="btn btn-small btn-default" data-bind="click: $parent.delete" title="Delete record"><i class="fa fa-trash"></i>&nbsp;Delete</button>
                                                    </span>
                                                    <!-- /ko -->
                                                </div>
                                            </td>
                                            <!-- /ko -->
                                            <!-- ko if:  type == 'checkbox' && $parent.transients.parent.transients.isBulkActionsEnabled() -->
                                            <td class="text-align-center">
                                                <input type="checkbox" data-bind="visible: $parent.transients.parent.transients.isBulkActionsEnabled, disable: !$parent.userCanModerate, value: $parent.activityId, checked: $parent.transients.parent.transients.activitiesToDelete"/>
                                            </td>
                                            <!-- /ko -->
                                        <!-- /ko -->
                                    </tr>
                                    <!-- /ko -->
                                    <!-- /ko -->
                                </tbody>
                            </table>
                            <div class="margin-top-2"></div>
                            <g:render template="/shared/pagination"/>
                            <!-- ko if : activities().length > 0 -->
                            <div class="row-fluid">
                                <div class="span12 pull-right">
                                    <div class="span12 text-right">
                                        <div><small class="text-right"><span class="fa fa-lock"></span> indicates that only project members can access the record.
                                        </small></div>
                                        <div><small class="text-right"><span class="fa fa-caret-up fa-2x" style="vertical-align: -3px;"></span>  indicates species absence record.
                                        </small></div>
                                    </div>

                                </div>
                            </div>
                            <!-- /ko -->
                        <!-- /ko -->
                    </div>

                    <div class="tab-pane" id="mapVis">
                        <div class="alert alert-info">
                            <g:message code="data.map.message"></g:message>
                        </div>
                        <span data-bind="visible: transients.loadingMap()">
                            <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
                        </span>
                        <span data-bind="visible: transients.totalPoints() == 0 && !transients.loadingMap()">
                            <span class="text-left margin-bottom-five">
                                <span data-bind="if: transients.loading()">
                                    <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
                                </span>
                                <span data-bind="if: !transients.loading()">No Results</span>
                            </span>
                        </span>

                        <span data-bind="visible: transients.totalPoints() > 0 && !transients.loadingMap() ">
                            <m:map height="800px" width="auto" id="recordOrActivityMap" />
                        </span>
                    </div>

                    <!-- ko stopBinding:true -->
                    <div class="tab-pane" id="imageGallery">
                        <g:render template="/shared/imageGallery"></g:render>
                    </div>
                    <!-- /ko -->

                    <div class="tab-pane" id="chartGraph">
                        <g:render template="/shared/chartGraphTab"></g:render>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->

<asset:javascript src="chartjs/chart.min.js"/>
<asset:script type="text/javascript">

    var activitiesAndRecordsViewModel, alaMap, results;
    function initialiseData(view) {
        console.log('initialiseData - for images tab');
        var user = '${user ? user as grails.converters.JSON : "{}"}',
        configImageGallery;
        if (user) {
            user = JSON.parse(user);
        } else {
            user = null;
        }

        var columnConfig =${ hubConfig.getDataColumns(grailsApplication) as grails.converters.JSON}

        var facetConfig; 
        
        console.log('============== current view ==============');
        console.log(view);
        console.log('============== current view ==============');
        if(view === 'allrecords') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('allRecords') };
        } else if (view === 'myrecords') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('myRecords') };
        } else if (view === 'project') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('project') };
        } else if (view === 'projectrecords') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('projectrecords') };
        } else if (view === 'myprojectrecords') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('myprojectrecords') };
        } else if (view === 'userprojectactivityrecords') {
            facetConfig = ${ hubConfig.getFacetConfigForPage('userprojectactivityrecords') };
        } else {
            facetConfig = ${ hubConfig.getFacetConfigForPage('allRecords') };
        }

        var hubConfig = ${ hubConfig }

        activitiesAndRecordsViewModel = new ActivitiesAndRecordsViewModel('data-result-placeholder', view, user, false, false, ${doNotStoreFacetFilters?:false}, columnConfig, facetConfig);
        ko.applyBindings(activitiesAndRecordsViewModel, document.getElementById('survey-all-activities-and-records-content'));
        $('#dataMapTab').on('shown',function(){
            activitiesAndRecordsViewModel.transients.alaMap.redraw();
        })

        configImageGallery = {
            recordUrl: fcConfig.recordImageListUrl,
            poiUrl: fcConfig.poiImageListUrl,
            method: 'POST',
            element: document.getElementById('imageGallery'),
            data: {
                view: fcConfig.view,
                fq: [],
                searchTerm: '',
                projectId: fcConfig.projectId || '',
                spotterId: fcConfig.spotterId,
                projectActivityId: fcConfig.projectActivityId
            },
            viewModel: activitiesAndRecordsViewModel
        }

        activitiesAndRecordsViewModel.imageGallery = initialiseImageGallery(configImageGallery);
        console.log('initialiseData - 2');
        if(activitiesAndRecordsViewModel !== undefined) {
            console.log('activitiesAndRecordsViewModel facets '+activitiesAndRecordsViewModel.facets);
        }
        console.log('initialiseData - end');
    }

    // initialise tab
    var recordsTab = getUrlParameterValue('recordsTab'),
        tabId;
    switch (recordsTab){
        case 'map':
            tabId = '#dataMapTab';
            break;
        case 'list':
            tabId = '#recordVis-tab';
            break;
        case 'image':
            tabId = '#dataImageTab';
            break;
        case 'Graph':
            tabId = '#chartGraphTab';
            break;
    }

    tabId && $(tabId).tab('show');

</asset:script>
