<div id="project-all-data">

    <div id="data-result-placeholder"></div>

    <div class="row-fluid">
        <div class="span12">

            <div class="span12">
                <ul class="nav nav-tabs" id="ul-project-records-activities">
                    <li><a href="#survey-all-data-activities" id='survey-all-data-activities-tab' data-toggle="tab">Surveys</a></li>
                    <li><a href="#survey-all-data-records" id='survey-all-data-records-tab' data-toggle="tab">Records</a></li>
                </ul>
                <div class="tab-content clearfix">
                    <div class="tab-pane" id="survey-all-data-activities">
                        <h5>
                            <g:render template="../bioActivity/allActivities"/>
                        </h5>
                    </div>
                    <div class="tab-pane" id="survey-all-data-records">
                        <h5>
                            <g:render template="../bioActivity/allRecords"/>
                        </h5>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<r:script>
    function initialiseData(){
        var recordVM = initialiseRecords('data-result-placeholder');
        var activityVM = initialiseActivities('data-result-placeholder');
        new RestoreTab('ul-project-records-activities', 'survey-all-data-records-tab');

        $('#ul-project-records-activities a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            if ('#survey-all-data-records' == e.currentTarget.hash) {
                recordVM.refreshPage();
            } else if ('#survey-all-data-activities' == e.currentTarget.hash) {
                activityVM.refreshPage();
            }
        });
    };
</r:script>