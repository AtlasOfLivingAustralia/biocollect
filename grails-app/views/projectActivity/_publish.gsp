<div id="pActivityPublish" class="well">
    <!-- ko foreach: projectActivities -->
        <!-- ko if: current -->
            <span data-bind="if: !published()">
            <div class="row-fluid">
                <div class="span10 text-left">
                    <h2 class="strong">Step 7 of 7 - Publish the survey to enter data</h2>
                </div>

                <div class="span2 text-right">
                    <g:render template="../projectActivity/status"/>
                </div>
            </div>

            <div class="row-fluid">
                <div class="span12 text-left">
                    <p>The survey must be published to be accessible on the survey list for data entry.</p>
                    <button class="btn btn-success btn-small" data-bind="click: $root.updateStatus">Publish</button>
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
                        <g:render template="../projectActivity/status"/>
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