<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach:facets -->
        <div class="row-fluid" data-bind="visible: terms().length">
            <button data-bind="click: toggle" class="btn btn-block btn-text-left">
                &nbsp;
                <i data-bind="css: {'icon-plus': !show(), 'icon-minus': show}"></i>
                <strong data-bind="text: metadata.displayName"></strong>
            </button>
            <div data-bind="slideVisible: show" class="facet-window">
                <!-- ko foreach: terms -->
                <label class="control-label checkbox" data-bind="visible:count, attr:{title:displayName}">
                    <input type="checkbox" data-bind="checked: checked"/>
                    <span data-bind="click: $root.addFacetTerm, attr: {title:displayName}" class="label-ellipsis"> <!-- ko text: displayName --> <!-- /ko --> (<span data-bind="text:count"></span>)</span>
                </label>
                <!-- /ko -->
            </div>
        </div>
        &nbsp;
        <!-- /ko -->
    </div>
</div>