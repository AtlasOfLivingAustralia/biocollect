<div class="row-fluid" id="${containerId}">
    <div data-bind="foreach:documents">
		<span data-bind="if: (role() == '${filterBy}' || 'all' == '${filterBy}') && role() != '${ignore}' && role() != 'variation' ">
            <g:if test="${editable}">
                <div class="clearfix space-after media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocEditTmpl' : 'objDocEditTmpl'"></div>
            </g:if>
            <g:else>
                <div class="clearfix space-after media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocTmpl' : 'objDocTmpl'"></div>
            </g:else>
         </span>
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