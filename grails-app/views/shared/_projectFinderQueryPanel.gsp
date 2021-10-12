<g:set var="modalName" value="${modalId ?: 'chooseMore'}"></g:set>
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
        <g:render template="/shared/facetView"></g:render>

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
<div id="${modalName}" class="modal" role="dialog" tabindex="-1">
    <div class="modal-dialog ">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title" data-bind="text: displayTitle('<g:message code="facet.dialog.more.title"
                                                                                    default="Filter by"/>')"></span>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <div class="row mb-3">
                    <div class="input-group input-group-sm col-12">
                        <input class="form-control" type="text" placeholder="Search" data-bind="value: searchText">
                        <div class="input-group-append">
                            <button class="btn btn-dark">
                                <i class="fas fa-filter"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- ko foreach: showMoreTermList -->
                <label class="form-check" data-bind="visible: showTerm()">
                    <input class="form-check-input" type="checkbox" data-bind="checked: checked">
                    <label class="form-check-label"
                           data-bind="text:displayName, click: filterNow, attr:{title: displayName}"
                           data-dismiss="modal"></label>
                </label>
                <!-- /ko -->
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-outline-dark" data-bind="click: includeSelection"
                        data-dismiss="modal">
                    <i class="fas fa-plus-circle"></i>
                    <g:message code="facet.dialog.more.include" default="INCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-sm btn-outline-dark" data-bind="click: excludeSelection"
                        data-dismiss="modal">
                    <i class="fas fa-minus-circle"></i>
                    <g:message code="facet.dialog.more.exclude" default="EXCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-sm btn-danger" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                    <g:message code="facet.dialog.more.close" default="Close"/>
                </button>

            </div>
        </div>

    </div>
</div>
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
                <m:map id="mapFilter" width="100%"/>
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