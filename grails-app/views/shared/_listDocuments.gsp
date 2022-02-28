<div id="projectResources" class="my-4 my-md-5">

    <div class="container-fluid">

        <h2>Resources</h2>

        <div class="row" id="${containerId}">
            <div class="col-12 col-md-12 col-lg-4 col-xl-4">
                <div class="form-group d-flex search-resources">
                    <label for="searchResources" class="sr-only">Search Resources</label>
                    <input type="text" id="searchResources" class="form-control" name="Search Resources" data-bind="textInput: documentFilter" placeholder="Search Resources...">
                    <label for="searchType" class="sr-only">Sort by</label>
                    <select id="searchType" class="form-control custom-select" data-bind="options: documentFilterFieldOptions, value: documentFilterField, optionsText: 'label'" aria-label="Sort Order">
                    </select>
                </div>
                <div class="search-results">
                    <!-- ko if: filteredDocuments().length == 0 -->
                    <h4 class="text-center">No documents</h4>
                    <!-- /ko -->
                    <!-- ko foreach: { data: filteredDocuments, afterAdd: showListItem, beforeRemove: hideListItem } -->
                    <div class="resource align-items-start overflow-hidden" data-bind="{ if: (role() == '${filterBy}' || 'all' == '${filterBy}') && role() != '${ignore}' && role() != 'variation', click: $parent.selectDocument, css: { active: $parent.selectedDocument() == $data } }">
                        <!-- ko template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocTmpl' : 'objDocTmpl' --><!-- /ko -->
                    </div>
                    <!-- /ko -->
                </div>
            </div>

            <div class="col-12 col-md-12 col-lg-8 col-xl-8 d-block">
                <div id="preview" class="w-100" data-bind="{ template: { name: previewTemplate } }">
                </div>
            </div>
        </div>

    </div>

</div>

<script id="htmlViewer" type="text/html">
<div class="w-100 h-100">
    <p>Test</p>
</div>
</script>

<script id="iframeViewer" type="text/html">
<div class="w-100 h-100">
    <iframe class="w-100 h-100 border-0 fc-resource-preview" data-bind="attr: {src: selectedDocumentFrameUrl}">
        <p>Your browser does not support iframes <i class="fa fa-frown-o"></i>.</p>
    </iframe>
</div>
</script>

<script id="xssViewer" type="text/html">
<div class="w-100" data-bind="html: selectedDocument().embeddedVideo"></div>
</script>

<script id="noPreviewViewer" type="text/html">
    <span class="instructions">
        There is no preview available for this file.
    </span>
</script>

<script id="noViewer" type="text/html">
    <span class="instructions">
        Select a document to preview it here.
    </span>
</script>

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