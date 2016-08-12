<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach:facets -->
        <div class="row-fluid" data-bind="visible: terms().length">
            <h5 data-bind="text: displayName"></h5>
            <!-- ko foreach: terms -->
                <label class="control-label checkbox">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow"></span>
                </label>
            <!-- /ko -->
        </div>
        <!-- /ko -->
    </div>
</div>