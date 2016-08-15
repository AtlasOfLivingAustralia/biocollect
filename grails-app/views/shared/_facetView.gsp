<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach: facets -->
        <div class="row-fluid" data-bind="visible: isAnyTermVisible">
            <h5 data-bind="text: displayName"></h5>
            <!-- ko foreach: terms -->
                <label class="control-label checkbox" data-bind="visible: !refined()">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}"></span>
                </label>
            <!-- /ko -->
        </div>
        <!-- /ko -->
    </div>
</div>