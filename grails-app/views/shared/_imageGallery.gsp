<r:require modules="imageGallery"/>
<bc:koLoading>
    <div class="image-gallery">
        <ul class="thumbnails">
            <!-- ko foreach: recordImages -->
            <li>
            <div  class="hide" data-bind="attr:{id: 'popoverContent' + $index()}">
                <div data-bind="visible:name"><strong>Name:</strong> <span data-bind="text:name"></span></div>
                <div data-bind="visible: attribution"><strong>Attribution:</strong> <span data-bind="text: attribution"></span></div>
                <div data-bind="visible: dateTaken"><strong>Date:</strong> <span data-bind="text: convertToSimpleDate(dateTaken())"></span></div>
                <div data-bind="visible: notes"><strong>Date:</strong> <span data-bind="text: notes"></span></div>
            </div>
                <div class="thumbnail"  data-toggle="popover" data-trigger="hover" data-title="Photo metadata" data-bind="popover: {placement:'top', content: function(){ return $('#popoverContent' + $index()).html()} }">
                    <a href=""
                       data-bind="attr:{href:url}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade'}"
                       data-target="_photo">
                        <div class="image-window" data-target="#imageGalleryModal" data-toggle="modal"
                             data-bind="style:{'background-image':'url('+thumbnailUrl+')'}, click: $root.imageFullscreen">

                        </div>
                    </a>
                </div>
            </li>
            <!-- /ko -->
        </ul>
        <button class="btn margin-left-30" data-bind="click: nextPage, visible: isLoadMore">Load more</button>

        <!-- ko if: recordImages().length == 0 -->
        <h3>
            No record images found.
        </h3>
        <!-- /ko -->
    </div>
</bc:koLoading>