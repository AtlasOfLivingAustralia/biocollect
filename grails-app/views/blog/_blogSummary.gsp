<!-- ko stopBinding:true -->
<div id="site-blog">
    <g:if test="${blog.size() > 0}">
        <ul class="unstyled" data-bind="foreach:entries">
            <li>
                <img data-bind="visible:imageUrl(), attr:{src:imageUrl}" class="margin-right-10 pull-left" width="50" height="50">
                <i class="blog-icon pull-left fa fa-3x" data-bind="visible:stockIcon(), css:stockIcon"></i>
                <div>
                    <div class="row-fluid">
                        <strong data-bind="text:title"></strong>
                        <div class="pull-right">
                            <a href data-bind="click:$parent.editBlogEntry"><g:message code='g.edit'/></a> |
                            <a href data-bind="click:$parent.deleteBlogEntry"><g:message code='g.delete'/></a>
                        </div>
                    </div>
                    <p data-bind="text:shortContent"></p>
                </div>
                <hr/>
            </li>

        </ul>
    </g:if>
    <g:else>
        <g:message code='project.blog.noEntries'/>.
    </g:else>

    <div class="form-actions">
        <button data-bind="click:newBlogEntry" type="button" id="new" class="btn btn-primary"><g:message code='project.blog.newEntry'/></button>
    </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">

$(function(){

    var blog = ${fc.modelAsJavascript(model:blog, default:'[]')};
    ko.applyBindings(new BlogSummary(blog), document.getElementById('site-blog'));
});

</asset:script>