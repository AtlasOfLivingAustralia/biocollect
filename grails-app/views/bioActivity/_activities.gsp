<!-- ko stopBinding: true -->
<div id="survey-all-activities-and-records-content">
    <div id="data-result-placeholder"></div>
    <g:render template="../bioActivity/search"/>
    <!-- ko if: activities().length > 0 -->
    <div class="row-fluid">
        <div class="span12">
            <div class="span3 text-left well">
                <g:render template="../bioActivity/facets"/>
            </div>

            <div class="span9 text-left">
                <div class="well">
                    <h3 class="text-left">Found <span data-bind="text: total()"></span> record<span data-bind="if: total() >= 2">s</span></h3>
                    <g:render template="../shared/pagination"/>
                    <!-- ko foreach : activities -->
                    <div class="row-fluid">
                        <div class="span12">
                            <div data-bind="attr:{class: embargoed() ? 'searchResultSection locked' : 'searchResultSection'}">

                                <div class="span9 text-left">
                                    <div>
                                        <h4>
                                            <!-- ko if: embargoed() -->
                                            <a href="#" class="helphover"
                                               data-bind="popover: {title:'Access to the record is restricted to non-project members', content:'Embargoed until : ' + moment(embargoUntil()).format('DD/MM/YYYY')}">
                                                <span class="icon-lock"></span>
                                            </a>
                                            <!--/ko -->
                                            Survey name:
                                            <a data-bind="attr:{'href': transients.viewUrl}">
                                                <span data-bind="text: name"></span>
                                            </a>
                                        </h4>
                                    </div>
                                    <!-- ko if : records().length > 0 -->
                                    <div>
                                        <h6>
                                            Species :
                                            <!-- ko foreach : records -->
                                            <a target="_blank"
                                               data-bind="attr:{href: $root.transients.bieUrl + '/species/' + guid()}">
                                                <span data-bind="text: $index()+1"></span>. <span
                                                    data-bind="text: name"></span>
                                            </a>
                                            <span data-bind="if: $parent.records().length != $index()+1">
                                                <b>|</b>
                                            </span>
                                            <!-- /ko -->
                                        </h6>
                                    </div>
                                    <!-- /ko -->

                                    <div>
                                        <h6>Project name: <a data-bind="attr:{'href': projectUrl()}"><span
                                                data-bind="text: projectName"></span></a></h6>
                                    </div>

                                    <div>
                                        <h6>Submitted by: <span data-bind="text: ownerName"></span> on <span
                                                data-bind="text: lastUpdated.formattedDate"></span>
                                        </h6>
                                    </div>
                                </div>

                                <div class="span3 text-right">

                                    <!-- looks awkward to show view eye icon by itself. Users can view the survey by clicking the survey title.-->
                                    <div class="padding-top-0" data-bind="if: showCrud()">
                                        <span class="margin-left-1">
                                            <a data-bind="attr:{'href': transients.viewUrl}"><i class="fa fa-eye" title="View survey"></i></a>
                                        </span>
                                        <span class="margin-left-1" data-bind="visible: showAdd()">
                                            <a data-bind="attr:{'href': transients.addUrl}"><i class="fa fa-plus" title="Add survey"></i></a>
                                        </span>
                                        <span class="margin-left-1">
                                            <a data-bind="attr:{'href': transients.editUrl}"><i class="fa fa-edit" title="Edit survey"></i></a>
                                        </span>
                                        <span class="margin-left-1">
                                            <a href="#" data-bind="click: $parent.delete"><i class="fa fa-remove" title="Delete survey"></i></a>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- /ko -->
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
                </div>
            </div>
        </div>
    </div>
    <!-- /ko -->
</div>
<!-- /ko -->

<r:script>
    function initialiseData(view) {
        ko.applyBindings(new ActivitiesAndRecordsViewModel('data-result-placeholder', view), document.getElementById('survey-all-activities-and-records-content'));
    }
</r:script>
