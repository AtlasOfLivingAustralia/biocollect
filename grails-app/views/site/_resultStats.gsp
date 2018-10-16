<div class="row-fluid">
    <div class="span12">
        <h4>Filter results</h4>
        <div class="row-fluid">
            <div class="span12">
                <button class="btn btn-small" data-bind="click: addRefineListToSelected"><i class="icon-filter">&nbsp;</i> Refine</button>
                <button class="btn btn-small" data-bind="click: removeAllSelectedFacets" style=""><i class="icon-remove-sign">&nbsp;</i>Clear all</button>
            </div>
        </div>
        <div data-bind="slideVisible: selectedFacets().length">
            <h4 data-bind="visible: selectedFacets().length"><g:message code="project.search.currentFilters"/></h4>
            <ul class="unstyled">
                <!-- ko foreach: selectedFacets -->
                <li class="row-fluid">
                    <span class="label-ellipsis span10"
                          data-bind="text: facet.metadata.displayName + ' : ' + displayName(), attr:{title:facet.metadata.displayName + ' : ' + displayName()}"></span>
                    <a href="#" class="span2" data-bind="click: $root.removeFacetTerm"><i class="icon-remove"></i></a>
                </li>
                <!-- /ko -->
            </ul>
        </div>
    </div>
</div>