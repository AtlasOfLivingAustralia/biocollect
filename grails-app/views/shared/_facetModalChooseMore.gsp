<g:set var="modalName" value="${modalId ?: 'chooseMore'}"></g:set>
<div id="${modalName}" class="modal" role="dialog" tabindex="-1">
    <div class="modal-dialog ">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title" data-bind="text: displayTitle('<g:message code="facet.dialog.more.title"
                                                                                    default="Filter by"/>')"></span>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
                    
                </button>
            </div>

            <div class="modal-body">
                <div class="row mb-3">
                    <div class="input-group input-group-sm col-12">
                        <input class="form-control" type="text" placeholder="Search" data-bind="value: searchText">
                        <div class="input-group-append">
                            <button class="btn btn-dark">
                                <i class="fas fa-filter"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- ko foreach: showMoreTermList -->
                <label class="form-check" data-bind="visible: showTerm()">
                    <input class="form-check-input" type="checkbox" data-bind="checked: checked">
                    <label class="form-check-label"
                           data-bind="text:displayName, click: filterNow, attr:{title: displayName}"
                           data-bs-dismiss="modal"></label>
                </label>
                <!-- /ko -->
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-primary-dark" data-bind="click: includeSelection"
                        data-bs-dismiss="modal">
                    <i class="fas fa-plus-circle"></i>
                    <g:message code="facet.dialog.more.include" default="INCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-sm btn-primary-dark" data-bind="click: excludeSelection"
                        data-bs-dismiss="modal">
                    <i class="fas fa-minus-circle"></i>
                    <g:message code="facet.dialog.more.exclude" default="EXCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-sm btn-dark" data-bs-dismiss="modal" aria-label="Close">
                    
                    <g:message code="facet.dialog.more.close" default="Close"/>
                </button>

            </div>
        </div>

    </div>
</div>