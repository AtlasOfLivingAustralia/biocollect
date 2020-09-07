<%@ page import="grails.converters.JSON" %>
<asset:stylesheet src="map-activity.css"/>
<g:set var="noImageUrl" value="${asset.assetPath([src: "no-image-2.png"])}"/>
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
                    <li class=""><a href="#mapVis" id="dataMapTab" data-toggle="tab">Map</a></li>
                    <li class=""><a id="dataImageTab" href="#imageGallery" data-toggle="tab">Images</a></li>
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
                        <span>
                            <m:map height="800px" width="auto" id="recordOrActivityMap" />
                        </span>
                        
                    </div>
                    <!-- ko stopBinding:true -->
                    <div class="tab-pane" id="imageGallery">
                        <g:render template="/shared/imageGallery"></g:render>
                    </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">
    var activitiesAndRecordsViewModel, alaMap, results;
    function initialiseData(view) {
        var user = '${user ? user as grails.converters.JSON : "{}"}',
        configImageGallery;
        if (user) {
            user = JSON.parse(user);
        } else {
            user = null;
        }

        var columnConfig =${ hubConfig.getDataColumns(grailsApplication) as grails.converters.JSON}

        activitiesAndRecordsViewModel = new ActivitiesAndRecordsViewModel('data-result-placeholder', view, user, false, false, ${doNotStoreFacetFilters?:false}, columnConfig);
        ko.applyBindings(activitiesAndRecordsViewModel, document.getElementById('survey-all-activities-and-records-content'));
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
    }

    tabId && $(tabId).tab('show');
</asset:script>
<asset:script type="text/html" id="script-popup-template">
    <div class="record-map-popup">
        <div class="container-fluid">
            <h3>Record (<!-- ko text: index() + 1 --> <!-- /ko --> of <!-- ko text: features.length --> <!-- /ko -->)</h3>
            <!-- ko foreach: features -->
            <div data-bind="if: $root.index() == $index()">
                <div class="row-fluid margin-bottom-10" data-bind="if: $data.properties.thumbnailUrl">
                    <div class="span12">
                        <div class="projectLogo image-centre">
                            <a target="_blank" data-bind="attr: { href: fcConfig.activityViewUrl + '/' + $data.properties.activityId }">
                                <img class="image-window image-logo" onload="findLogoScalingClass(this, 200, 150)" alt="Click to view record"  data-bind="attr: {src: $data.properties.thumbnailUrl || fcConfig.imageLocation + 'no-image-2.png'}" onerror="imageError(this, fcConfig.imageLocation + 'no-image-2.png');">
                            </a>
                        </div>
                    </div>
                </div>
                <div class="row-fluid" data-bind="if: $data.properties.recordNameFacet">
                    <div class="span6"><span><g:message code="record.popup.scientificname"/></span></div>
                    <div class="span6" data-bind="text: $data.properties.recordNameFacet"></div>
                </div>
                <div class="row-fluid" data-bind="if: $data.properties.projectActivityNameFacet">
                    <div class="span6"><span><g:message code="record.popup.survey"/></span></div>
                    <div class="span6" data-bind="text: $data.properties.projectActivityNameFacet"></div>
                </div>
                <div class="row-fluid" data-bind="if: $data.properties.projectNameFacet">
                    <div class="span6"><span><g:message code="record.popup.project"/></span></div>
                    <div class="span6">
                        <a title="View details of this project" target="_blank"
                           data-bind="attr: { href: fcConfig.projectIndexUrl + '/' + $data.properties.projectId }, text: $data.properties.projectNameFacet">
                        </a>
                    </div>
                </div>
                <div class="row-fluid" data-bind="if: $data.geometry.coordinates">
                    <div class="span6"><span><g:message code="record.popup.latlon"/></span></div>
                    <div class="span6">
                        <!-- ko text: Math.floor($data.geometry.coordinates[1]*10000)/10000 --> <!-- /ko --> &
                        <!-- ko text: Math.floor($data.geometry.coordinates[0]*10000)/10000 --> <!-- /ko -->
                    </div>
                </div>
                <div class="row-fluid" data-bind="if: $data.properties.surveyMonthFacet && $data.properties.surveyYearFacet">
                    <div class="span6"><span><g:message code="record.popup.created"/></span></div>
                    <div class="span6">
                    <!-- ko text: $data.properties.surveyMonthFacet --> <!-- /ko -->,
                    <!-- ko text: $data.properties.surveyYearFacet --> <!-- /ko -->
                    </div>
                </div>
                <div class="btn-group">
                    <button type="button" class="btn btn-mini" title="Previous record" data-bind="click: $root.index($root.index() - 1), disable: $root.index() == 0"><span>«</span></button>
                    <button type="button" class="btn btn-mini" title="Next record" data-bind="click: $root.index($root.index() + 1), disable: $root.index() == ($root.features.length - 1)"><span>»</span></button>
                </div>
                <a class="btn btn-mini" title="View details of this record" target="_blank" data-bind="attr: { href: fcConfig.activityViewUrl + '/' + $data.properties.activityId }"><span><g:message code="record.popup.view"/></span></a>
            </div>
            <!-- /ko -->
        </div>
    </div>
</asset:script>