<div id="pActivitySurvey" class="well">

        <!-- ko foreach: projectActivities -->
            <!-- ko if: current -->
            <g:render template="/projectActivity/warning"/>
            <h5>Select a form template  OR build new form for your survey</h5>
            <br/>

            <div class="row-fluid">
                <div class="span2 text-right">
                    <label class="control-label" for="template"> Select a form template : </label>
                </div>
                <div class="span4 text-left">
                    <div class="controls">
                        <select id="template" style="width:98%;" data-validation-engine="validate[required]" data-bind="options: $root.formNames, value: pActivityFormName, optionsCaption: 'Please select'" ></select>
                    </div>
                </div>
                <div class="span1 text-left">
                  <b>(OR)</b>
                </div>
                <div class="span4 text-left">
                    <button class="btn-default btn block"> Build new form </button>
                </div>

            </div>

             <br/>
             <div class="row-fluid">
                <div class="span2 text-right"></div>
                <div class="span8 text-left">

                 <!-- ko foreach: pActivityFormImages -->
                    <a data-bind="attr:{href:url}" target="_blank">
                        <img src="" data-bind="attr:{src: thumbnail}" height="200" width="200"/>
                    </a>
                 <!-- /ko -->

                </div>
             </div>

            <!-- /ko -->
        <!-- /ko -->

    <br/>

    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn block" data-bind="click: saveForm"> Save </button>
        </div>
    </div>
</div>


