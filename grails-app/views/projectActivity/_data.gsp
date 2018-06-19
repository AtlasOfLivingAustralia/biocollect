<!-- ko stopBinding: true -->
<div id="pActivitiesData">

   <div class="row-fluid">
        <div class="span12">

            <div class="span12">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#survey-all-data-activities" id='survey-all-data-activities-tab' data-toggle="tab">Records</a></li>
                    <li><a href="#survey-all-data-records" id='survey-all-data-records-tab' data-toggle="tab">Records</a></li>
                    <li><a href="#survey-all-data-map" id='survey-all-data-map-tab' data-toggle="pill">Map</a></li>

                </ul>

                <div class="tab-content clearfix">
                    <div class="tab-pane active" id="survey-all-data-activities">
                        <h5>

                            <b>Showing activities for:</b>

                        </h5>
                    </div>

                    <div class="tab-pane" id="survey-all-data-records">
                        <h5>

                            <b>Showing records for:</b>

                        </h5>
                    </div>

                    <div class="tab-pane" id="survey-all-data-map">

                    </div>

                </div>

            </div>

        </div>

    </div>

</div>
<!-- /ko -->


<asset:script type="text/javascript">
    function initialiseProjectActivitiesData(pActivitiesVM){
        var pActivitiesDataVM = new ProjectActivitiesDataViewModel(pActivitiesVM);
        ko.applyBindings(pActivitiesDataVM, document.getElementById('pActivitiesData'));
    };
</asset:script>