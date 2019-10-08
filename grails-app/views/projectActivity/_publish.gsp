<div id="pActivityPublish" class="well">
    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <span data-bind="if: !published()">
            <div class="row-fluid">
                <div class="span10 text-left">
                    <h2 class="strong">Step 7 of 7 - Publish the survey to enter data</h2>
                </div>

                <div class="span2 text-right">
                    <g:render template="/projectActivity/status"/>
                </div>
            </div>

            <div class="alert alert-danger" data-bind="visible: !$root.isSurveyPublishable()">
                <span>Validation failed</span>
                <ol>
                    <li data-bind="visible:!isInfoValid()">
                        All mandatory fields in survey info tab needs to be filled. <div class="btn btn-mini btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-info-tab'}">Fill survey info</div>
                    </li>
                    <li data-bind="visible: !areSpeciesValid()">
                        Survey species constrain not set. <div class="btn btn-mini btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-species-tab'}">Set species</div>
                    </li>
                    <li data-bind="visible: !$root.isPActivityFormNameFilled()">
                        Survey data entry template not set.  <div class="btn btn-mini btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}">Set template</div>
                    </li>
                    <li data-bind="visible: !$root.isSiteSelected()">
                        Site not selected for this survey <div class="btn btn-mini btn-primary" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-locations-tab'}">Choose survey site(s)</div>
                    </li>
                </ol>
            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <p>The survey must be published to be accessible on the survey list for data entry.</p>
                    <p><strong>Note:</strong> If the survey is published and you wish to change anything on the &quot;species&quot;,
                    &quot;Survey form&quot; or &quot;Locations&quot; tabs, you must first &quot;Unpublish&quot; the survey.
                    All data already recorded for this survey will be lost if you do this. To retain existing data, end-date
                    the current survey and create a new one with the same details and changed configuration settings.</p>
                    <button class="btn btn-success btn-small" data-bind="click: $root.updateStatus, disable: !$root.isSurveyPublishable()">Publish</button>
                </div>
            </div>
            </span>

            <span data-bind="if: published()">
                <div class="row-fluid">
                    <div class="span10 text-left">
                        <p>
                            Unpublishing this survey will remove it from the survey list and allow you to change configuration settings. However, you cannot unpublish the survey whilst it has data associated with it as changing survey settings may adversely affect existing data. Therefore records must be deleted before the survey can be unpublished.
                        </p>
                    </div>
                    <div class="span2 text-right">
                        <g:render template="/projectActivity/status"/>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span12">
                        <button class="btn btn-primary btn-small" data-bind="click: $root.updateStatus">Unpublish</button>
                    </div>
                </div>
            </span>
        <!-- /ko -->
    <!-- /ko -->
</div>