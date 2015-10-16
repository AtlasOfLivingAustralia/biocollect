<div id="project-all-data">

    <div class="row-fluid">
        <div class="span12">

            <div class="span12">
                <ul class="nav nav-tabs" id="ul-project-records-activities">
                    <li><a href="#survey-all-data-records" id='survey-all-data-records-tab' data-toggle="tab">Records</a></li>
                    <li><a href="#survey-all-data-activities" id='survey-all-data-activities-tab' data-toggle="tab">Surveys</a></li>
                </ul>

                <div class="tab-content clearfix">
                    <div class="tab-pane" id="survey-all-data-records">
                        <h5>
                            <g:render template="../bioActivity/allRecords" model="[show:false]"/>
                        </h5>
                    </div>

                    <div class="tab-pane" id="survey-all-data-activities">
                        <h5>
                            <g:render template="../bioActivity/allActivities" model="[show:false]"/>
                        </h5>
                    </div>

                </div>

            </div>

        </div>

    </div>

</div>


<r:script>
    function initialiseData(){
        initialiseActivities();
        initialiseRecords();
        new RestoreTab('ul-project-records-activities', 'survey-all-data-records-tab');
    };
</r:script>