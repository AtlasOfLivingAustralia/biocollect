<!-- ko stopBinding: true -->
<div id="survey-all-records-content">
    <g:render template="../shared/loading"/>

    <!-- ko if: !transients.loading() -->
    <span class="main-content"  style="display: none;">
        <!-- ko if: records().length == 0 -->
        <h4>Total records : 0</h4>
        <!-- /ko -->

        <g:render template="../shared/pagination"/>

        <!-- ko foreach : records -->
        <div class="row-fluid">
            <div class="span12">
                <div>
                    <strong>Species: </strong>
                    <a data-bind="visible: showCrud(), attr:{'href': transients.viewUrl}">
                        <span data-bind="text: name"></span>
                    </a>
                    <span data-bind="visible: !showCrud(), text: name"></span>
                </div>
                <small>Survey name: </small><small data-bind="text: transients.pActivity.name"></small>
                </br>
                <small>Description: </small><small data-bind="text: transients.pActivity.description"></small>
                </br>
                <small>Submitted on: <span data-bind="text: lastUpdated.formattedDate"></span></small>
                <!-- ko if: showCrud -->
                    </br>
                    <a data-bind="attr:{'href': transients.viewUrl}">view</a>
                    <a data-bind="visible: showAdd, attr:{'href': transients.addUrl}">add</a>
                    <a data-bind="attr:{'href': transients.editUrl}">edit</a>
                    <a href="#" data-bind="click: $parent.delete">delete</a>
                <!-- /ko -->
            </br></br>
            </div>
        </div>
        <!-- /ko -->

        </br>
        <g:render template="../shared/pagination"/>
    </span>
    <!-- /ko -->
</div>
<!-- /ko -->

<r:script>
    function initialiseRecords(placeHolder){
        var viewModel = new RecordListsViewModel(placeHolder)
        ko.applyBindings(viewModel, document.getElementById('survey-all-records-content'));
        return viewModel;
    }
</r:script>