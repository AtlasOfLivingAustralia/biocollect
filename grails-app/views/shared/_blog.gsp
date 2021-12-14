<!-- ko stopBinding:true -->
<g:set var="blogId" value="blog-${fc.attributeSafeValue(value:type)}"/>
<div id="${blogId}" class="row post-list">
    <span data-bind="if: entries().length == 0">
        <div class="col-12">
            <h4>No entries available</h4>
        </div>
    </span>
    <!-- ko foreach:entries -->
    <article class="blog col-12 post mb-5 mb-md-4" style="border-bottom: ridge">
        <div class="row blog-entry">
            <div class="col-12 col-md-3">
                <!-- ko if: imageUrl() -->
                    <a href="#" class="post-image">
                        <img data-bind="attr:{src:imageUrl}">
                    </a>
                <!-- /ko -->
                <!-- ko ifnot: imageUrl() -->
                    <i class="blog-icon fa fa-4x" data-bind="visible:stockIcon(), css:stockIcon"></i>
                <!-- /ko -->
            </div>

            <div class="col-12 col-md-9">
                <div class="post-link">
                    <h2 class="entry-title" data-bind="text:title"></h2>
                </div>
                <div class="post-meta">
                    <time data-bind="text:formattedDate" aria-label="Date Posted"></time>
                </div>
                <div data-bind="html:content.markdownToHtml()"></div>
                <a href="#" class="btn btn-sm btn-primary-dark" data-bind="visible:viewMoreUrl, attr:{href:viewMoreUrl}">
                    <i class="far fa-eye"></i> View More
                </a>
            </div>
        </div>
    </article>
    <!-- /ko -->
</div>
<!-- /ko -->
<asset:script type="text/javascript">
    $(function() {

        var blog = <fc:modelAsJavascript model="${blog}" default="[]"/>;
        //var data = [
        //    {title:'Test', text:'This is a test', date:'2 Oct', imageUrl:'http://ecodata.ala.org.au/uploads/2015-08/Common%20Riverbank%20Weeds%20Cover%20Image.png'},
        //    {title:'Also a test', text:'Over four years of Caring for our Country funding the RLF has run a dedicated program of events targeting horse owners. From early workshops using the "Managing Horses on Small Properties" workshop series offered by Equiculture it became apparent that a network of horse owners interested in sustainable land management would be valuable. ', date:'12 Sep', imageUrl:'http://ecodata.ala.org.au/uploads/2015-08/Common%20Riverbank%20Weeds%20Cover%20Image.png'}
        //];
        var blogViewModel = new BlogViewModel(blog, '${type}');
        ko.applyBindings(blogViewModel, document.getElementById('${blogId}'));
    });
</asset:script>
