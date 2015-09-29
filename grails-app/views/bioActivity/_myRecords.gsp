<div id="survey-records-content">
    <g:render template="../shared/loading"/>
    <!-- ko if: !transients.loading() -->
        <span class="main-content"  style="display: none;">
            <div class="row-fluid">
                <div class="span12 ">
                    <div class="span12 text-center">
                        <h1 class="text-success">Total records: <span  data-bind="text: pagination.totalResults()"></span></h1>
                    </div>

                </div>
            </div>
            </br>

            <!-- ko foreach : records -->
            <div class="row-fluid">
                <div class="span12">
                    <div class="span1 text-right">
                        <label data-bind="text: $parent.pagination.start() + $index()">
                        </label>
                    </div>
                    <div class="span2 text-center">
                        <span data-bind="text: lastUpdated.formattedDate"></span>
                    </div>
                    <div class="span5">
                        <a data-bind="attr:{'href': transients.viewUrl}">
                            <a data-bind="attr:{'href': transients.viewUrl}"><span data-bind="text: transients.pActivity.name"></span></a>

                        </a>
                    </div>
                    <div class="span4 text-right">
                        <a data-bind="attr:{'href': transients.addUrl}"><span class="badge badge-default">add</span></a>
                        <a data-bind="attr:{'href': transients.viewUrl}"><span class="badge badge-info">view</span></a>
                        <a data-bind="attr:{'href': transients.editUrl}"><span class="badge badge-warning">edit</span></a>
                        <a data-bind="attr:{'href': transients.deleteUrl}"><span class="badge badge-important">delete</span></a>
                    </div>
                </div>
            </div>
            <!-- /ko -->

            </br>
    <g:render template="../shared/pagination"/>
    </span>
    <!-- /ko -->
</div>

<r:script>
    function initialiseMyRecords(){
        ko.applyBindings(new RecordListsViewModel(), document.getElementById('survey-records-content'));
    }
</r:script>