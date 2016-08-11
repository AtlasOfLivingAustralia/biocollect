<h3>Refine results</h3>
<span data-bind="if: $root.transients.loading()">Loading...</span>
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
<!-- /ko -->

<div class="row-fluid" data-bind="if: refinementSelected() || selectedFilters().length > 0">
    <div class="span12">
        <button class="button btn-sm btn-default" data-bind="click: refineSearch, visible: refinementSelected()"><i class="fa fa-filter">&nbsp;</i>Refine</button>
        <button class="button btn-sm btn-default" data-bind="click: removeUserSelectedFacet, visible: selectedFilters().length > 0"><i class="fa fa-times-circle-o">&nbsp;</i>Reset</button>
    </div>
</div>

<div class="panel-group" id="facet-accordion">
    <!-- ko foreach: facets -->
    <div data-bind="visible: visible" class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <span data-bind="attr:{class: filter() ? 'icon-chevron-right' : 'icon-chevron-down'}"></span>
                <a role="button" data-toggle="collapse" data-parent="#facet-accordion"
                   data-bind="text: displayText, attr:{ href: '#facets_accordion_' + $index()+1}, click: toggleFilter()"></a>
            </h4>
        </div>

        <div data-bind="attr:{id: 'facets_accordion_' + $index()+1}" class="panel-collapse collapse">
            <div class="margin-left-1 input-append" data-bind="visible: showFilter()">
                <input type="text" placeholder="Filter facets" data-bind="value: searchTerm"/><button class="btn"><i class="icon-filter"></i></button>
            </div>
            <div class="panel-body facet-block">
                <!-- ko foreach : terms -->
                <div class="margin-left-1" data-bind="visible: showTerm">
                    <span>
                        <input type="checkbox" data-bind="attr: {id: term}, checked: selected">
                        <a href="#" data-bind="click: $root.addUserSelectedFacet,text: displayText"></a>
                    </span> </br>
                </div>
                <!-- /ko -->
            </div>
        </div>
    </div>
    <!-- /ko -->
</div>
