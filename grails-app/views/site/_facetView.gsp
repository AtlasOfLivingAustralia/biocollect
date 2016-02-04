<bc:koLoading>
    <div class="row-fluid">
        <div class="span12">
            <h4><strong>Facets</strong></h4>
            <!-- ko foreach:facets -->
            <div class="row-fluid" data-bind="visible: terms().length">
                <h5><strong  data-bind="text: metadata.displayName"></strong></h5>
                <ul class="unstyled facet-window">
                    <!-- ko foreach: terms -->
                    <li data-bind="visible:count, click: $root.addFacetTerm"><a href="#"> <span data-bind="text:displayName"></span> (<span
                            data-bind="text:count"></span>)</a></li>
                    <!-- /ko -->
                </ul>
            </div>
            <!-- /ko -->
        </div>
    </div>
</bc:koLoading>