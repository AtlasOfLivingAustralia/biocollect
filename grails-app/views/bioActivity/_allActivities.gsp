<!-- ko stopBinding: true -->
<div id="survey-all-activities-content">
    <g:render template="../shared/loading"/>
    <!-- ko if: !transients.loading() -->
    <span class="main-content"  style="display: none;">
        <!-- ko if: activities().length == 0 -->
        <h4>Total results : 0</h4>
        <!-- /ko -->

        <g:render template="../shared/pagination"/>

        <!-- ko foreach : activities -->
            <div class="row-fluid">
                <div class="span12">
                    <div class="span12 text-left">

                        <div>
                            <strong>Survey name:</strong>
                            <a data-bind="attr:{'href': transients.viewUrl}">
                                <span data-bind="text: transients.pActivity.name"></span>
                            </a>
                        </div>

                        <div>
                            <small>Description: <span data-bind="text: transients.pActivity.description"></span>
                            </small>
                        </div>

                        <div>
                            <small>Submitted on: <span data-bind="text: lastUpdated.formattedDate"></span></small>
                        </div>

                        <div class="margin-bottom-2">
                            <a data-bind="attr:{'href': transients.viewUrl}">view</a>
                            <!-- ko if: showCrud -->
                            <a data-bind="visible: showAdd(), attr:{'href': transients.addUrl}">add</a>
                            <a data-bind="attr:{'href': transients.editUrl}">edit</a>
                            <a href="#" data-bind="click: $parent.delete">delete</a>
                            <!-- /ko -->
                        </div>
                    </div>
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
    function initialiseActivities(placeHolder){
        var viewModel = new ActivityListsViewModel(placeHolder);
        ko.applyBindings(viewModel, document.getElementById('survey-all-activities-content'));
        return viewModel;
    }
</r:script>