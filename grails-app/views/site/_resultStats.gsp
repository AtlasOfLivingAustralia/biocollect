<bc:koLoading>
    <div class="row-fluid">
        <div class="span12">
            <strong><span data-bind="text: pagination.totalResults"></span> results found.</strong>

            <div data-bind="visible: selectedFacets().length">
                <strong>Selected filters :</strong>
                <!-- ko foreach: selectedFacets -->
                <a class="label inline-flex margin-bottom-5" href="#" data-bind="click: $root.removeFacetTerm">
                    <span class="label-ellipsis"
                          data-bind="text: facet.metadata.displayName + ' : ' + displayName(), attr:{title:facet.metadata.displayName + ' : ' + displayName()}"></span>
                    <i class="icon-remove-circle icon-white"></i>
                </a>
                <!-- /ko -->
            </div>
        </div>
    </div>
</bc:koLoading>