<div id="pt-table" class="span9 no-sidebar">
    <bc:koLoading>
        <div>
            <div class="project-results">
                <div id="pt-result-heading" class="inline-block margin-bottom-20">
                    <span id="pt-resultsReturned"></span>
                    <g:if test="${showProjectDownloadButton}">
                        <a data-bind="visible: pageProjects().length > 0, click: download" href="${downloadLink}" id="pt-downloadLink" class="btn btn-warning btn-mini"
                           title="${message(code: 'project.download.tooltip')}">
                            <i class="icon-download icon-white"></i>&nbsp;<g:message code="g.download"/></a>
                    </g:if>
                </div>
                <div class="inline-block margin-bottom-20">
                    <span class="search-spinner spinner margin-left-1" style="display: none" >
                        <i class='red fa fa-spin fa-spinner'></i> Updating...
                    </span>
                </div>
            </div>

        </div>
        <div data-bind="visible: pageProjects().length > 0">
            <div id="pt-searchNavBar" class="clearfix">
                <div id="pt-navLinks"></div>
            </div>
            <div data-bind="if: viewMode() == 'listView'">
                <g:render template="/shared/projectFinderResultPanelList"></g:render>
            </div>

            <div data-bind="if: viewMode() == 'tileView'">
                <g:render template="/shared/projectFinderResultPanelTile"></g:render>
            </div>
            <div data-bind="visible: viewMode() == 'mapView'">
                <g:render template="/shared/projectFinderResultPanelMap"></g:render>
            </div>
            <div id="pt-searchNavBar" class="clearfix">
                <div id="pt-navLinks"></div>
            </div>
        </div>
    </bc:koLoading>
</div>