<bc:koLoading>
<!-- ko if: !isSitesEmpty() -->
<div class="inline">
    <div class="text-right">Image sort order :
        <div class="btn-group" data-toggle="buttons-radio">
            <button class="btn btn-small" data-value="asc" data-bind="event:{click: setSortDirection}">ascending</button>
            <button class="btn btn-small active" data-value="desc" data-bind="event:{click: setSortDirection}">descending</button>
        </div>
    </div>
</div>
<hr>
<!-- /ko -->
<div>
<!-- ko foreach: sites -->
    <!-- ko if: !isPhotoPointsEmpty() -->
    <h3 data-bind="text:name"></h3>
    <!-- ko foreach: poi -->
    <ul class="breadcrumb margin-bottom-5 margin-top-5">
        <li>
            <span><strong data-bind="text:name"></strong> (<span  data-bind="text: total"></span>)</span>
        </li>
        <li>
            | <span data-bind="text: $parent.name"></span>
        </li>
        <li data-bind="visible: showPoi() == true" title="Click to hide images for this point of interest">
            | <a class="btn-link" data-bind="click: toggleVisibility"> hide</a>
        </li>
        <li data-bind="visible: showPoi() == false" title="Click to show images for this point of interest">
            | <a class="btn-link" data-bind="click: toggleVisibility"> show</a>
        </li>
    </ul>
    <div class="list-parent" data-bind="slideVisible: showPoi">
        <ul class="cards-list padding-bottom-20 margin-top-10 unstyled"  data-bind="style:{width:getWidth}">
            <!-- ko foreach: documents -->
            <li data-bind="fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', type:'iframe', title: function(){ return this.next().html() }}">
            <div class="projectLogo">
                <!-- ko if: !isEmbargoed -->
                    <a href="#" data-bind="attr:{href:getImageViewerUrl(),rel:'group'+$parent.poiId()}" target="fancybox">
                        <img data-bind="attr:{ src: thumbnailUrl }" onload="findLogoScalingClass(this,200,150)" class="image-logo image-window">
                    </a>
                    <div class="hide metadata">
                        <div>
                            <div data-bind="visible:name"><strong>Name:</strong> <span data-bind="text:name"></span></div>
                            <div data-bind="visible: attribution"><strong>Attribution:</strong> <span data-bind="text: attribution"></span></div>
                            <div data-bind="visible: dateTaken"><strong>Date:</strong> <span data-bind="text: convertToSimpleDate(dateTaken())"></span></div>
                            <div data-bind="visible: notes"><strong>Date:</strong> <span data-bind="text: notes"></span></div>
                            <div data-bind="visible: activityId"><a data-bind="attr:{href:getActivityLink()}" target="_blank">View Activity</a></div>
                        </div>
                    </div>
                <!-- /ko -->
                <!-- ko if: isEmbargoed -->
                    <strong>EMBARGOED</strong>
                    <span class="clear-line-height"><i class="icon-question-sign" data-bind="popover: {placement:'top', content: 'You do not have permission to view this image.' }"></i></span>
                <!-- /ko -->
                </div>
            </li>
            <!-- /ko -->
            <!-- ko if: hasNextPage -->
            <li>
                <div class="projectLogo text-center">
                    <a href="#" data-bind="click:nextPage"> <i class="icon-plus"></i> Load more</a>
                </div>
            </li>
            <!-- /ko -->
        </ul>
        <div data-bind="visible: isEmpty">
            <h4> No photos found</h4>
        </div>
    </div>
    <!-- /ko -->
    <!-- ko if: !$data.isPhotoPointsEmpty() -->
    <hr/>
    <!-- /ko -->
    <!-- /ko -->
<!-- /ko -->
    <div data-bind="visible: isSitesEmpty">
        <h4> No photo points found</h4>
    </div>
    <div data-bind="visible: loading">
        <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
    </div>
</div>
</bc:koLoading>
<script>
    function initPoiGallery( params, id ){
        var sites = new SitesGalleryViewModel(params);
        ko.applyBindings(sites, $('#'+id)[0])
        return sites;
    }
</script>