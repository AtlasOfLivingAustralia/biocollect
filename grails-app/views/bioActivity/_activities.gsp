<%@ page import="grails.converters.JSON" %>
<g:set var="noImageUrl" value="${asset.assetPath([src: "biocollect-logo-dark.png"])}"/>
<!-- ko stopBinding: true -->
<div id="projectData" class="my-4 my-md-5">
    <div id="survey-all-activities-and-records-content">
        <bc:koLoading>
            <div class="container-fluid data-expander data-container show">
                <div class="row justify-content-end">
                    <div class="col-12 col-md-4 mb-3">
                        <g:render template="/bioActivity/search"/>
                    </div>
                </div>

                <div id="sortBar" class="row d-flex">
                    <div class="col col-md-4 mb-3 order-1 order-md-0 pr-1">
                        <button data-toggle="collapse" data-target=".data-expander" aria-expanded="true" aria-controls="filters" class="btn btn-dark" title="Filter Data">
                            <i class="fas fa-filter"></i> Filter Data
                        </button>
                    </div>
                    <div class="col col-sm-6 col-md-4 mb-3 text-right text-md-center order-2 order-md-1 pl-1">
                        <div class="btn-group">
                            <div class="btn-group nav nav-tabs" role="group" aria-label="Catalogue Display Options">
                                <a class="btn btn-outline-dark" id="data-grid-tab" data-toggle="tab" type="button"
                                   href="#dataGrid" title="<g:message code="data.grid.title"/>"
                                   role="tab" aria-controls="<g:message code="data.grid.title"/>">
                                    <i class="fas fa-th-large"></i>
                                </a>
                                <a class="btn btn-outline-dark active" id="data-list-tab" data-toggle="tab" type="button"
                                   href="#recordVis" title="<g:message code="data.list.title"/>"
                                   role="tab" aria-controls="<g:message code="data.list.title"/>" aria-selected="true">
                                    <i class="fas fa-list"></i>
                                </a>
                                <a class="btn btn-outline-dark" id="data-map-tab"
                                   data-bind="attr:{'data-toggle': activities().length > 0 ? 'tab' : ''}" type="button"
                                   href="#mapVis" title="<g:message code="data.map.title"/>"
                                   role="tab" aria-controls="<g:message code="data.map.title"/>">
                                    <i class="far fa-map"></i>
                                </a>
                                <a class="btn btn-outline-dark" id="data-image-tab" data-toggle="tab" type="button"
                                   href="#imageGallery" title="<g:message code="data.image.title"/>"
                                   role="tab" aria-controls="<g:message code="data.image.title"/>">
                                    <i class="far fa-images"></i>
                                </a>
                                <a class="btn btn-outline-dark" id="data-chart-tab" data-toggle="tab" type="button"
                                   href="#chartGraph" title="<g:message code="data.chart.title"/>"
                                   role="tab" aria-controls="<g:message code="data.chart.title"/>">
                                    <i class="fas fa-chart-pie"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-md-4 text-center text-md-right order-0 order-md-2">
                        <button class="btn btn-dark padding-top-1"
                                data-bind="click: download, disable: transients.loading"
                                data-email-threshold="${grailsApplication.config.download.email.threshold ?: 200}">
                            <i class="fas fa-download">&nbsp;</i> <g:message code="g.download"/>
                        </button>
                    </div>
                </div>

                <div class="filter-bar d-flex align-items-center">
                    <h4>Applied Filters: </h4>
                    <!-- ko foreach: filterViewModel.selectedFacets -->
                    <button class="filter-item btn btn-sm btn-outline-dark">
                        <strong data-bind="visible: exclude " title="Exclude">[EXCLUDE]</strong>
                        <!-- ko text: displayNameWithoutCount() --> <!-- /ko -->
                        <span class="remove" data-bind="click: remove"><i class="far fa-times-circle"></i></span>
                    </button>
                    <!-- /ko -->
                    <!-- ko if: (filterViewModel.selectedFacets() && (filterViewModel.selectedFacets().length > 0)) -->
                    <button type="button" class="btn btn-sm btn-dark clear-filters"  data-bind="click: reset" aria-label="Clear all filters"><i class="far fa-times-circle"></i> Clear All
                    </button>
                    <!-- /ko -->
                </div>

                <div class="records-found">
                    <div class="row d-flex align-items-center justify-content-between">
                        <div class="order-0 col-6 col-xl-auto flex-shrink-1">
                            <h4>Found <!-- ko text: total() --><!-- /ko --> record(s)</h4>
                        </div>
                        <div class="info order-2 order-xl-1 col-12 col-xl flex-grow-1 text-center mt-3 mt-xl-0">
                            <span class="item d-block d-md-inline">
                                <i class="fas fa-lock"></i>
                                Indicates that only project members can access the record
                            </span>
                            <span class="item d-block d-md-inline">
                                <i class="fas fa-caret-up fa-2x"></i>
                                Indicates species absence record
                            </span>
                        </div>
                        <div class="order-1 order-xl-2 col-6 col-xl-auto flex-shrink-1 text-right">
                            <span class="d-none" id="downloadStartedMsg"><i class="fa fa-spin fa-spinner"></i> Preparing download, please wait...</span>
                        </div>
                    </div>
                    <div class="row" data-bind="visible: transients.showEmailDownloadPrompt()">
                        <div class="col-12">
                            <div class="mb-2">
                                <span class="fas fa-info-circle">&nbsp;&nbsp;</span>This download may take several minutes. Please provide your email address, and we will notify you by email when the download is ready.
                            </div>
                            <div class="form-group">
                                <label for="email">Email address</label>
                                <input type="email" class="form-control" id="exampleInputEmail1" aria-describedby="emailHelp">
                                <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
                            </div>
                            <div class="form-group row">
                                <label class="col-form-label col-sm-2" for="email">Email address</label>
                                <div class="col-sm-10">
                                    <g:textField class="input-xxlarge" type="email" data-bind="value: transients.downloadEmail" name="email"/>
                                </div>
                            </div>
                            <button data-bind="click: asyncDownload" class="btn btn-primary-dark pt-1"><i class="fas fa-download">&nbsp;</i>Download</button>
                        </div>
                    </div>
                    <g:set var="divideSection" value="${hubConfig.content?.showNote && isProjectContributingDataToALA}"/>
                    <g:if test="${hubConfig.content?.showNote || isProjectContributingDataToALA}">
                        <div class="row d-flex my-3 align-items-center">
                            <g:if test="${hubConfig.content?.showNote}">
                                <div class="col-12 ${divideSection ? "col-md-8" : "col-md-12"}">
                                    <div class="alert alert-info mb-0" role="alert">
                                        <strong>Note!</strong> ${hubConfig.content?.recordNote?.encodeAsHTML()}
                                    </div>
                                </div>
                            </g:if>
                            <g:if test="${isProjectContributingDataToALA}">
                                <div class="col-12 ${divideSection ? "col-md-4" : "col-md-12"} text-right">
                                    <div class="btn-space">
                                        <a class="btn btn-sm btn-dark" data-bind="attr:{href: biocacheUrl}">
                                            <i class="fas fa-globe"></i> View in occurrence explorer
                                        </a>
                                        <a class="btn btn-sm btn-dark" data-bind="attr:{href: spatialUrl}">
                                            <i class="fas fa-map"></i> View in spatial portal
                                        </a>
                                    </div>
                                </div>
                            </g:if>
                        </div>
                    </g:if>
                </div>
                <div class="tab-content activities-search-panel">
                    <div class="tab-pane" id="dataGrid" role="tabpanel">
                        <g:render template="/shared/pagination" model="[bs:4, classes:'mb-3']"/>
                        <!-- .pagination -->
                        <div class="records-list row d-flex flex-wrap mt-4 mt-md-4 mb-3">
                            <!-- ko if: activities().length == 0 -->
                            <div class="col-12 d-flex">
                                <h3 class="text-left mb-1">
                                    <span data-bind="if: $root.searchTerm() == '' && $root.filterViewModel.selectedFacets().length == 0 && !$root.transients.loading()">
                                        No data has been recorded for this project yet
                                    </span>
                                    <span data-bind="if: $root.searchTerm() != '' || $root.filterViewModel.selectedFacets().length > 0 && !$root.transients.loading()">No results</span>
                                </h3>
                            </div>
                            <!-- /ko -->
                            <!-- ko foreach : activities -->
                            <!-- ko if : records().length > 0 -->
                            <!-- ko foreach : records -->
                            <div class="col-12 col-lg-6 col-xl-4 d-flex">
                                <div class="record flex-grow-1">
                                    <div class="row">
                                        <div class="col-12 col-sm-5 pb-3 pb-sm-0">
                                            <img onload="findLogoScalingClass(this, 200, 150)" data-bind="attr:{src: thumbnailUrl}"
                                                 onerror="imageError(this, '${noImageUrl}');"/>
                                        </div>
                                        <div class="col-12 col-sm-7 pl-sm-1">
                                            <h4 data-bind="text: name"></h4>
                                            <ul class="detail-list">
                                                <li><span class="label">Submitted On:</span>
                                                    <time aria-label="Date Submitted" >
                                                        <!-- ko text: $parent.lastUpdated.formattedDate --><!-- /ko -->
                                                    </time>
                                                </li>
                                                <li><span class="label">Recorded By:</span> <!-- ko text: $parent.ownerName --><!-- /ko --></li>
                                                <li><span class="label">Survey Name:</span> <!-- ko text: $parent.name --><!-- /ko --></li>
                                                <li><span class="label">Project Name:</span> <!-- ko text: $parent.projectName --><!-- /ko --></li>
                                            </ul>
                                            <div class="btn-space">
                                                <a class="btn btn-primary-dark btn-sm"
                                                   data-bind="attr:{href: $parent.transients.viewUrl}"
                                                   title="<g:message code="data.activity.view.title"/>"
                                                   role="button">
                                                    <i class="far fa-eye"></i>
                                                    <g:message code="btn.view"/>
                                                </a>
                                                <!-- ko if: $parent.showCrud() && !$parent.readOnly()-->
                                                <a class="btn btn-sm editBtn btn-dark"
                                                   data-bind="attr: {href: $parent.transients.editUrl }"
                                                   title="Edit record"><i class="fas fa-pencil-alt"></i>&nbsp;Edit</a>
                                                <button class="btn btn-sm btn-dark"
                                                        data-bind="click: $parent.delete"
                                                        title="Delete record"><i class="far fa-trash-alt"></i>&nbsp;Delete</button>
                                                <!-- /ko -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /ko -->
                            <!-- /ko -->

                            <!-- ko if : records().length == 0 -->
                            <div class="col-12 col-lg-6 col-xl-4 d-flex">
                                <div class="record flex-grow-1">
                                    <div class="row">
                                        <div class="col-12 col-sm-5 pb-3 pb-sm-0">
                                            <img data-bind="attr:{src: transients.thumbnailUrl}" onload="findLogoScalingClass(this, 200, 150)"
                                                 onerror="imageError(this, '${noImageUrl}');"/>
                                        </div>
                                        <div class="col-12 col-sm-7 pl-sm-1">
                                            <h4 data-bind="text: name"></h4>
                                            <ul class="detail-list">
                                                <li><span class="label">Submitted On:</span>
                                                    <time aria-label="Date Submitted" >
                                                        <!-- ko text: lastUpdated.formattedDate --><!-- /ko -->
                                                    </time>
                                                </li>
                                                <li><span class="label">Recorded By:</span> <!-- ko text: ownerName --><!-- /ko --></li>
                                                <li><span class="label">Survey Name:</span> <!-- ko text: name --><!-- /ko --></li>
                                                <li><span class="label">Project Name:</span> <!-- ko text: projectName --><!-- /ko --></li>
                                            </ul>
                                            <div class="btn-space">
                                                <a class="btn btn-primary-dark btn-sm"
                                                   data-bind="attr:{href: transients.viewUrl}"
                                                   title="<g:message code="data.activity.view.title"/>"
                                                   role="button">
                                                    <i class="far fa-eye"></i>
                                                    <g:message code="btn.view"/>
                                                </a>
                                                <!-- ko if: showCrud() && !readOnly() -->
                                                <a class="btn btn-sm btn-dark editBtn"
                                                   data-bind="attr: {href: transients.editUrl}"
                                                   title="Edit record"><i class="fas fa-pencil-alt"></i>&nbsp;Edit</a>
                                                <button class="btn btn-sm btn-dark" data-bind="click: $data.delete"
                                                        title="Delete record"><i class="far fa-trash-alt"></i>&nbsp;Delete</button>
                                                <!-- /ko -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /ko -->
                            <!-- /ko -->
                        </div>
                        <g:render template="/shared/pagination" model="[bs:4]"/>
                        <!-- .pagination -->
                    </div>
                    <div class="tab-pane active" id="recordVis">
                        <!-- ko if: activities().length == 0 -->
                        <div class="row">
                            <h3 class="text-left mb-1">
                                <span data-bind="if: $root.searchTerm() == '' && $root.filterViewModel.selectedFacets().length == 0 && !$root.transients.loading()">
                                    No data has been recorded for this project yet
                                </span>
                                <span data-bind="if: $root.searchTerm() != '' || $root.filterViewModel.selectedFacets().length > 0 && !$root.transients.loading()">No results</span>
                            </h3>
                        </div>
                        <!-- /ko -->

                        <!-- ko if: activities().length > 0 -->

                        <div class="row" data-bind="visible: version().length == 0">
                            <div class="col-12">
                                <div class="float-right mb-2 mt-1">
                                    <!-- ko if:  transients.isBulkActionsEnabled -->
                                    <span><g:message code="data.bulk.actions.label"/>
                                        <div class="btn-group" role="group" aria-label="<g:message code="data.bulk.actions.label" />">
                                            <button class="btn btn-sm btn-dark" data-bind="disable: !transients.activitiesToDelete().length, click: bulkDelete"><i class="fas fa-trash-alt">&nbsp;</i> <g:message code="project.bulkactions.delete"/></button>
                                            <button class="btn btn-sm btn-dark" data-bind="disable: !transients.activitiesToDelete().length, click: bulkEmbargo"><i class="fas fa-lock">&nbsp;</i> <g:message code="project.bulkactions.embargo"/></button>
                                            <button class="btn btn-sm btn-dark" data-bind="disable: !transients.activitiesToDelete().length, click: bulkRelease"><i class="fas fa-unlock">&nbsp;</i> <g:message code="project.bulkactions.release"/></button>
                                        </div>
                                    </span>
                                    <!-- /ko -->
                                </div>

                            </div>
                        </div>

                        <g:render template="/shared/pagination" model="[bs: 4]"/>
                        <table class="table table-hover">
                            <thead>
                            <tr>
                                <!-- ko foreach : columnConfig -->
                                <!-- ko if:  type != 'checkbox' -->
                                <th>
                                    <!-- ko if: isSortable -->
                                    <div data-bind="click: $parent.sortByColumn" role="button">
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
                                <td class="align-top">
                                    <div class="projectLogo project-logo">
                                        <a data-bind="attr: {href: $parents[1].transients.viewUrl}">
                                            <!-- ko if: $parent.multimedia[0] && $parent.multimedia[0].identifier -->
                                            <img class="image-logo image-window" data-bind="attr:{title:($parent.multimedia[0] && $parent.multimedia[0].title) || 'No Image', src:($parent.multimedia[0] && $parent.multimedia[0].identifier) || '${noImageUrl}'}"  onload="findLogoScalingClass(this, 200, 150)">
                                            <!-- /ko -->
                                            <!-- ko ifnot: $parent.multimedia[0] && $parent.multimedia[0].identifier -->
                                            <img class="image-logo image-window" onload="findLogoScalingClass(this, 200, 150)" data-bind="attr:{src:$parent.thumbnailUrl}"/>
                                            <!-- /ko -->
                                        </a>
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if: type == 'recordNameFacet' -->
                                <td class="align-top">
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
                                <td class="align-top">
                                    <div>
                                        <!-- ko if: $parents[1].embargoed() -->
                                        <a href="#" class="helphover"
                                           data-bind="popover: {title:'Embargoed', content:'Indicates that only project members can access the record'}">
                                            <span class="fas fa-lock"></span>
                                        </a>
                                        <!-- /ko -->
                                        &nbsp;&nbsp;
                                        <!-- ko if: $parent.individualCount() === 0 -->
                                        <a href="#" class="helphover"
                                           data-bind="popover: {content:'The record indicates absence of the species'}">
                                            <span class="fas fa-caret-up fa-2x" style="vertical-align: -3px;"></span>
                                        </a>
                                        <!-- /ko -->
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if: type == 'details' -->
                                <td class="align-top">
                                    <div class="row">
                                        <div class="col-12">
                                            <ul class="detail-list m-0">
                                                <li data-bind="if: $parent.eventDate.formattedDate">
                                                    <span class="label">Recorded on:</span> <span
                                                        data-bind="text: $parent.eventDate.formattedDate"></span>
                                                    <span data-bind="visible: $parent.eventTime, text: $parent.eventTime"></span>
                                                </li>
                                                <li data-bind="if: $parents[1].lastUpdated">
                                                    <span class="label">Submitted on:</span> <span
                                                        data-bind="text: $parents[1].lastUpdated.formattedDate"></span>
                                                </li>
                                                <li data-bind="if: $parents[1].ownerName">
                                                    <span class="label">Recorded by:</span> <span
                                                        data-bind="text: $parents[1].ownerName"></span>
                                                </li>
                                                <li class="text-truncate" data-bind="if: $parent.coordinates && $parent.coordinates[0]">
                                                    <span class="label">Coordinate:</span> <span class="display-inline-block text-truncate"
                                                                      data-bind="text: $parent.coordinates[0], attr: {title: $parent.coordinates[0]}"></span>
                                                    <span class="display-inline-block text-truncate"
                                                          data-bind="text: ',' + $parent.coordinates[1], attr: {title: $parent.coordinates[1]}"></span>
                                                </li>
                                                <li data-bind="if: $parents[1].name() && !fcConfig.hideProjectAndSurvey">
                                                    <span class="label">Survey name:</span>
                                                    <a data-bind="attr:{'href': $parents[1].transients.addUrl}">
                                                        <span data-bind="text: $parents[1].name"></span>
                                                    </a>
                                                </li>
                                                <li data-bind="if: $parents[1].projectName() && !fcConfig.hideProjectAndSurvey">
                                                    <span class="label">Project name:</span> <a
                                                        data-bind="attr:{'href': $parents[1].projectUrl()}"><span
                                                            data-bind="text: $parents[1].projectName"></span></a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if: type == 'action' -->
                                <td class="align-top">
                                    <div class="btn-space">
                                        <a class="btn btn-sm btn-primary-dark editBtn" data-bind="attr: {href: $parents[1].transients.viewUrl}" title="View record"><i class="far fa-eye"></i> View</a>
                                        <!-- ko if: !$parents[1].readOnly() &&  $parents[1].showCrud() -->
                                        <a  class="btn btn-sm editBtn btn-dark" data-bind="attr: {href: $parents[1].transients.editUrl }" title="Edit record"><i class="fas fa-pencil-alt"></i> Edit</a>
                                        <!-- /ko -->
                                        <!-- ko if: !$parents[1].readOnly() && $parents[1].showCrud() -->
                                        <button class="btn btn-sm btn-dark" data-bind="click: $parents[1].delete" title="Delete record"><i class="far fa-trash-alt"></i>&nbsp;Delete</button>
                                        <!-- /ko -->
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if: type == 'checkbox' && $parents[1].transients.parent.transients.isBulkActionsEnabled() -->
                                <td class="text-align-center align-top">
                                    <input type="checkbox" data-bind="visible: $parents[1].transients.parent.transients.isBulkActionsEnabled, disable: !$parents[1].userCanModerate, value: $parents[1].activityId, checked: $parents[1].transients.parent.transients.activitiesToDelete"/>
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'property' -->
                                <td class="align-top">
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
                                <td class="align-top">
                                    <div class="projectLogo project-logo">
                                        <img class="image-logo wide" data-bind="attr:{title:$parent.transients.imageTitle, src:$parent.transients.thumbnailUrl} " />
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if: type == 'recordNameFacet' -->
                                <td class="align-top">
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'symbols' -->
                                <td class="align-top">
                                    <div>
                                        <!-- ko if: $parent.embargoed() -->
                                        <a href="#" class="helphover"
                                           data-bind="popover: {title:'Embargoed.', content:'Indicates that only project members can access the record'}">
                                        </a>
                                        <!-- /ko -->
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'property' -->
                                <td class="align-top">
                                    <!-- ko if: dataType == 'date' -->
                                    <div data-bind="text: $parent.getPropertyValue($data) && moment($parent.getPropertyValue($data)).format('DD/MM/YYYY')"></div>
                                    <!-- /ko -->
                                    <!-- ko ifnot: dataType == 'date' -->
                                    <div data-bind="text: $parent.getPropertyValue($data)"></div>
                                    <!-- /ko -->
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'details' -->
                                <td class="align-top">
                                    <div class="row">
                                        <div class="col-12">
                                            <ul class="detail-list m-0">
                                                <li data-bind="visible: $parent.lastUpdated">
                                                   <span class="label">Submitted on:</span> <span
                                                        data-bind="text: $parent.lastUpdated.formattedDate"></span>
                                                </li>
                                                <li data-bind="visible: $parent.ownerName">
                                                    <span class="label">Recorded by:</span> <span
                                                        data-bind="text: $parent.ownerName"></span>
                                                </li>
                                                <li data-bind="visible: $parent.name() && !fcConfig.hideProjectAndSurvey">
                                                    <span class="label">Survey name:</span>
                                                    <a data-bind="attr:{'href': $parent.transients.addUrl}">
                                                        <span data-bind="text: $parent.name"></span>
                                                    </a>
                                                </li>
                                                <li data-bind="visible: $parent.projectName() && !fcConfig.hideProjectAndSurvey">
                                                    <span class="label">Project name:</span> <a
                                                        data-bind="attr:{'href': $parent.projectUrl()}"><span
                                                            data-bind="text: $parent.projectName"></span></a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'action' -->
                                <td class="align-top">
                                    <div class="btn-space">
                                        <a data-bind="attr:{'href': $parent.transients.viewUrl}"
                                           title="<g:message code="data.activity.view.title"/>"
                                           class="btn btn-sm editBtn btn-primary-dark">
                                            <i class="far fa-eye"></i>
                                            <g:message code="btn.view"/>
                                        </a>
                                        <!-- ko if: $parent.showCrud() && !$parent.readOnly() -->
                                        <a data-bind="attr:{'href': $parent.transients.editUrl}"
                                           title="Edit record"
                                           class="btn btn-sm editBtn btn-dark">
                                            <i class="fas fa-pencil-alt"></i> Edit
                                        </a>
                                        <button class="btn btn-sm btn-dark"
                                                data-bind="click: $parent.delete"
                                                title="Delete record">
                                            <i class="far fa-trash-alt"></i>&nbsp;Delete
                                        </button>
                                        <!-- /ko -->
                                    </div>
                                </td>
                                <!-- /ko -->
                                <!-- ko if:  type == 'checkbox' && $parent.transients.parent.transients.isBulkActionsEnabled() -->
                                <td class="text-align-center align-top">
                                    <input type="checkbox" data-bind="visible: $parent.transients.parent.transients.isBulkActionsEnabled, disable: !$parent.userCanModerate, value: $parent.activityId, checked: $parent.transients.parent.transients.activitiesToDelete"/>
                                </td>
                                <!-- /ko -->
                                <!-- /ko -->
                            </tr>
                            <!-- /ko -->
                            <!-- /ko -->
                            </tbody>
                        </table>
                        <g:render template="/shared/pagination" model="[bs: 4]"/>
                        <!-- /ko -->
                    </div>

                    <div class="tab-pane fade" id="mapVis" role="tabpanel">
                        <div class="alert alert-info">
                            <g:message code="data.map.message"></g:message>
                        </div>
                        <span data-bind="visible: transients.loadingMap()">
                            <i class="fa fa-spin fa-spinner"></i>&nbsp;Loading...
                        </span>
                        <span data-bind="visible: transients.totalPoints() == 0 && !transients.loadingMap()">
                            <span class="text-left mb-1">
                                <span data-bind="if: transients.loading()">
                                    <i class="fa fa-spin fa-spinner"></i>&nbsp;Loading...
                                </span>
                                <span data-bind="if: !transients.loading()">No Results</span>
                            </span>
                        </span>

                        <span data-bind="visible: transients.totalPoints() > 0 && !transients.loadingMap() ">
                            <m:map height="800px" width="auto" id="recordOrActivityMap" />
                        </span>
                    </div>

                    <!-- ko stopBinding: true -->
                    <div class="tab-pane fade" id="imageGallery" role="tabpanel" aria-labelledby="data-map-tab">
                        <g:render template="/shared/imageGallery"></g:render>
                    </div>
                    <!-- /ko -->

                    <div class="tab-pane fade" id="chartGraph" role="tabpanel" aria-labelledby="data-chart-tab">
                        <g:render template="/shared/chartGraphTab"></g:render>
                    </div>
                </div>

            </div>

            <g:render template="/shared/simpleFacetsFilterView"></g:render>
            <!-- /#filters -->
        </bc:koLoading>
    </div>
</div>
<!-- /ko -->

<asset:javascript src="chartjs/chart.min.js"/>
<asset:script type="text/javascript">
    <g:applyCodec encodeAs="none">

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

        var facetConfig; 

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
            console.warn("[Facets] Unrecognised view name '" + view + "', using allRecords facet config.");
            facetConfig = ${ hubConfig.getFacetConfigForPage('allRecords') };
        }

        var hubConfig = ${ hubConfig }

        activitiesAndRecordsViewModel = new ActivitiesAndRecordsViewModel('data-result-placeholder', view, user, false, false, ${doNotStoreFacetFilters?:false}, columnConfig, facetConfig);
        ko.applyBindings(activitiesAndRecordsViewModel, document.getElementById('survey-all-activities-and-records-content'));
        $('#data-map-tab').on('shown.bs.tab',function(){
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
    }

    // initialise tab
    var recordsTab = getUrlParameterValue('recordsTab'),
        tabId;
    switch (recordsTab){
        case 'map':
            tabId = '#data-map-tab';
            break;
        case 'list':
            tabId = '#data-list-tab';
            break;
        case 'grid':
            tabId = '#data-grid-tab';
            break;
        case 'image':
            tabId = '#data-image-tab';
            break;
        case 'Graph':
            tabId = '#data-chart-tab';
            break;
    }

    tabId && $(tabId).tab('show');
    </g:applyCodec>
</asset:script>
