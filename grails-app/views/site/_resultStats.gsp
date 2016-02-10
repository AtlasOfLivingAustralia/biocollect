<div class="row-fluid">
    <div class="span12">
        <h4><strong>Search result</strong></h4>
        <span data-bind="text: pagination.totalResults"></span> sites found.
        <div data-bind="slideVisible: selectedFacets().length">
            <h4><strong>Selected filters</strong></h4>
            <!-- ko foreach: selectedFacets -->
            <a class="label inline-flex margin-bottom-5" href="#" data-bind="click: $root.removeFacetTerm">
                <span class="label-ellipsis"
                      data-bind="text: facet.metadata.displayName + ' : ' + displayName(), attr:{title:facet.metadata.displayName + ' : ' + displayName()}"></span>&nbsp;
                <i class="icon-remove-circle icon-white"></i>
            </a>
            <!-- /ko -->
        </div>
        <div>
            <button class="button btn-sm btn-default" data-bind="click: removeAllSelectedFacets, visible: selectedFacets().length" style=""><i class="fa fa-times-circle-o">&nbsp;</i>Reset</button>
            <button class="button btn-sm btn-default" data-bind="click: addRefineListToSelected, visible: refineList().length"><i class="fa fa-filter">&nbsp;</i> Refine</button>
        </div>
    </div>
</div>