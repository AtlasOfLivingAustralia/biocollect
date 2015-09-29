<div class="row-fluid" id="${containerId}">
    <div data-bind="span12">
        <div class="well">
            <div data-bind="foreach: { data: documents, afterAdd: showListItem, beforeRemove: hideListItem }">
                <div data-bind="{ if: (role() == '${filterBy}' || 'all' == '${filterBy}') && role() != '${ignore}' && role() != 'variation' }">
                    <div class="clearfix space-after media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocEditTmpl' : 'objDocEditTmpl'"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<g:render template="/shared/documentTemplate"></g:render>
<r:script>
    var imageLocation = "${imageUrl}",
        useExistingModel = ${useExistingModel};

    $(window).load(function () {

        if (!useExistingModel) {

            var docListViewModel = new DocListViewModel(${documents ?: []});
            ko.applyBindings(docListViewModel, document.getElementById('${containerId}'));
        }
    });

</r:script>