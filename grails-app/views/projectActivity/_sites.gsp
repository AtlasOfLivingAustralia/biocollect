<div id="pActivitySites" class="well">

    <!-- ko foreach: projectActivities -->
    <!-- ko if: current -->

    <g:render template="/projectActivity/warning"/>

    <div class="row-fluid">

        <div class="span12 text-left">
            <div class="btn-group btn-group-justified">
                <a class="btn btn-xs btn-default" data-bind="attr:{href: transients.siteCreateUrl}">Add new site</a>
                <a class="btn btn-xs btn-default" data-bind="attr:{href: transients.siteSelectUrl}">Choose existing sites</a>
                <a class="btn btn-xs btn-default" data-bind="attr:{href: transients.siteUploadUrl}">Upload locations from shapefile</a>
            </div>
        </div>

    </div>

    </br>

    <div class="row-fluid">

        <div class="span6 text-left">

            <span data-bind="if: sites().length == 0">
                <h4> No sites associated with this project.</h4>
            </span>
            <span data-bind="if: sites().length > 0">
                <h4> Sites associated with this project:</h4>
            </span>
            <!-- ko foreach: sites -->
                <div class="row-fluid">
                    <div class="span10 text-left">
                        <a target="_blank" data-bind="attr:{href: siteUrl}"><span data-bind="text: name"> </span></a>
                    </div>

                    <div class="span2 text-right">
                        <span data-bind="if: added()">
                            <small>
                                <a href="#" data-bind="click: removeSite" class="btn btn-small btn-danger" title="Remove">&lt;&lt;</a>
                            </small>
                        </span>
                        <span data-bind="if: !added()">
                            <small>
                                <a href="#" data-bind="click: addSite" class="btn btn-small btn-success" title="Add">&gt;&gt;</a>
                            </small>
                        </span>
                    </div>

                </div>
            <!-- /ko -->
        </div>

        <div class="span6 text-left">
            <h4 class="text-right"> Sites associated with this survey: <span class="req-field"></span></h4>
            <!-- ko foreach: sites -->
            <span data-bind="if: added()">
                <div class="row-fluid">
                    <div class="span12 text-right">
                        <i class="icon-check"> </i>
                        <a target="_blank" data-bind="attr:{href: siteUrl}"><span data-bind="text: name"> </span></a>
                    </div>
                </div>
            </span>
            <!-- /ko -->

        </div>

    </div>

    </br>
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

    <div class="row-fluid">
        <div class="span12">
            <button class="btn-primary btn block" data-bind="click: $parent.saveSites, disable: !transients.saveOrUnPublishAllowed()"> Save </button>
        </div>
    </div>

    <!-- /ko -->
    <!-- /ko -->
</div>
