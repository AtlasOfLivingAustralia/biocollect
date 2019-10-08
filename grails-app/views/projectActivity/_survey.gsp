<div id="pActivitySurvey" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
            <g:render template="/bioActivity/previewTemplate" ></g:render>


            <div class="row-fluid">
                <div class="span10 text-left">
                    <h2 class="strong">Step 4 of 7 - Choose a data entry form template for the survey</h2>
                </div>
                <div class="span2 text-right">
                    <g:render template="/projectActivity/status"/>
                </div>
            </div>

            <g:render template="/projectActivity/warning"/>

            <div class="row-fluid">
                <div class="span12">
                    <p>You can choose one of the existing form templates listed. If none of these are appropriate for you requirements,
                    please contact <a href="mailto:support@ala.org.au?subject=BioCollect enquiry">support@ala.org.au.</a></p>
                </div>
            </div>

            </br>

            <div class="row-fluid">
                <div class="span3 text-left">
                    <label class="control-label" for="template"> Select a form template: <span class="req-field"></span></label>
                </div>
                <div class="span4 text-left">
                    <div class="controls">
                        <select id="template" style="width:98%;" data-validation-engine="validate[required]" data-bind="options: $root.formNames, value: pActivityFormName, optionsCaption: 'Please select'" ></select>
                        <a class="btn btn-small btn-default" href="" data-bind="click: function() {previewActivity('<g:createLink controller="bioActivity" action="previewActivity"/>', pActivityFormName())}"> <i class="icon-eye-open"></i> Preview Survey</a>
                    </div>
                </div>
            </div>
            <!-- /ko -->
        <!-- /ko -->
</div>

<!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn block btn-small" data-bind="click: $parent.saveForm"><i class="icon-white  icon-hdd" ></i>  Save </button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-alert-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
        </div>
    </div>
    <!-- /ko -->
<!-- /ko -->