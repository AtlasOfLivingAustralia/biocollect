<div id="pActivitySites" class="well">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row-fluid">
        <div class="span10 text-left">
            <h2 class="strong">Step 6 of 7 - Specify the area or places where the survey will be undertaken</h2>
        </div>
        <div class="span2 text-right">
            <g:render template="../projectActivity/status"/>
        </div>
    </div>

    <g:render template="/projectActivity/warning"/>

    <g:render template="/projectActivity/unpublishWarning"/>

    <div class="row-fluid">
        <div class="span12 text-left">
            <p>You can constrain the survey to a particular geographic area and/or to particular pre-determined sites.</p>
        </div>
    </div>
    <h3>Add or remove sites to the survey</h3>
    <div class="row-fluid">
        <div class="span6 ">
            <table class="table white-background table-custom-border borderless">
                <thead>
                <tr>
                    <th class="text-left">Sites associated with this survey:
                        <span class="req-field"></span>
                        <a href="#" data-bind="popover: {content:'Sites listed here will be selectable on the data collection form. If you don\'t want a particular site to be available for selection in this survey, click the arrow to move it into the \'Sites associated with the project\' column. Note that the survey must have at least one site associated with it.'}"><i  class="icon-question-sign"></i></a>
                    </th>
                </tr>
                </thead>

                <tbody>
                <!-- ko foreach: sites -->
                <tr data-bind="visible: added()">
                    <td>
                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                        <button class="btn btn-mini pull-right btn-default" data-bind="click: removeSite"  title="Remove this site from survey">
                            <span class="icon-arrow-right"></span>
                        </button>

                    </td>
                </tr>
                <!-- /ko -->
                <!-- ko if: getNumberOfSitesForSurvey() == 0 -->
                <tr>
                    <td>
                        <i>Add sites to survey from the column on right using the <span class="icon-arrow-left"></span> button.</i>
                    </td>
                </tr>
                <!-- /ko -->
                </tbody>

            </table>
        </div>

        <div class="span6">
            <table class="table table-custom-border borderless white-background">
                <thead>
                <tr>
                    <th>Sites associated with this project:
                        <a href="#" data-bind="popover: {content:'Sites listed here are associated with the project, but are not used by this particular survey. If you want a particular site to be available for selection in this survey, click on the arrow to move it into the \'Sites associated with the survey\' column.'}"><i  class="icon-question-sign"></i></a>
                    </th>
                </tr>
                </thead>

                <tbody>
                <!-- ko foreach: sites -->
                <tr data-bind="visible: !added()">
                    <td>
                        <button class="btn btn-mini btn-primary" data-bind="click: addSite" title="Add this site to survey">
                            <span class="icon-arrow-left icon-white"></span>
                        </button>
                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl}, text: name"></a>
                    </td>
                </tr>
                <!-- /ko -->
                <!-- ko if:sites().length == 0 -->
                <tr>
                    <td>
                        No sites found in this project. Please use the above actions to add sites to this project.
                    </td>
                </tr>
                <!-- /ko -->
                </tbody>

            </table>
        </div>

    </div>
<div class="row-fluid">
    <h3>Or, add custom site using the below options</h3>
    <div class="">
        <div class="btn-group btn-group-justified">
            <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToCreate, disable: !transients.saveOrUnPublishAllowed()"><i class="icon-plus"></i> Add new site </button>
            <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToSelect, disable: !transients.saveOrUnPublishAllowed()"><i class="icon-folder-open"></i> Choose existing sites </button>
            <button class="btn-default btn btn-small block" data-bind="click: $parent.redirectToUpload, disable: !transients.saveOrUnPublishAllowed()"><i class="icon-arrow-up"></i> Upload locations from shapefile </button>
        </div>
    </div>
</div>
    <!--
    Not supported.
    <div class="row-fluid">

        <div class="span12">
            <p>
                <input type="checkbox" data-bind="checked: restrictRecordToSites"/> Restrict record locations to the selected survey sites
            </p>
        </div>

    </div>
    -->
    <!-- /ko -->
    <!-- /ko -->
</div>

<!-- ko foreach: projectActivities -->
    <!-- ko if: current -->
    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn btn-small block" data-bind="click: $parent.saveSites, disable: !transients.saveOrUnPublishAllowed()"><i class="icon-white  icon-hdd" ></i>  Save </button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-form-tab'}"><i class="icon-white icon-chevron-left" ></i>Back</button>
            <button class="btn-primary btn btn-small block" data-bind="showTabOrRedirect: {url:'', tabId: '#survey-publish-tab'}">Next <i class="icon-white icon-chevron-right" ></i></button>
        </div>
    </div>
    <!-- /ko -->
<!-- /ko -->