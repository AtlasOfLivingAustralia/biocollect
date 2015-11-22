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
                    <h3 class="text-left">Found <span data-bind="text: total()"></span> records</h3>
                    <g:render template="../shared/pagination"/>
                    <!-- ko foreach : activities -->
                    <div class="row-fluid">
                        <div class="span12">
                            <div data-bind="attr:{class: embargoed() ? 'searchResultSection locked' : 'searchResultSection'}">
                                <div class="span12 text-left ">
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

                                    <div>
                                        <small>Project name: <a data-bind="attr:{'href': projectUrl()}"><span
                                                data-bind="text: projectName"></span></a></small>
                                    </div>
                                    <!-- ko if : records().length > 0 -->
                                    <div>
                                        <small>
                                            Species :
                                            <!-- ko foreach : records -->
                                            <a target="_blank"
                                               data-bind="attr:{href: $root.transients.bieUrl + '/species/' + guid()}">
                                                <span data-bind="text: $index()+1"></span>. <span
                                                    data-bind="text: name"></span>
                                            </a>
                                            <!-- /ko -->
                                        </small>

                                    </div>
                                    <!-- /ko -->
                                    <div>
                                        <small>Submitted by: <span data-bind="text: ownerName"></span> on <span
                                                data-bind="text: lastUpdated.formattedDate"></span></small>
                                    </div>
                                    <a data-bind="attr:{'href': transients.viewUrl}">view</a>
                                    <span data-bind="if: access()">
                                        <span data-bind="visible: showAdd()">
                                            <a data-bind="attr:{'href': transients.addUrl}">add</a>
                                        </span>
                                        <a data-bind="attr:{'href': transients.editUrl}">edit</a>
                                        <a href="#" data-bind="click: $parent.delete">delete</a>
                                    </span>
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
                                        class="icon-lock"></span> indicates that access to the record is restricted to non-project members.
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
    function initialiseData(caller) {
        ko.applyBindings(new ActivitiesAndRecordsViewModel('data-result-placeholder', caller), document.getElementById('survey-all-activities-and-records-content'));
    }
</r:script>
