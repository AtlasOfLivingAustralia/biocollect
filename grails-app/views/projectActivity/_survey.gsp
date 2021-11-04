<div id="pActivitySurvey">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
            <g:render template="/bioActivity/previewTemplate" ></g:render>


            <div class="row mt-4">
                <div class="col-12">
                    <h5 class="d-inline">Step 4 of 7 - Choose a data entry form template for the survey</h5>
                    <g:render template="/projectActivity/status"/>
                </div>
            </div>

            <g:render template="/projectActivity/warning"/>

            <div class="row">
                <div class="col-12">
                    <p>You can choose one of the existing form templates listed. If none of these are appropriate for you requirements,
                    please contact <a href="mailto:support@ala.org.au?subject=BioCollect enquiry">support@ala.org.au.</a></p>
                </div>
            </div>

            <div class="row mt-2 form-group">
%{--                <div >--}%
                <label class="col-4 col-form-label" for="template"> Select a form template: <span class="req-field"></span></label>
%{--                </div>--}%
                <div class="col-8">
                    <div class="btn-space">
                        <select class="form-control" id="template" data-validation-engine="validate[required]" data-bind="options: $root.formNames, value: pActivityFormName, optionsCaption: 'Please select'" ></select>
                        <button class="btn btn-sm btn-primary-dark" data-bind="click: function() {previewActivity('<g:createLink controller="bioActivity" action="previewActivity"/>', pActivityFormName())}"> <i class="far fa-eye"></i> Preview Survey</button>
                    </div>
                </div>
            </div>
            <!-- /ko -->
        <!-- /ko -->
</div>

<!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row">
        <div class="col-12">
            <button class="btn-primary-dark btn btn-sm" data-bind="click: $parent.saveForm"><i class="fas fa-hdd"></i> Save</button>
            <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-alert-tab'}"><i
                    class="far fa-arrow-alt-circle-left"></i> Back</button>
            <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}"><i
                    class="far fa-arrow-alt-circle-right"></i> Next</button>
        </div>
    </div>
    <!-- /ko -->
<!-- /ko -->