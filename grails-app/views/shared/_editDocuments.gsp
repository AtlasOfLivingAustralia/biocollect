<div class="row" id="${containerId}">
    <div data-bind="col-12">
        <!-- ko if: documents().length > 0 -->
            <div data-bind="foreach: { data: documents, afterAdd: showListItem, beforeRemove: hideListItem }">
                <div data-bind="{ if: (role() == '${filterBy}' || 'all' == '${filterBy}') && role() != '${ignore}' && role() != 'variation' }">
                    <div class="media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocEditTmpl' : 'objDocEditTmpl'"></div>
                </div>
            </div>
        <!-- /ko -->
    </div>
</div>

<g:render template="/shared/documentTemplate"></g:render>
<asset:script type="text/javascript">
    var imageLocation = "${imageUrl}",
        useExistingModel = ${useExistingModel};

    $(window).on('load', function () {

        if (!useExistingModel) {

            var docListViewModel = new DocListViewModel(${documents ?: []});
            ko.cleanNode(document.getElementById('${containerId}'));
            ko.applyBindings(docListViewModel, document.getElementById('${containerId}'));
        }
    });

</asset:script>