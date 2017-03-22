<%@ page import="grails.converters.JSON" %>
<r:require modules="map"></r:require>
<g:set var="noImageUrl" value="${resource([dir: "images", file: "no-image-2.png"])}"/>
<!-- ko stopBinding: true -->
<div id="survey-all-activities-and-records-content">
    <div id="data-result-placeholder"></div>
    <div data-bind="visible: version().length == 0">
        <g:render template="../bioActivity/search"/>
    </div>

    <div class="row-fluid">
        <div class="span12">
            <div class="span3 text-left">

                <div class="well">
                    <g:render template="/shared/simpleFacetsFilterView"></g:render>
                </div>

            </div>
            <div class="span9 text-left well activities-search-panel">
                <config:occurrenceExplorerText hubConfig="${hubConfig}"/>
                <ul class="nav nav-tabs" id="tabDifferentViews">
                    <li class="active"><a id="recordVis-tab" href="#recordVis" data-toggle="tab" >List</a></li>
                    <li class=""><a href="#mapVis" id="dataMapTab" data-bind="attr:{'data-toggle': activities().length > 0 ? 'tab' : ''}">Map</a></li>
                    <li class=""><a href="#imageGallery" data-toggle="tab">Images</a></li>
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
                                <div class="span9">
                                    <h3 class="text-left margin-bottom-2">Found <span data-bind="text: total()"></span> record(s)</h3>
                                </div>
                                <div class="span3 padding-top-0 margin-bottom-2">
                                    <button data-bind="click: download, disable: transients.loading" data-email-threshold="${grailsApplication.config.download.email.threshold ?: 200}" class="btn btn-primary pull-right padding-top-1"><span class="fa fa-download">&nbsp;</span>Download</button>
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

                            <g:render template="../shared/pagination"/>
                            <table class="full-width table table-hover">
                                <thead>
                                    <tr>
                                        <th>
                                            Image
                                        </th>
                                        <th>
                                            Identification
                                        </th>
                                        <th></th>
                                        <th>
                                            Details
                                        </th>
                                        <th>
                                            Action
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- ko foreach : activities -->
                                    <!-- ko if: records().length > 0-->
                                    <!-- ko foreach : records -->
                                    <tr>
                                        <td>
                                            <div class="projectLogo">
                                                <a href=""
                                                   data-bind="attr:{href:fcConfig.imageLeafletViewer + '?file=' + encodeURIComponent((multimedia[0] && multimedia[0].identifier) || '${noImageUrl}')}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', type: 'iframe', width:'80%'}"
                                                   target="fancybox">
                                                    <img class="image-logo image-window" data-bind="attr:{title:(multimedia[0] && multimedia[0].title) || 'No Image', src:(multimedia[0] && multimedia[0].identifier) || '${noImageUrl}'}"  onload="findLogoScalingClass(this, 200, 150)">
                                                </a>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <!-- ko if: name() -->
                                                <a target="_blank"
                                                   data-bind="visible: guid, attr:{href: $root.transients.bieUrl + '/species/' + guid()}">
                                                    <span data-bind="text: name"></span>
                                                </a>
                                                <span data-bind="visible: !guid()">
                                                    <span data-bind="text: name"></span>
                                                </span>
                                                <!-- /ko -->
                                            </div>
                                            <div>
                                                <span data-bind="text: commonName"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <!-- ko if: $parent.embargoed() -->
                                                <a href="#" class="helphover"
                                                   data-bind="popover: {title:'Access to the record is restricted to non-project members', content:'Embargoed until : ' + moment($parent.embargoUntil()).format('DD/MM/YYYY')}">
                                                    <span class="icon-lock"></span>
                                                </a>
                                                <!--/ko -->
                                            </div>
                                        </td>
                                        <td>
                                            <div class="row-fluid">
                                                <div class="span12">
                                                    <div data-bind="visible: eventDate.formattedDate">
                                                        Recorded on: <span
                                                            data-bind="text: eventDate.formattedDate"></span>
                                                        <span data-bind="visible: eventTime, text: eventTime"></span>
                                                    </div>
                                                    <div data-bind="visible: $parent.lastUpdated">
                                                        Submitted on: <span
                                                            data-bind="text: $parent.lastUpdated.formattedDate"></span>
                                                    </div>
                                                    <div data-bind="visible: $parent.ownerName">
                                                        Recorded by: <span
                                                            data-bind="text: $parent.ownerName"></span>
                                                    </div>
                                                    <div data-bind="visible: coordinates && coordinates[0]">
                                                        Coordinate: <span class="ellipsis-50 display-inline-block"
                                                            data-bind="text: coordinates[0], attr: {title: coordinates[0]}"></span>
                                                        <span class="ellipsis-50 display-inline-block"
                                                            data-bind="text: ',' + coordinates[1], attr: {title: coordinates[1]}"></span>
                                                    </div>
                                                    <div data-bind="visible: $parent.name">
                                                        Survey name:
                                                        <a data-bind="attr:{'href': $parent.transients.addUrl}">
                                                            <span data-bind="text: $parent.name"></span>
                                                        </a>
                                                    </div>
                                                    <div data-bind="visible: $parent.projectName">
                                                        Project name: <a
                                                            data-bind="attr:{'href': $parent.projectUrl()}"><span
                                                                data-bind="text: $parent.projectName"></span></a>
                                                        <span class="badge" data-bind="if: $parent.isWorksProject() ">Works</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <span>
                                                    <button data-bind="click: function(){ window.location = $parent.transients.viewUrl() }" title="View record" class="btn btn-small editBtn btn-default margin-top-5"><i class="fa fa-file-o"></i> View</button>
                                                </span>
                                                <span data-bind="visible: !$parent.readOnly(), if: $parent.showCrud()">
                                                    <button data-bind="click: function(){ window.location = $parent.transients.editUrl() }" title="Edit record" class="btn btn-small editBtn btn-default margin-top-5"><i class="fa fa-pencil"></i> Edit</button>
                                                </span>
                                                <span data-bind="visible: !$parent.readOnly(), if: $parent.showCrud()">
                                                    <button class="btn btn-small btn-default margin-top-5" data-bind="click: function(){ $parent.transients.parent.delete($parent) }" title="Delete record"><i class="fa fa-trash"></i>&nbsp;Delete</button>
                                                </span>
                                            </div>
                                        </td>
                                    </tr>
                                    <!-- /ko -->
                                    <!-- /ko -->
                                    <!-- ko if: !records() || !records().length -->
                                    <tr>
                                        <td>
                                            <div class="projectLogo">
                                                <img class="image-logo wide" src="${noImageUrl}" title="No Image">
                                            </div>
                                        </td>
                                        <td>
                                        </td>
                                        <td>
                                            <div>
                                                <!-- ko if: embargoed() -->
                                                <a href="#" class="helphover"
                                                   data-bind="popover: {title:'Access to the record is restricted to non-project members', content:'Embargoed until : ' + moment(.embargoUntil()).format('DD/MM/YYYY')}">
                                                    <span class="icon-lock"></span>
                                                </a>
                                                <!--/ko -->
                                            </div>
                                        </td>
                                        <td>
                                            <div class="row-fluid">
                                                <div class="span12">
                                                    <div data-bind="visible: lastUpdated">
                                                        Submitted on: <span
                                                            data-bind="text: lastUpdated.formattedDate"></span>
                                                    </div>
                                                    <div data-bind="visible: ownerName">
                                                        Recorded by: <span
                                                            data-bind="text: ownerName"></span>
                                                    </div>
                                                    <div data-bind="visible: name">
                                                        Survey name:
                                                        <a data-bind="attr:{'href': transients.addUrl}">
                                                            <span data-bind="text: name"></span>
                                                        </a>
                                                    </div>
                                                    <div data-bind="visible: projectName">
                                                        Project name: <a
                                                            data-bind="attr:{'href': projectUrl()}"><span
                                                                data-bind="text: projectName"></span></a>
                                                        <span class="badge" data-bind="if: isWorksProject() ">Works</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div data-bind="if: showCrud()">
                                                <span>
                                                    <a data-bind="attr:{'href': transients.viewUrl}" title="View record" class="btn btn-small editBtn btn-default"><i class="fa fa-file-o"></i> View</a>
                                                </span>
                                                <span data-bind="visible: !readOnly()">
                                                    <a data-bind="attr:{'href': transients.editUrl}" title="Edit record" class="btn btn-small editBtn btn-default"><i class="fa fa-pencil"></i> Edit</a>
                                                </span>
                                                <span data-bind="visible: !readOnly()">
                                                    <button class="btn btn-small btn-default" data-bind="click: $parent.delete" title="Delete record"><i class="fa fa-trash"></i>&nbsp;Delete</button>
                                                </span>
                                            </div>
                                        </td>
                                    </tr>
                                    <!-- /ko -->
                                    <!-- /ko -->
                                </tbody>
                            </table>
                            <div class="margin-top-2"></div>
                            <g:render template="../shared/pagination"/>
                            <!-- ko if : activities().length > 0 -->
                            <div class="row-fluid">
                                <div class="span12 pull-right">
                                    <div class="span12 text-right">
                                        <div><small class="text-right"><span
                                                class="icon-lock"></span> indicates that only project members can access the record.
                                        </small></div>
                                    </div>

                                </div>
                            </div>
                            <!-- /ko -->
                        <!-- /ko -->
                    </div>

                    <div class="tab-pane" id="mapVis">
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
                            <m:map id="recordOrActivityMap" width="100%"/>
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
<r:script>
    var activitiesAndRecordsViewModel, alaMap, results;
    function initialiseData(view) {
        var user = '${user as grails.converters.JSON}',
            configImageGallery;
        if (user) {
            user = JSON.parse(user);
        } else {
            user = null;
        }
        activitiesAndRecordsViewModel = new ActivitiesAndRecordsViewModel('data-result-placeholder', view, user, false, false, ${doNotStoreFacetFilters?:false});
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
                projectId: fcConfig.projectId || ''
            },
            viewModel: activitiesAndRecordsViewModel
        }

        activitiesAndRecordsViewModel.imageGallery = initialiseImageGallery(configImageGallery);
    }


</r:script>
