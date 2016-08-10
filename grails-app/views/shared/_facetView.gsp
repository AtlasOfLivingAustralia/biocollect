<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach:facets -->
        <div class="row-fluid" data-bind="visible: terms().length">
            <h5 data-bind="text: displayName"></h5>
            <!-- ko foreach: terms -->
                <div class="row-fluid">
                    <div>
                        <button data-bind="visible:count, attr:{title:displayName}, css:{active: checked}" type="button" class="btn btn-info as-checkbox btn-small" data-toggle="button">
                            <i class="pull-left toggleIndicator fa fa-check-square-o" data-bind="click: toggle"></i>
                            <i class="pull-left toggleIndicator fa fa-square-o" data-bind="click: toggle"></i>
                            <a href="#" class="inline-flex" data-bind="click: toggle">
                                <span class="label-ellipsis" data-bind="text:displayName"></span></a>
                        </button>
                    </div>
                </div>
            <!-- /ko -->
        </div>
        <!-- /ko -->
    </div>
</div>