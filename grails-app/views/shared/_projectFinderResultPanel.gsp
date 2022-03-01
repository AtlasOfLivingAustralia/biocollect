<g:render template="/shared/pagination" model="[bs:4, classes:'my-2']"/>
<div id="pt-table">
    <bc:koLoading>
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
<g:render template="/shared/pagination" model="[bs:4]"/>