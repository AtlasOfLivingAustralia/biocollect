<bc:koLoading>
    <!-- ko foreach: sites -->
    <div data-bind="visible: name">
        <div class="pull-right margin-right-20">
            <a data-bind="click:addSiteToFavourites,visible: showAddToFavourites" class="margin-left-20"><i class="fa fa-star-o" title="Add to favourites"></i></a>
            <a data-bind="click:removeSiteFromFavourites,visible: showRemoveFromFavourites" class="margin-left-10"><i class="fa fa-star" title="Remove from favourites"></i></a>
            <a data-bind="attr:{href:getSiteUrl()}" class="margin-left-10"><i class="fa fa-eye" title="View site"></i></a>
            <a data-bind="attr:{href:getSiteEditUrl()},visible: canEdit" class="margin-left-10"><i class="fa fa-edit" title="Edit site"></i></a>
            <a href="#" data-bind="visible: canDelete, click: deleteSite" class="margin-left-10"><i class="fa fa-remove" title="Delete site"></i></a>
        </div>
        <h4><a data-bind="attr:{href:getSiteUrl()}, text: name"></a></h4>
        <div class="margin-left-20">
            <div data-bind="visible: description"><span data-bind="text: description"></span></div>
            <div data-bind="visible: type"><span>Site type:</span> <span data-bind="text: type"></span></div>
            <div data-bind="visible: numberOfPoi() != undefined"><span>Number of POI:</span> <span data-bind="text: numberOfPoi"></span><br></div>
            <div data-bind="visible: numberOfProjects() != undefined"><span>Number of associated projects:</span> <span data-bind="text: numberOfProjects"></span></div>
        </div>
        <hr>
    </div>
    <!-- /ko -->
    <!-- ko if: sites().length == 0 -->
    <h4 data-bind="visible: !sitesLoaded()"><span class="fa fa-spin fa-spinner"></span>&nbsp;Sites Loading...</h4>
    <h4 data-bind="visible: sitesLoaded()">No sites found</h4>
    <!-- /ko -->
</bc:koLoading>