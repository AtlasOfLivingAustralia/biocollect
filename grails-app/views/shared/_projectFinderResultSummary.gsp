<div id="sortBar" class="row d-flex">
    <div class="col-12 col-md-4 offset-md-8 py-2 text-end mb-3">
        <div class="input-group">
            <input id="pt-search" type="text" class="form-control" placeholder="<g:message code="projectfinder.search"/>" aria-label="<g:message code="projectfinder.search"/>" aria-describedby="pt-search-link">
            <button class="btn btn-primary-dark" type="button" id="pt-search-link"><i class="fas fa-search"></i></button>
        </div>
    </div>
    <div class="col-6 col-md-4 mb-3 order-1 order-md-0">
        <button class="btn btn-dark project-finder-filters-expander" data-bs-toggle="collapse" data-bs-target=".expander" aria-expanded="true" aria-controls="expander" title="Filter Projects">
            <i class="fas fa-filter"></i> Filter Projects
        </button>
    </div>
    <div class="col-6 col-sm-6 col-md-4 mb-3 text-end text-md-center order-2 order-md-1">
        <div class="btn-group" role="group" aria-label="Catalogue Display Options">
            <div class="btn-group nav nav-tabs project-finder-tab" role="group" aria-label="Catalogue Display Options">
                <a class="btn btn-outline-dark active" id="grid-tab" data-bs-toggle="tab" title="View as Grid" href="#grid" role="tab" aria-controls="View as Grid" aria-selected="true">
                    <i class="fas fa-th-large"></i></a>
                <a class="btn btn-outline-dark" id="list-tab" data-bs-toggle="tab" title="View as List" href="#list" role="tab" aria-controls="View as List">
                    <i class="fas fa-list"></i></a>
%{-- todo : uncomment when all project area can be shown without pagination--}%
%{--                <a class="btn btn-outline-dark" id="map-tab" data-bs-toggle="tab" title="View as Images" href="#map" role="tab" aria-controls="View on Map">--}%
%{--                    <i class="far fa-map"></i></a>--}%
            </div>
            %{--                    <button type="button" class="btn btn-outline-dark active" title="View as Grid"><i class="fas fa-th-large"></i></button>--}%
            %{--                    <button type="button" class="btn btn-outline-dark" title="View as List"><i class="fas fa-list"></i></button>--}%
            %{--                    <button type="button" class="btn btn-outline-dark" title="View as Map"><i class="far fa-map"></i></button>--}%
        </div>
    </div>
    <div class="col-12 col-md-4 text-center text-md-end order-0 order-md-2 ps-md-0 mb-3 mb-md-0">
        <div class="project-finder-sort-controls d-flex flex-column flex-sm-row justify-content-md-end gap-2 gap-md-3">
            <div class="project-finder-sort-group d-flex flex-column flex-sm-row align-items-start align-items-sm-center gap-1 gap-sm-3">
            <label for="sortBy" class="col-form-label">Sort by</label>
            <select id="sortBy" class="form-select col form-select" data-bind="value: sortBy" aria-label="Sort Order">
                <option value="dateCreatedSort">Most Recent</option>
                <option value="nameSort">Name</option>
                <option value="_score">Relevance</option>
                <option value="organisationSort">Organisation</option>
            </select>
            </div>
            <div class="project-finder-sort-group d-flex flex-column flex-sm-row align-items-start align-items-sm-center gap-1 gap-sm-3 projects-from-select">
            <label for="projectsFrom" class="col-form-label">Projects from</label>
            <select id="projectsFrom" class="form-select col form-select" data-bind="value: isWorldWide" aria-label="Projects from">
                <option value="false">Australia</option>
                <option value="true">Global</option>
            </select>
            </div>
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
    <!-- ko if: filterViewModel.nationwideProjectCheckbox() -->
    <button class="filter-item btn btn-outline-dark btn-sm"><g:message code="project.search.excludeNationalProject"/><span class="remove" data-bind="click: removeNationwide"><i class="far fa-trash-alt"></i></span></button>
    <!-- /ko -->
    <!-- ko if: ((filterViewModel.selectedFacets() && filterViewModel.selectedFacets().length > 0) || isGeoSearchEnabled() || filterViewModel.nationwideProjectCheckbox()) -->
    <button type="button" class="btn btn-sm btn-dark clear-filters" data-bind="click: reset">
        <i class="far fa-trash-alt"></i> Clear All
    </button>
    <!-- /ko -->
</div>

<div class="information-bar d-flex align-items-center justify-content-between my-0">
    <div id="pt-result-heading">
        <span id="pt-resultsReturned"></span>
        <span class="search-spinner spinner ms-1 d-none">
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
