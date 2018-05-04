<bc:koLoading>
    <div class="image-gallery">
        <ul class="thumbnails" data-bind="visible: ${name}().length">
            <!-- ko foreach: ${name} -->
            <li>
                <div class="projectLogo" data-toggle="popover" data-trigger="hover" data-title="Photo metadata" data-bind="popover: {placement:'top', content: function(){ return $(this).find('.metadata').html()} }">
                    <a href=""
                       data-bind="attr:{href:getImageViewerUrl()}, fancybox: {nextEffect:'fade', preload:0, 'prevEffect':'fade', type: 'iframe', width: '80%', title: function(){ return $(this).next().find('.metadata').html()}}"
                       target="fancybox">
                        <img class="image-logo image-window" data-bind="attr:{title:name, src:thumbnailUrl}" onload="findLogoScalingClass(this, 200, 150)">
                    </a>
                    <div class="hide">
                        <div class="metadata">
                            <div data-bind="visible:name"><strong>Name:</strong> <span class="label-ellipsis" data-bind="text:name"></span></div>
                            <div data-bind="visible: attribution"><strong>Attribution:</strong> <span data-bind="text: attribution"></span></div>
                            <div data-bind="visible: licenceDescription"><strong>Licence:</strong> <span data-bind="text: licenceDescription"></span></div>
                            <div data-bind="visible: dateTaken"><strong>Date:</strong> <span data-bind="text: convertToSimpleDate(dateTaken())"></span></div>
                            <div data-bind="visible: notes"><strong>Notes:</strong> <span data-bind="text: notes"></span></div>
                            <div data-bind="visible: activityName && !fcConfig.hideProjectAndSurvey"><strong>Activity name:</strong> <a data-bind="attr:{href:getActivityLink()}, text: activityName" target="_blank"></a></div>
                            <div data-bind="visible: projectName && !fcConfig.hideProjectAndSurvey"><strong>Project name:</strong> <a data-bind="attr:{href:getProjectLink()}, text: projectName" target="_blank"></a></div>
                        </div>
                    </div>
                </div>
            </li>
            <!-- /ko -->
        </ul>

        <!-- ko if: ${name}().length == 0 -->
        <p>
            No images found.
        </p>
        <!-- /ko -->
    </div>
</bc:koLoading>