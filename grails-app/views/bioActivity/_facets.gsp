<h3>Refine results</h3>
<!-- ko if: selectedFilters().length > 0 -->
<div class="row-fluid">
    <div class="span12">
        Results refined by:
        <ul>
        <!-- ko foreach : selectedFilters -->
            <li>
                <span data-bind="text: facetDisplayName"></span>: <span data-bind="text: term"></span>
                <a data-bind="click: $parent.removeFilter" class="btn btn-inverse btn-mini tooltips" title="remove filter">X</a>
            </li>
        <!-- /ko -->
        </ul>
    </div>
</div>

<div class="row-fluid">
    <div class="span12">
        <button class="button btn-sm btn-default" data-bind="click: removeUserSelectedFacet">Reset</button>
    </div>
</div>
<!-- /ko -->

<div class="panel-group" id="facet-accordion">
    <!-- ko foreach: facets -->
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <span data-bind="attr:{class: filter() ? 'icon-chevron-right' : 'icon-chevron-down'}"></span>
                <a role="button" data-toggle="collapse" data-parent="#facet-accordion"
                   data-bind="text: displayText, attr:{ href: '#facets_accordion_' + $index()+1}, click: toggleFilter()"></a>
            </h4>
        </div>

        <div data-bind="attr:{id: 'facets_accordion_' + $index()+1}" class="panel-collapse collapse">
            <div class="panel-body">
                <!-- ko foreach : terms -->
                <div class="margin-left-1">
                    <span>
                        <a href="#" data-bind="click: $root.addUserSelectedFacet,text: displayText"></a>
                    </span> </br>
                </div>
                <!-- /ko -->
            </div>
        </div>
    </div>
    <!-- /ko -->
</div>
