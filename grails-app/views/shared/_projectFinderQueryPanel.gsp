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
            <button class="btn btn-sm btn-dark" data-target="#mapModal" data-toggle="modal">
                <i class="far fa-map"></i>
                Filter by geographic location
%{--                <a href="#" tabindex="-1" data-bind="popover: {placement:'right', content: '<g:message--}%
%{--                        code="project.search.geoFilter.helpText"/>' }">--}%
%{--                    <i class="fas fa-info-circle"></i>--}%
%{--                </a>--}%
            </button>
        </div>

%{--        <div class="row-fluid">--}%
%{--            <div class="span12">--}%
%{--                <h5><g:message code="project.search.geoFilter"/>--}%
%{--                    <a href="#" tabindex="-1" data-bind="popover: {placement:'right', content: '<g:message--}%
%{--                            code="project.search.geoFilter.helpText"/>' }">--}%
%{--                        <i class="icon-question-sign">&nbsp;</i>--}%
%{--                    </a>--}%
%{--    </h5>--}%

%{--                <div class="row-fluid">--}%
%{--                    <!-- Trigger the modal with a button -->--}%
%{--                    <button id="filterByRegionButton" type="button" class="btn btn-small btn-info margin-bottom-2"--}%
%{--                            data-toggle="modal" data-target="#mapModal"><g:message--}%
%{--                            code="project.search.mapToggle"/></button>--}%
%{--                </div>--}%
%{--            </div>--}%
%{--        </div>--}%
    </div>
</div>
<g:render template="/shared/facetModalChooseMore"/>
<!-- ko stopBinding: true -->
<div id="mapModal" class="modal" role="dialog">
    <div class="modal-dialog ">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title"><g:message code="project.search.mapToggle"/></h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <m:map id="mapFilter" width="100%" imageLocation="${assetPath(src:"/leaflet/images")}"/>
            </div>

            <div class="modal-footer">
                <button id="clearFilterByRegionButton" type="button"
                        class="btn btn-sm btn-dark"><i
                        class="toggleIndicator far fa-times-circle"></i> <g:message
                        code="project.search.mapClear"/></button>
                <button type="button" class="btn btn-sm btn-primary-dark" data-dismiss="modal" aria-label="Close">
                    <i class="far fa-arrow-alt-circle-right"></i>
                    <g:message
                            code="project.search.mapClose"/>
                </button>
%{--                <button type="button" class="btn btn-primary-dark btn-sm" data-dismiss="modal"><i--}%
%{--                        class=""></i> <g:message--}%
%{--                        code="project.search.mapClose"/></button>--}%
            </div>
        </div>

    </div>
</div>
<!-- /ko -->
<!-- /ko -->