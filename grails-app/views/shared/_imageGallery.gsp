<bc:koLoading>
    <div class="image-gallery">
        <g:render template="/shared/pagination" model="[bs: 4]"/>
        <div class="thumbnails row">
            <!-- ko foreach: recordImages -->
            <div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2 mt-1">
                <div class="projectLogo" data-toggle="popover" data-trigger="hover" data-title="Photo metadata" data-bind="popover: {placement:'top', content: function(){ return $(this).find('.metadata').html()} }">
                    <a href=""
                       data-bind="attr:{href:getImageViewerUrl()}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', type: 'iframe', width:'80%', title: function(){ return $(this).next().find('.metadata').html()}}"
                       target="fancybox">
                        <img class="image-logo image-window img-thumbnail" data-bind="attr:{title:name, src:thumbnailUrl}"
                             onload="findLogoScalingClass(this, 200, 150)" onerror="imageError(this, '${noImageUrl}');">
                    </a>
                    <div class="hide">
                        <div class="metadata">
                            <div data-bind="visible:name"><strong>Name:</strong> <span class="label-ellipsis display-inline-block" data-bind="text:name, attr:{title:name}"></span></div>
                            <div data-bind="visible: attribution"><strong>Attribution:</strong> <span data-bind="text: attribution"></span></div>
                            <div data-bind="visible: licenceDescription"><strong>Licence:</strong> <span data-bind="text: licenceDescription"></span></div>
                            <div data-bind="visible: dateTaken"><strong>Date:</strong> <span data-bind="text: convertToSimpleDate(dateTaken())"></span></div>
                            <div data-bind="visible: notes"><strong>Notes:</strong> <span data-bind="text: notes"></span></div>
                            <div data-bind="visible: activityName && !fcConfig.hideProjectAndSurvey"><strong>Activity name:</strong> <a data-bind="attr:{href:getActivityLink()}, text: activityName" target="_blank"></a></div>
                            <div data-bind="visible: projectName && !fcConfig.hideProjectAndSurvey"><strong>Project name:</strong> <a data-bind="attr:{href:getProjectLink()}, text: projectName" target="_blank"></a></div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /ko -->
        </div>
        <g:render template="/shared/pagination" model="[bs: 4]"/>

        <span data-bind="if: transients.loading()"><span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...</span>
        <!-- ko if: recordImages().length == 0 && !error() -->
        <span data-bind="if: !transients.loading()">No images found</span>
        <!-- /ko -->

        <!-- ko if: error() -->
        <div class="alert alert-error" data-bind="text: error">
        </div>
        <!-- /ko -->
    </div>
</bc:koLoading>