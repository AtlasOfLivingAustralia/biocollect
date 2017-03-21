<!-- ko with: filterViewModel-->
<div class="row-fluid">
    <div id="pt-selectors" class="well">
        <h4><g:message code="project.search.heading"/></h4>
        <div id="filter-buttons">
            <button class="btn btn-small facetSearch" data-bind="click: mergeTempToRefine"><i class="icon-filter"></i>Refine</button>
            <button class="btn btn-small clearFacet" data-bind="click: $root.reset"><i class="icon-remove-sign"></i>Clear all</button>
        </div>
        <div>
            <h4 data-bind="visible: selectedFacets().length"><g:message code="project.search.currentFilters"/></h4>
            <ul class="unstyled">
                <!-- ko foreach:selectedFacets -->
                <li class="row-fluid">
                    <strong class="span4 label-ellipsis" data-bind="visible: exclude " title="Exclude">[EXCLUDE]</strong>
                    <span class="label-ellipsis display-inline-block span6"
                          data-bind="text: displayNameWithoutCount(), attr:{title: displayNameWithoutCount()}">
                    </span>
                    <a class="span2" href="#" data-bind="click: remove"><i class="icon-remove"></i></a>
                </li>
                <!-- /ko  -->
            </ul>
        </div>
        <div id="filters-hidden">
            <div id="pt-searchControls" class="row-fluid">
                <g:render template="/shared/facetView"></g:render>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->