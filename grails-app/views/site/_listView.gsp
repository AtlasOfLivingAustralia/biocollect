<bc:koLoading>
    <div class="row">
        <!-- ko foreach: sites -->
        %{--    --}%
        <div class="col-12 col-lg-6 d-flex" data-bind="visible: name">
            <div class="record flex-grow-1">
                <div class="row">
                    <div class="col-12 pl-sm-1">
                        <h4><a data-bind="attr:{href:getSiteUrl()}, text: name"></a></h4>
                        <ul class="detail-list">
                            <li data-bind="visible: description"><span class="label"><g:message
                                    code="label.description"/>:</span> <span data-bind="text: description"></span></li>
                            <li data-bind="visible: type"><span class="label"><g:message
                                    code="label.site.type"/>:</span> Echinda CSI</li>
                            <li data-bind="visible: numberOfPoi() != undefined"><span class="label"><g:message
                                    code="label.poi"/>:</span> <span data-bind="text: numberOfPoi"></span></li>
                            <li data-bind="visible: numberOfProjects() != undefined"><span class="label"><g:message
                                    code="label.project"/>:</span> <span data-bind="text: numberOfProjects"></span></li>
                        </ul>

                        <div class="btn-space">
                            <a class="btn btn-sm btn-primary-dark" role="button" title="View Record"
                               data-bind="attr:{href:getSiteUrl()}">
                                <i class="far fa-eye"></i>
                                <g:message code="label.view"/>
                            </a>
                            <a class="btn btn-sm btn-dark" role="button" title="View Record"
                               data-bind="attr:{href:getSiteEditUrl()},visible: canEdit">
                                <i class="fas fa-pencil-alt"></i>
                                <g:message code="label.edit"/>
                            </a>
                            <a class="btn btn-sm btn-dark" role="button"
                               title="<g:message code="title.add.favourites"/>"
                               data-bind="click:addSiteToFavourites,visible: showAddToFavourites">
                                <i class="far fa-solid fa-heart"></i>
                                <g:message code="label.add.favourite"/>
                            </a>
                            <a class="btn btn-sm btn-dark" role="button"
                               title="<g:message code="title.remove.favourites"/>"
                               data-bind="click:removeSiteFromFavourites,visible: showRemoveFromFavourites">
                                <i class="fas fa-heart-broken"></i>
                                <g:message code="label.remove.favourite"/>
                            </a>
                            <a class="btn btn-sm btn-dark" role="button" title="<g:message code="title.delete"/>"
                               data-bind="visible: canDelete, click: deleteSite">
                                <i class="far fa-trash-alt"></i>
                                <g:message code="label.delete"/>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /ko -->
        <!-- ko if: sites().length == 0 -->
        <div class="col-12 col-lg-6 d-flex mt-3">
            <h4 data-bind="visible: sitesLoaded()">No sites found</h4>
        </div>
        <!-- /ko -->
    </div>
</bc:koLoading>