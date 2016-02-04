<bc:koLoading>
    <div class="row-fluid">
        <div class="span12">
            <span data-bind="text: pagination.totalResults"></span> results found.
            <span data-bind="visible: selectedFacets().length">
                Selected filters :
                <!-- ko foreach: selectedFacets -->
                <a class="label" href="#" data-bind="click: $root.removeFacetTerm">
                    <span data-bind="text: facet.metadata.displayName"></span> : <span
                        data-bind="text: displayName"></span> <i class="icon-remove-circle icon-white"></i>
                </a>
                <!-- /ko -->
            </span>
        </div>
    </div>
</bc:koLoading>