<div id="pt-table">
    <bc:koLoading>
        <div class="project-results">
            <div id="pt-result-heading" class="inline-block mb-3">
                <span id="pt-resultsReturned"></span>
                <g:if test="${showProjectDownloadButton}">
                    <a class="btn btn-success btn-sm" id="pt-downloadLink"
                       data-bind="visible: pageProjects().length > 0, click: download" href="${downloadLink}"
                       title="${message(code: 'project.download.tooltip')}">
                        <i class="fas fa-download"></i>&nbsp;<g:message code="g.download"/>
                    </a>
                </g:if>
            </div>

            <div class="d-inline-block mb-3">
                <span class="search-spinner spinner ml-1 d-none">
                    <i class='fa fa-spin fa-spinner'></i> Updating...
                </span>
            </div>
        </div>

        <div class="tab-content" data-bind="visible: pageProjects().length > 0">
            %{--            <div id="pt-searchNavBar" class="clearfix">--}%
            %{--                <div id="pt-navLinks"></div>--}%
            %{--            </div>--}%
            %{--            <div data-bind="if: viewMode() == 'listView'">--}%
            %{--                <g:render template="/shared/projectFinderResultPanelList"></g:render>--}%
            %{--            </div>--}%

            %{--            <div data-bind="if: viewMode() == 'tileView'">--}%
            %{--                <g:render template="/shared/projectFinderResultPanelTile"></g:render>--}%
            %{--            </div>--}%
            %{--            <div data-bind="visible: viewMode() == 'mapView'">--}%
            %{--                <g:render template="/shared/projectFinderResultPanelMap"></g:render>--}%
            %{--            </div>--}%
            %{--            <div id="pt-searchNavBar" class="clearfix">--}%
            %{--                <div id="pt-navLinks"></div>--}%
            %{--            </div>--}%

            <div class="tab-pane active" id="grid" role="tabpanel" aria-labelledby="grid-tab">
                <g:render template="/shared/projectFinderResultPanelTile"></g:render>
            </div>

            <div class="tab-pane fade" id="list" role="tabpanel" aria-labelledby="list-tab">
                <g:render template="/shared/projectFinderResultPanelList"></g:render>
            </div>

            <div class="tab-pane fade" id="map" role="tabpanel" aria-labelledby="map-tab">
                <g:render template="/shared/projectFinderResultPanelMap"></g:render>
            </div>
        </div>
    </bc:koLoading>
</div>