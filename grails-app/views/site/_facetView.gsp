<div class="row-fluid">
    <div class="span12">
        <h4><strong>Facets</strong></h4>
        <!-- ko foreach:facets -->
        <div class="row-fluid" data-bind="visible: terms().length">
            <h5><a href="#" data-bind="click: toggle"> <span data-bind="css:{ 'icon-chevron-right': !show(), 'icon-chevron-down': show}"></span><span  data-bind="text: metadata.displayName"></span> (<span data-bind="text:total"></span>)</a></h5>
            <ul data-bind="slideVisible: show" class="unstyled facet-window">
                <!-- ko foreach: terms -->
                <li data-bind="visible:count, attr:{title:displayName}">
                    <input type="checkbox" data-bind="attr: {id: term}, checked: checked">
                    <a href="#" class="inline-flex" data-bind="click: $root.addFacetTerm"> <span class="label-ellipsis" data-bind="text:displayName"></span>&nbsp;(<span data-bind="text:count"></span>)</a>
                </li>
                <!-- /ko -->
            </ul>
        </div>
        <!-- /ko -->
    </div>
</div>