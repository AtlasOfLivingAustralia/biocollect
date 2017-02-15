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
            <ul>
                <!-- ko foreach:selectedFacets -->
                <li><strong data-bind="if: exclude">[EXCLUDE]</strong> <span data-bind="text: displayNameWithoutCount()"></span><a href="#" data-bind="click: remove"><i class="icon-remove"></i></a></li>
                <!-- /ko  -->
            </ul>
        </div>
        <div id="filters-hidden">
            <div id="pt-searchControls" class="row-fluid">
                <g:render template="/shared/facetView"></g:render>
            </div>

            <div class="row-fluid">
                <div class="span12">
                    <h5><g:message code="project.search.geoFilter"/>
                        <a href="#" tabindex="-1" data-bind="popover: {placement:'right', content: '<g:message code="project.search.geoFilter.helpText"/>' }">
                            <i class="icon-question-sign">&nbsp;</i>
                        </a></h5>
                    <div class="row-fluid">
                        <!-- Trigger the modal with a button -->
                        <button id="filterByRegionButton" type="button" class="btn btn-small btn-info margin-bottom-2" data-toggle="modal" data-target="#mapModal"><g:message code="project.search.mapToggle"/></button>

                        <!-- Modal -->
                        %{--inline style is required as the first time so the modal does not block other components on screen--}%
                        %{--Looks like a bug in Bootstrap--}%
                        <div id="mapModal" class="modal fade" role="dialog" style="display: none; ">
                            <div class="modal-dialog ">

                                <!-- Modal content-->
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                                        <h4 class="modal-title"><g:message code="project.search.mapToggle"/></h4>
                                    </div>
                                    <div class="modal-body">
                                        <m:map id="mapFilter" width="100%"/>
                                    </div>
                                    <div class="modal-footer">
                                        <button id="clearFilterByRegionButton" type="button" class="btn btn-small btn-info"
                                                 ><i class="toggleIndicator icon-remove icon-white"></i> <g:message code="project.search.mapClear"/></button>
                                        <button type="button" class="btn btn-primary btn-small" data-dismiss="modal"><i
                                                class="toggleIndicator icon-chevron-right icon-white"></i> <g:message code="project.search.mapClose"/></button>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /ko -->