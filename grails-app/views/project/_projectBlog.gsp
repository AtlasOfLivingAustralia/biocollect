<g:if test="${hasNewsAndEvents || hasLegacyNewsAndEvents}">
    <h3>News & events</h3>
    <div class="blog-section">
        <g:render template="/shared/blog" model="${[blog:blog, type:'News and Events']}"/>

        %{-- Legacy news & events section--}%
        <div class="row-fluid" data-bind="if:newsAndEvents()">
            <div class="span12" id="newsAndEventsDiv" data-bind="html:newsAndEvents.markdownToHtml()" ></div>
        </div>
    </div>
</g:if>

<g:if test="${hasProjectStories || hasLegacyProjectStories}">
    <div class="row-fluid">
        <h3>Project stories</h3>
        <div class="blog-section">
            <g:render template="/shared/blog" model="${[blog:blog, type:'Project Stories']}"/>

            %{-- Legacy news & events section--}%
            <div class="row-fluid" data-bind="visible:projectStories()">
                <div class="span12" id="projectStoriesDiv" data-bind="html:projectStories.markdownToHtml()"></div>
            </div>
        </div>
    </div>
</g:if>

<g:if test="${!hasNewsAndEvents && !hasLegacyNewsAndEvents}">
    <div class="well">
        <h4>Not available</h4>
    </div>

</g:if>