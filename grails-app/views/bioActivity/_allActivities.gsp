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

                        <label>
                            <strong>Survey name: </strong>
                            <a data-bind="attr:{'href': transients.viewUrl}">
                                <span data-bind="text: transients.pActivity.name"></span>
                            </a>
                        </label>
                        <small>Description: <span data-bind="text: transients.pActivity.description"></span></small></br>
                        <small>Submitted on: <span data-bind="text: lastUpdated.formattedDate"></span></small>
                        <g:if test="${show}">
                            </br>
                            <a data-bind="attr:{'href': transients.addUrl}"><small>add</small></a>
                            <a data-bind="attr:{'href': transients.viewUrl}"><small>view</small></a>
                            <a data-bind="attr:{'href': transients.editUrl}"><small>edit</small></a>
                            <a href="#" data-bind="click: $parent.delete"><small>delete</small></a>
                        </g:if>
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
    function initialiseActivities(){
        ko.applyBindings(new ActivityListsViewModel(), document.getElementById('survey-all-activities-content'));
    }
</r:script>