<div id="pActivityAlert" class="well">

    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <div class="row-fluid">
                <div class="span10 text-left">
                    <h2 class="strong">Step 3 of 7 - Set Alert</h2>
                </div>

                <div class="span2 text-right">
                    <g:render template="/projectActivity/status"/>
                </div>

            </div>

            <g:render template="/projectActivity/warning"/>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <g:render template="/projectActivity/speciesAlert"/>
                </div>
             </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <g:render template="/projectActivity/emailList"/>
                </div>
            </div>

            <div class="row-fluid">

                <div class="span12">
                    <button class="btn-primary btn block btn-small"
                            data-bind="click: $parent.saveAlert"><i class="icon-white icon-hdd" ></i>  Save</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-visibility-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
                    <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
                </div>

            </div>

        <!-- /ko -->
    <!-- /ko -->
</div>
