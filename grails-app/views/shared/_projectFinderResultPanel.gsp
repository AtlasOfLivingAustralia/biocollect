<div id="pt-table" class="span9 no-sidebar">
    <bc:koLoading>
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
    </bc:koLoading>
</div>