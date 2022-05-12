<div id="pActivityPublish">
    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <!-- ko if: !published() -->
            <div class="row mt-4">
                <div class="col-12">
                    <h5 class="d-inline">Step 7 of 7 - Publish the survey to enter data</h5>
                    <g:render template="/projectActivity/status"/>
                </div>
            </div>

            <div class="alert alert-danger" data-bind="visible: !$root.isSurveyPublishable()">
                <span>Validation failed</span>
                <ol>
                    <li data-bind="visible:!isInfoValid()">
                        All mandatory fields in survey info tab needs to be filled. <div class="btn btn-sm btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-info-tab'}">Fill survey info</div>
                    </li>
                    <li data-bind="visible: !areSpeciesValid()">
                        Survey species constrain not set. <div class="btn btn-sm btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}">Set species</div>
                    </li>
                    <li data-bind="visible: !$root.isPActivityFormNameFilled()">
                        Survey data entry template not set.  <div class="btn btn-sm btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}">Set template</div>
                    </li>
                    <li data-bind="visible: !$root.isSiteSelected()">
                        Site not selected for this survey <div class="btn btn-sm btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-locations-tab'}">Choose survey site(s)</div>
                    </li>
                </ol>
            </div>

            <div class="row">
                <div class="col-12">
                    <p>The survey must be published to be accessible on the survey list for data entry.</p>
                    <p><strong>Note:</strong> If the survey is published and you wish to change anything on the &quot;species&quot;,
                    &quot;Survey form&quot; or &quot;Locations&quot; tabs, you must first &quot;Unpublish&quot; the survey.
                    All data already recorded for this survey will be lost if you do this. To retain existing data, end-date
                    the current survey and create a new one with the same details and changed configuration settings.</p>
                    <button class="btn btn-primary-dark btn-sm" data-bind="click: $root.updateStatus, disable: !$root.isSurveyPublishable()"><i class="fas fa-upload"></i> Publish</button>
                </div>
            </div>
            <!-- /ko -->

            <!-- ko if: published() -->
                <div class="row mt-4">
                    <div class="col-12">
                        <h5 class="d-inline">Step 7 of 7 - Survey is now publicly accessible</h5>
                        <g:render template="/projectActivity/status"/>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <p>
                            Unpublishing this survey will remove it from the survey list and allow you to change configuration settings. However, you cannot unpublish the survey whilst it has data associated with it as changing survey settings may adversely affect existing data. Therefore records must be deleted before the survey can be unpublished.
                        </p>
                    </div>
                </div>
                <div class="row">
                    <div class="col-12">
                        <button class="btn btn-danger btn-sm" data-bind="click: $root.updateStatus"><i class="far fa-times-circle"></i> Unpublish</button>
                    </div>
                </div>
            <!-- /ko -->
        <!-- /ko -->
    <!-- /ko -->
</div>