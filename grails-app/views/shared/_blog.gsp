<!-- ko stopBinding:true -->
<g:set var="blogId" value="blog-${fc.attributeSafeValue(value:type)}"/>
<div id="${blogId}" class="blog"  data-bind="foreach:entries">
    <div class="blog-entry">
        <img class="blog-image floatleft" data-bind="visible:imageUrl(), attr:{src:imageUrl}">
        <i class="blog-icon floatleft fa fa-4x" data-bind="visible:stockIcon(), css:stockIcon"></i>
        <div class="widget-news-right-body">
            <h3><span class="title" data-bind="text:title"></span><span class="pull-right" data-bind="text:formattedDate"></span></h3>
            <div class="text" data-bind="html:content.markdownToHtml()"></div> <a data-bind="visible:viewMoreUrl, attr:{href:viewMoreUrl}" aria-label="More information"><i class="fa fa-arrow-circle-o-right"></i></a>
        </div>
    </div>
</div>
<!-- /ko -->
<r:script>
    $(function() {

        var blog = <fc:modelAsJavascript model="${blog}" default="[]"/>;
        //var data = [
        //    {title:'Test', text:'This is a test', date:'2 Oct', imageUrl:'http://ecodata.ala.org.au/uploads/2015-08/Common%20Riverbank%20Weeds%20Cover%20Image.png'},
        //    {title:'Also a test', text:'Over four years of Caring for our Country funding the RLF has run a dedicated program of events targeting horse owners. From early workshops using the "Managing Horses on Small Properties" workshop series offered by Equiculture it became apparent that a network of horse owners interested in sustainable land management would be valuable. ', date:'12 Sep', imageUrl:'http://ecodata.ala.org.au/uploads/2015-08/Common%20Riverbank%20Weeds%20Cover%20Image.png'}
        //];
        var blogViewModel = new BlogViewModel(blog, '${type}');
        ko.applyBindings(blogViewModel, document.getElementById('${blogId}'));
    });
</r:script>
