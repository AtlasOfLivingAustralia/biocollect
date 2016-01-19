<r:require modules="imageGallery"/>
<bc:koLoading>
    <div class="image-gallery">
        <ul class="thumbnails">
            <!-- ko foreach: recordImages -->
            <li>
                <div class="hide" data-bind="attr:{id: 'projectActivityLinks' + $index()}">
                    <div data-bind="attr:{id: 'popoverContent' + $index()}">
                        <div data-bind="visible:name"><strong>Name:</strong> <span data-bind="text:name"></span></div>
                        <div data-bind="visible: attribution"><strong>Attribution:</strong> <span data-bind="text: attribution"></span></div>
                        <div data-bind="visible: dateTaken"><strong>Date:</strong> <span data-bind="text: convertToSimpleDate(dateTaken())"></span></div>
                        <div data-bind="visible: notes"><strong>Date:</strong> <span data-bind="text: notes"></span></div>
                        <div data-bind="visible: activityName"><strong>Activity name:</strong> <a data-bind="attr:{href:getActivityLink()}, text: activityName" target="_blank"></a></div>
                        <div data-bind="visible: projectName"><strong>Project name:</strong> <a data-bind="attr:{href:getProjectLink()}, text: projectName" target="_blank"></a></div>
                    </div>
                </div>
                <div class="projectLogo" data-toggle="popover" data-trigger="hover" data-title="Photo metadata" data-bind="popover: {placement:'top', content: function(){ return $('#popoverContent' + $index()).html()} }">
                    <a href=""
                       data-bind="attr:{href:url}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', title: function(){ return $('#projectActivityLinks' + $index()).html()}}"
                       data-target="_photo" class="">
                        <img class="image-logo image-window" data-bind="attr:{title:name, src:thumbnailUrl}" onload="findLogoScalingClass(this, 200, 150)">
                    </a>
                </div>
                <div class="thumbnail hide"  data-toggle="popover" data-trigger="hover" data-title="Photo metadata" data-bind="popover: {placement:'top', content: function(){ return $('#popoverContent' + $index()).html()} }">
                    <a href=""
                       data-bind="attr:{href:url}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', title: function(){ return $('#projectActivityLinks' + $index()).html()}}"
                       data-target="_photo">
                        <div class="image-window" data-target="#imageGalleryModal" data-toggle="modal"
                             data-bind="style:{'background-image':'url('+thumbnailUrl+')'}">
                        </div>
                    </a>
                </div>
            </li>
            <!-- /ko -->
        </ul>
        <button class="btn margin-left-30" data-bind="click: nextPage, visible: isLoadMore">Load more</button>

        <!-- ko if: recordImages().length == 0 && !error() -->
        <h3>
            No images found.
        </h3>
        <!-- /ko -->

        <!-- ko if: error() -->
        <div class="alert alert-error" data-bind="text: error">
        </div>
        <!-- /ko -->
    </div>
</bc:koLoading>