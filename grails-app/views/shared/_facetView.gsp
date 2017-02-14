<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach: facets -->
        <div class="row-fluid" data-bind="visible: isAnyTermVisible">
            <button data-bind="click: toggleState" class="btn btn-block btn-text-left">
                &nbsp;
                <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}" class="vertical-align-top"></i>
                <strong data-bind="text: displayName"></strong>
                <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'right', content: helpText }">
                    <i class="icon-question-sign vertical-align-top">&nbsp;</i>
                </a>
            </button>
            <div data-bind="slideVisible: state() == 'Expanded'" class="margin-top-5">
                <!-- ko foreach: terms -->
                <label class="control-label checkbox" data-bind="visible: !refined()">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}"></span>
                </label>
                <!-- /ko -->
            </div>
        </div>
        &nbsp;
        <!-- /ko -->
    </div>
</div>