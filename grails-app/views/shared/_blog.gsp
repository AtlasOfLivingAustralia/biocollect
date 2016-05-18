<!-- ko stopBinding:true -->
<g:set var="blogId" value="blog-${fc.attributeSafeValue(value:type)}"/>
<div id="${blogId}" class="blog"  data-bind="foreach:entries">
    <div class="blog-entry">
        <img class="blog-image floatleft" data-bind="visible:imageUrl(), attr:{src:imageUrl}">
        <i class="blog-icon floatleft fa fa-4x" data-bind="visible:stockIcon(), css:stockIcon"></i>
        <div class="widget-news-right-body">
            <h3><span class="title" data-bind="text:title"></span><span class="floatright" data-bind="text:formattedDate"></span></h3>
            <div class="text" data-bind="html:content.markdownToHtml()"></div> <a data-bind="visible:viewMoreUrl, attr:{href:viewMoreUrl}" aria-label="More information"><i class="fa fa-arrow-circle-o-right"></i></a>
        </div>
    </div>

</div>
<!-- /ko -->
<r:script>
    $(function() {

        var blog = <fc:modelAsJavascript model="${blog}"/>;

        var blogViewModel = new BlogViewModel(blog, '${type}');
        ko.applyBindings(blogViewModel, document.getElementById('${blogId}'));
    });
</r:script>
