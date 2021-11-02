<g:if test="${hasNewsAndEvents || hasLegacyNewsAndEvents}">
    <div id="projectBlog" class="my-4 my-md-5">

        <div class="container">

            <h2>News &amp; Events</h2>
            <div class="blog-section">
                <g:render template="/shared/blog" model="${[blog:blog, type:'News and Events']}"/>

                %{-- Legacy news & events section--}%
                <!-- ko if:newsAndEvents() -->
                    <div class="row">
                        <div class="post col-12 col-lg-6 mb-5 mb-md-4" id="newsAndEventsDiv" data-bind="html:newsAndEvents.markdownToHtml()" ></div>
                    </div>
                <!-- /ko -->
            </div>
        </div>

    </div>
</g:if>

<g:if test="${hasProjectStories || hasLegacyProjectStories}">
    <div id="projectBlog" class="my-4 my-md-5">
        <div class="container">
            <h2>Project stories</h2>
            <div class="blog-section">
                <div class="blog-section">
                    <g:render template="/shared/blog" model="${[blog:blog, type:'Project Stories']}"/>

                    %{-- Legacy news & events section--}%
                    <div class="row" data-bind="visible:projectStories()">
                        <div class="col-12" id="projectStoriesDiv" data-bind="html:projectStories.markdownToHtml()"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:if>

<g:if test="${!hasNewsAndEvents && !hasLegacyNewsAndEvents && !hasProjectStories}">
    <div class="row">
        <div class="col-12">
            <h4>Not available</h4>
        </div>
    </div>
</g:if>