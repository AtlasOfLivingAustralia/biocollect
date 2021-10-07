<div id="project-finder-container">
    <g:if test="${doNotShowSearchBtn != true}">
    <div class="row">
        <div class="col-12">
            <g:render template="/shared/projectFinderQueryInput"/>
        </div>
    </div>
    </g:if>

    <div>
        <g:render template="/shared/projectFinderResultSummary"/>
    </div>

    <div class="row">
        <div id="filterPanel" class="span3" style="display: none">
            <g:render template="/shared/projectFinderQueryPanel"/>
        </div>

        <g:render template="/shared/projectFinderResultPanel" />
    </div>
</div>