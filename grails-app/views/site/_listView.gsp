<bc:koLoading>
    <!-- ko foreach: sites -->
    <div data-bind="visible: name">
        <div class="pull-right margin-right-20">
            <a data-bind="click:addSiteToFavourites,visible: showAddToFavourites" class="margin-left-20"><i class="fa fa-star-o" title="${message(code: 'site.list.addFavourite')}"></i></a>
            <a data-bind="click:removeSiteFromFavourites,visible: showRemoveFromFavourites" class="margin-left-10"><i class="fa fa-star" title="${message(code: 'site.list.removeFavourite')}"></i></a>
            <a data-bind="attr:{href:getSiteUrl()}" class="margin-left-10"><i class="fa fa-eye" title="${message(code: 'site.list.view')}"></i></a>
            <a data-bind="attr:{href:getSiteEditUrl()},visible: canEdit" class="margin-left-10"><i class="fa fa-edit" title="${message(code: 'site.list.edit')}"></i></a>
            <a href="#" data-bind="visible: canDelete, click: deleteSite" class="margin-left-10"><i class="fa fa-remove" title="${message(code: 'site.list.remove')}"></i></a>
        </div>
        <h4><a data-bind="attr:{href:getSiteUrl()}, text: name"></a></h4>
        <div class="margin-left-20">
            <div data-bind="visible: description"><span data-bind="text: description"></span></div>
            <div data-bind="visible: type"><g:message code='site.metadata.type'/><span>:</span> <span data-bind="text: type"></span></div>
            <div data-bind="visible: numberOfPoi() != undefined"><span><g:message code='site.metadata.numberOfPOI'/>:</span> <span data-bind="text: numberOfPoi"></span><br></div>
            <div data-bind="visible: numberOfProjects() != undefined"><span><g:message code='site.list.associatedProjects'/>:</span> <span data-bind="text: numberOfProjects"></span></div>
        </div>
        <hr>
    </div>
    <!-- /ko -->
    <!-- ko if: sites().length == 0 -->
    <h4 data-bind="visible: !sitesLoaded()"><span class="fa fa-spin fa-spinner"></span>&nbsp;<g:message code='site.list.loading'/>...</h4>
    <h4 data-bind="visible: sitesLoaded()"><g:message code='site.list.noneFound'/></h4>
    <!-- /ko -->
</bc:koLoading>