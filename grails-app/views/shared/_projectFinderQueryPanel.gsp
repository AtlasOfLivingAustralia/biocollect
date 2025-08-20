<!-- ko with: filterViewModel-->
<div id="filters" class="collapse show expander overflow-auto project-finder-filters">
    <button data-toggle="collapse" data-target=".expander" aria-expanded="true" aria-controls="expander" class="close"
            title="Close Filters">
        <i class="far fa-times-circle"></i>
    </button>

    <div class="title">
        <h3><g:message code="label.filters"/></h3>
        <button type="button" class="btn btn-sm btn-dark refine"
                data-bind="click: mergeTempToRefine"
                aria-label="Refine Projects"><i class="fas fa-filter"></i> Refine</button>
    </div>

    <div id="filters-group">
        <g:render template="/shared/facetView" model="[modalName: 'chooseMore']"></g:render>

        <div class="filters-footer">
            <button class="btn btn-light custom-font accordion-header" data-target="#mapModal" data-toggle="modal">
                <i class="far fa-map"></i>
                Filter by geographic location
            </button>
        </div>
    </div>
</div>
<g:render template="/shared/facetModalChooseMore"/>
<div id="mapModal" class="modal" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title"><g:message code="project.search.mapToggle"/></h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <!-- Only the map body(Leaflet map) is shielded from KO -->
            <div class="modal-body" data-bind="stopBinding: true">
                <m:map id="mapFilter" width="100%" imageLocation="${assetPath(src:"/leaflet/images")}"/>
            </div>

            <div class="modal-footer">
                <g:if test="${hubConfig?.content?.enableNationalProjectsExclusionFilter}">
                    <div class="checkbox">
                        <input type="checkbox" data-bind="checked: nationwideProjCheckbox">
                        <g:message code="project.search.excludeNationalProject"/>
                    </div>
                </g:if>

                <button id="clearFilterByRegionButton" type="button" class="btn btn-sm btn-danger">
                    <i class="toggleIndicator far fa-trash-alt"></i>
                    <g:message code="project.search.mapClear"/>
                </button>

                <button type="button" class="btn btn-sm btn-primary-dark" data-dismiss="modal" aria-label="Close">
                    <i class="far fa-arrow-alt-circle-right"></i>
                    <g:message code="project.search.mapClose"/>
                </button>
            </div>

        </div>
    </div>
</div>
<!-- /ko -->