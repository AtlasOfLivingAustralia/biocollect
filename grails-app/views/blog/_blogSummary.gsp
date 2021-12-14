<!-- ko stopBinding:true -->
<div id="site-blog">
    <g:if test="${blog.size() > 0}">
        <!-- ko foreach:entries -->
        <div class="row mt-3" style="border-bottom: ridge">
            <div class="col-12 media">
                <img data-bind="visible:imageUrl(), attr:{src:imageUrl}" class="mr-2" width="50" height="50">
                <i class="blog-icon pull-left fa fa-3x mr-2" data-bind="visible:stockIcon(), css:stockIcon"></i>
                <div class="media-body">
                    <h5 data-bind="text:title"></h5>
                    <p class="excerpt" data-bind="text:shortContent"></p>
                    <div class="row">
                        <div class="col-12 mb-3">
                            <a class="btn btn-sm btn-primary-dark" href="#" data-bind="click:$parent.editBlogEntry">
                                <i class="fas fa-pencil-alt"></i> Edit</a>
                            <a class="btn btn-sm btn-danger" href="#" data-bind="click:$parent.deleteBlogEntry">
                                <i class="far fa-trash-alt"></i> Delete</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /ko -->
    </g:if>
    <g:else>
        No blog entries.
    </g:else>

    <div class="row mt-2">
        <div class="col-12">
            <button data-bind="click:newBlogEntry" type="button" id="new" class="btn btn-sm btn-primary-dark "><i class="fas fa-plus"></i> New Entry</button>
        </div>
    </div>
</div>
<!-- /ko -->

<asset:script type="text/javascript">

$(function(){

    var blog = ${raw(fc.modelAsJavascript(model:blog, default:'[]'))};
    ko.applyBindings(new BlogSummary(blog), document.getElementById('site-blog'));
});

</asset:script>