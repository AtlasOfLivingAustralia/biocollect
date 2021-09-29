<div class="filter-group">
    <!-- ko foreach:facets -->
    <!-- ko if: terms().length -->
    <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-bind="text: metadata.displayName, attr: { 'data-target': '#' + name()}" aria-expanded="false" aria-controls="types">

    </button>
    <div class="accordion-body collapse" data-bind="attr: { id: name}">
        <!-- ko foreach: terms -->
%{--        <div class="custom-checkbox">--}%
%{--            <input type="checkbox" name="types" data-bind="checked: checked, attr: {id: term}">--}%
%{--            <label class="label-ellipsis" data-bind="click: $root.addFacetTerm, attr: {title:displayName, for: term}"><!-- ko text: displayName --> <!-- /ko --> (<span data-bind="text:count"></span>)</label>--}%
%{--        </div>--}%
        <div class="form-check form-check-inline">
            <input class="form-check-input" type="checkbox" data-bind="checked: checked, attr: {id: term}">
            <label class="form-check-label label-ellipsis" data-bind="click: $root.addFacetTerm, attr: {title:displayName, for: term}"><!-- ko text: displayName --> <!-- /ko --> (<span data-bind="text:count"></span>)</label>
        </div>
        <!-- /ko -->
    </div>
    <!-- /ko -->
    <!-- /ko -->
</div>