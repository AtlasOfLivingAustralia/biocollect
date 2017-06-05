<div id="project-finder-container">
    <g:if test="${doNotShowSearchBtn != true}">
        <div class="row-fluid">
            <g:render template="/shared/projectFinderQueryInput"/>
        </div>
    </g:if>

    <div>
        <g:render template="/shared/projectFinderResultSummary"/>
    </div>

    <div class="row-fluid">
        <div id="filterPanel" class="span3" style="display: none">
            <g:render template="/shared/projectFinderQueryPanel"/>
        </div>

        <g:render template="/shared/projectFinderResultPanel" />
    </div>
</div>