<div id="project-finder-container">
    <div class="row-fluid">
        <g:render template="/shared/projectFinderQueryInput"/>
    </div>

    <div>
        <g:render template="/shared/projectFinderResultSummary"/>
    </div>

    <div class="row-fluid">
        <div id="filterPanel" class="span3" style="display: none">
            <g:render template="/shared/projectFinderQueryPanel"/>
        </div>

        <div id="pt-table" class="span9 no-sidebar">
            <bc:koLoading>
                <div data-bind="if: listView">
                    <g:render template="/shared/projectFinderResultPanelList"></g:render>
                </div>

                <div data-bind="ifnot: listView">
                    <g:render template="/shared/projectFinderResultPanelTile"></g:render>
                </div>
                <div id="pt-searchNavBar" class="clearfix">
                    <div id="pt-navLinks"></div>
                </div>
            </bc:koLoading>
        </div>
    </div>
</div>