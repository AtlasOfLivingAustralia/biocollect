<div id="pActivityAlert">

    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <div class="row mt-4">
                <div class="col-12">
                    <h5 class="d-inline">Step 3 of 7 - Set Alert</h5>
                    <g:render template="/projectActivity/status"/>
                </div>

            </div>

            <g:render template="/projectActivity/warning"/>

            <div class="row mt-2">
                <div class="col-12">
                    <g:render template="/projectActivity/speciesAlert"/>
                </div>
             </div>

            <div class="row mt-2">
                <div class="col-12">
                    <g:render template="/projectActivity/emailList"/>
                </div>
            </div>

            <div class="row">

                <div class="col-12">
                    <button class="btn-primary-dark btn btn-sm"
                            data-bind="click: $parent.saveAlert"><i class="fas fa-hdd"></i>  Save</button>
                    <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-visibility-tab'}">
                        <i
                                class="far fa-arrow-alt-circle-left"></i> Back</button>
                    <button class="btn-dark btn btn-sm" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}">
                        <i
                                class="far fa-arrow-alt-circle-right"></i> Next</button>
                </div>

            </div>

        <!-- /ko -->
    <!-- /ko -->
</div>
