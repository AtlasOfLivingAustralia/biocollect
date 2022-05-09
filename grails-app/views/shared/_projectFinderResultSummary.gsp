<div id="sortBar" class="row d-flex">
    <div class="col-12 col-md-4 offset-md-8 py-2 text-right mb-3">
        <div class="input-group">
            <input id="pt-search" type="text" class="form-control" placeholder="<g:message code="projectfinder.search"/>" aria-label="<g:message code="projectfinder.search"/>" aria-describedby="pt-search-link">
            <div class="input-group-append">
                <button class="btn btn-primary-dark" type="button" id="pt-search-link"><i class="fas fa-search"></i></button>
            </div>
        </div>
    </div>
    <div class="col-6 col-md-4 mb-3 order-1 order-md-0">
        <button class="btn btn-dark project-finder-filters-expander" data-toggle="collapse" data-target=".expander" aria-expanded="true" aria-controls="expander" title="Filter Projects">
            <i class="fas fa-filter"></i> Filter Projects
        </button>
    </div>
    <div class="col-6 col-sm-6 col-md-4 mb-3 text-right text-md-center order-2 order-md-1">
        <div class="btn-group" role="group" aria-label="Catalogue Display Options">
            <div class="btn-group nav nav-tabs project-finder-tab" role="group" aria-label="Catalogue Display Options">
                <a class="btn btn-outline-dark active" id="grid-tab" data-toggle="tab" title="View as Grid" href="#grid" role="tab" aria-controls="View as Grid" aria-selected="true">
                    <i class="fas fa-th-large"></i></a>
                <a class="btn btn-outline-dark" id="list-tab" data-toggle="tab" title="View as List" href="#list" role="tab" aria-controls="View as List">
                    <i class="fas fa-list"></i></a>
%{-- todo : uncomment when all project area can be shown without pagination--}%
%{--                <a class="btn btn-outline-dark" id="map-tab" data-toggle="tab" title="View as Images" href="#map" role="tab" aria-controls="View on Map">--}%
%{--                    <i class="far fa-map"></i></a>--}%
            </div>
            %{--                    <button type="button" class="btn btn-outline-dark active" title="View as Grid"><i class="fas fa-th-large"></i></button>--}%
            %{--                    <button type="button" class="btn btn-outline-dark" title="View as List"><i class="fas fa-list"></i></button>--}%
            %{--                    <button type="button" class="btn btn-outline-dark" title="View as Map"><i class="far fa-map"></i></button>--}%
        </div>
    </div>
    <div class="col-12 col-md-4 text-center text-md-right order-0 order-md-2 pl-0 d-flex justify-content-end justify-content-md-end">
        <div class="form-group">
            <label for="sortBy" class="col-form-label">Sort by</label>
            <select id="sortBy" class="form-control col custom-select" data-bind="value: sortBy" aria-label="Sort Order">
                <option value="dateCreatedSort">Most Recent</option>
                <option value="nameSort">Name</option>
                <option value="_score">Relevance</option>
                <option value="organisationSort">Organisation</option>
            </select>
        </div>
        <div class="form-group ml-2 projects-from-select">
            <label for="projectsFrom" class="col-form-label">Projects from</label>
            <select id="projectsFrom" class="form-control col custom-select" data-bind="value: isWorldWide" aria-label="Projects from">
                <option value="false">Australia</option>
                <option value="true">Global</option>
            </select>
        </div>
    </div>
</div>

<div class="filter-bar d-flex align-items-center my-0">
    <h4>Applied Filters: </h4>
    <!-- ko if: isGeoSearchEnabled -->
    <button class="filter-item btn btn-sm btn-outline-dark"> <g:message code="projectfinder.geofilter"/> <span class="remove" data-bind="click: clearGeoSearch"><i class="far fa-trash-alt"></i></span></button>
    <!-- /ko -->
    <!-- ko foreach: filterViewModel.selectedFacets -->
    <button class="filter-item btn btn-outline-dark btn-sm"><strong data-bind="if: exclude">[EXCLUDE]</strong> <!-- ko text: displayNameWithoutCount() --> <!-- /ko --> <span class="remove" data-bind="click: remove"><i class="far fa-trash-alt"></i></span></button>
    <!-- /ko -->
    <!-- ko if: ((filterViewModel.selectedFacets() && (filterViewModel.selectedFacets().length > 0)) || isGeoSearchEnabled()) -->
    <button type="button" class="btn btn-sm btn-dark clear-filters" data-bind="click: reset" aria-label="Clear all filters"><i class="far fa-trash-alt"></i> Clear All</button>
    <!-- /ko -->
</div>

<div class="information-bar d-flex align-items-center justify-content-between my-0">
    <div id="pt-result-heading">
        <span id="pt-resultsReturned"></span>
        <span class="search-spinner spinner ml-1 d-none">
            <i class='fa fa-spin fa-spinner'></i> Updating...
        </span>
    </div>

    <div class="">
        <g:if test="${showProjectDownloadButton}">
            <a class="btn btn-dark btn-sm" id="pt-downloadLink"
               data-bind="visible: pageProjects().length > 0, click: download" href="${downloadLink}"
               title="${message(code: 'project.download.tooltip')}">
                <i class="fas fa-download"></i>&nbsp;<g:message code="g.download"/>
            </a>
        </g:if>
    </div>
</div>
