<!-- ko stopBinding: true -->
<h4>Survey settings</h4>
<p>Each of your surveys can be configured differently depending on your needs. Project level settings are inherited as the default.</p>
<p>Click on tabs to edit settings required. And new surveys to the project as required.</p>

<div id="pActivities" >

    <div class="tab-pane" id="admin-project-activity">

        <div class="row-fluid">

            <div class="span12 text-left">

                <!-- ko if: projectActivities().length > 0 -->
                 <span> <b> Select survey: </b></span>
                 <div class="btn-group">

                 <button type="button" class="btn btn-small btn-primary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <!-- ko  foreach: projectActivities -->
                        <span data-bind="if: current">
                           <span data-bind="text: name"></span> <span class="caret"></span>
                        </span>
                    <!-- /ko -->
                  </button>

                  <ul class="dropdown-menu" role="menu" style="height: auto;max-height: 200px;overflow-x: hidden;">
                    <!-- ko  foreach: projectActivities -->
                        <li>
                            <a href="#" data-bind="click: $root.setCurrent" >
                                <span data-bind="attr:{'class': published() ? 'badge badge-success' : 'badge badge-important'}">
                                <span data-bind="if:published()"> <small>P</small></span>
                                <span data-bind="if:!published()"> <small>X</small></span>
                                </span>
                                <span data-bind="text: name"></span>
                                <span data-bind="if: current"> <span class="badge badge-info">selected</span></span>
                            </a>
                        </li>
                        </br>
                    <!-- /ko -->
                  </ul>
                </div>
                <!-- /ko -->

                <div class="btn-group btn-group-horizontal">
                        <a class="btn btn-small btn-default" data-bind="click: addProjectActivity"> <i class="icon-plus"></i> Add Survey</a>
                </div>

             </div>

        </div>

        <!-- ko if: projectActivities().length > 0 -->
        <div class="row-fluid">
            <div class="span12 text-right">
                <a class="btn btn-small btn-danger" data-bind="click: deleteProjectActivity"> <i class="icon-remove icon-white"></i> Delete</a>
            </div>
        </div>

        <div id="project-activities-result-placeholder"></div>

        <div class="row-fluid">

            <div class="span12">

                <ul id="ul-survey-constraint-citizen-science" class="nav nav-pills">
                    <li class="active"><a href="#survey-info" id="survey-info-tab" data-toggle="tab">Survey Info</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-visibility" id="survey-visibility-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}, css:{disabled: !isSurveyInfoFormFilled()}">Visibility</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-alert" id="survey-alert-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}">Alert</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-form" id="survey-form-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}">Survey Form</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-species" id="survey-species-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}">Species</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-locations" id="survey-locations-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}">Locations</a></li>
                    <li data-bind="css:{disabled: !isSurveyInfoFormFilled()}"><a href="#survey-publish" id="survey-publish-tab" data-toggle="tab" data-bind="attr:{'data-toggle': dataToggleVal()}">Publish</a></li>
                </ul>

                <div class="pill-content">
                    <div class="pill-pane active" id="survey-info">
                        <span class="validationEngineContainer" id="project-activities-info-validation">
                            <g:render template="/projectActivity/info"/>
                        </span>
                    </div>

                    <div class="pill-pane" id="survey-visibility">
                        <span class="validationEngineContainer" id="project-activities-visibility-validation">
                            <g:render template="/projectActivity/visibility"/>
                        </span>
                    </div>

                    <div class="pill-pane" id="survey-alert">
                        <span class="validationEngineContainer" id="project-activities-alert-validation">
                            <g:render template="/projectActivity/surveyAlert"/>
                        </span>
                    </div>

                    <div class="pill-pane" id="survey-form">
                        <span class="validationEngineContainer" id="project-activities-form-validation">
                            <g:render template="/projectActivity/survey"/>
                        </span>
                    </div>
                    <div class="pill-pane" id="survey-species">
                        <span class="validationEngineContainer" id="project-activities-species-validation">
                            <g:render template="/projectActivity/species"/>
                        </span>
                    </div>


                    <div class="pill-pane" id="survey-locations">
                        <span class="validationEngineContainer" id="project-activities-locations-validation">
                            <g:render template="/projectActivity/sites"/>
                        </span>
                    </div>

                    <div class="pill-pane" id="survey-publish">
                        <g:render template="/projectActivity/publish"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- /ko -->
    </div>

    </span>

</div>
<!-- /ko -->

<asset:script type="text/javascript">
    function initialiseProjectActivitiesSettings(pActivitiesVM) {
        var pActivitiesSettingsVM = new ProjectActivitiesSettingsViewModel(pActivitiesVM, 'project-activities-result-placeholder');
        ko.applyBindings(pActivitiesSettingsVM, document.getElementById('pActivities'));

        // Delay subscription until the databinding has modified pActivity.pFormName if any
        if(pActivitiesSettingsVM.current()) {
            pActivitiesSettingsVM.current().transients.subscribeOrDisposePActivityFormName(true);
        }

        new RestoreTab('ul-survey-constraint-citizen-science', 'survey-info');
    };
</asset:script>

