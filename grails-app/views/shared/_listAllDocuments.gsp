<div id="projectResources" class="my-4 my-md-5">

    <div  id="${containerId}" class="container-fluid">

        <g:if test="${hubConfig.templateConfiguration?.header?.links}">
            <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                <g:if test="${link.contentType == 'resources'}">
                    <h2>${link.displayName}</h2>
                </g:if>
            </g:each>
        </g:if>
        <g:else>
            <h2>Resources</h2>
        </g:else>

        <div class="input-group col-12 search-resources">
            <label for="searchResources" class="sr-only">Search Resources</label>
            <g:if test="${hubConfig.templateConfiguration?.header?.links}">
                <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                    <g:if test="${link.contentType == 'resources'}">
                        <input class="form-control" id="searchResources" type="text" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'"
                               placeholder="Search ${link.displayName}..." aria-label="Search documents..." aria-describedby="org-search-button"/>
                    </g:if>
                </g:each>
            </g:if>
            <g:else>
                <input class="form-control" id="searchResources" type="text" data-bind="value:searchTerm, hasFocus: searchHasFocus, valueUpdate:'keyup'"
                       placeholder="Search Resources..." aria-label="Search documents..." aria-describedby="org-search-button"/>
            </g:else>

            <div class="input-group-append">
                <label for="searchType" class="sr-only">Filter by</label>
                <select id="searchType" class="custom-select" data-bind="options: documentFilterFieldOptions, value: documentFilterField, optionsText: 'label'" aria-label="Filter">
                </select>
            </div>

            <div class="col-md-4 text-right mt-2 mt-md-0">
                <label for="sortBy" class="col-form-label">Sort by</label>
                <select id="sortBy" class="form-control col custom-select" data-bind="value: sortBy" aria-label="Sort Order">
                    <option value="dateCreatedSort">Date uploaded</option>
                    <option value="lastUpdatedSort">Date last modified</option>
                </select>
            </div>
        </div>

        <div class="row mb-2">
            <div class="col-12">
                <div class="border-top border-bottom border-dark py-3">
                    <g:if test="${hubConfig.templateConfiguration?.header?.links}">
                        <g:each in="${hubConfig.templateConfiguration?.header?.links}" var="link">
                            <g:if test="${link.contentType == 'resources'}">
                                <h6 class="m-0">Found <!-- ko text:pagination.totalResults --> <!-- /ko --> ${link.displayName}</h6>
                            </g:if>
                        </g:each>
                    </g:if>
                    <g:else>
                        <h6 class="m-0">Found <!-- ko text:pagination.totalResults --> <!-- /ko --> Resources</h6>
                    </g:else>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12 col-md-12 col-lg-4 col-xl-4">

                <div class="search-results">
                    <!-- ko if: documents().length == 0 -->
                    <h4 class="text-center">No documents</h4>
                    <!-- /ko -->
                    <!-- ko foreach: { data: documents, afterAdd: showListItem, beforeRemove: hideListItem } -->
                    <div class="resource align-items-start overflow-hidden" data-bind="{ if: (role == '${filterBy}' || 'all' == '${filterBy}') && role != '${ignore}' && role != 'variation', click: $parent.selectDocument, css: { active: $parent.selectedDocument() == $data } }">
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
        <g:render template="/shared/pagination" model="[bs: 4]"/>

    </div>

</div>

<script id="htmlViewer" type="text/html">

<div class="container">
    <div class="row row-cols-1 align-items-start" style="padding:20px;">
        <div class="row">
            <div class="col">
                <h4 data-bind="text:selectedDocument().name"></h4>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Document type:</h6></label>
            </div>
            <div class="col">
                <label id="documentType" data-bind="text:mapDocument(selectedDocument().role)"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Keywords:</h6></label>
            </div>
            <div class="col">
                <label id="labels" data-bind="text:selectedDocument().labels"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>DOI:</h6></label>
            </div>
            <div class="col">
                <a data-bind="attr: { href: selectedDocument().doiLink }, text: selectedDocument().doiLink"></a>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Attribution:</h6></label>
            </div>
            <div class="col">
                <label id="attribution" data-bind="text:selectedDocument().attribution"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Citation:</h6></label>
            </div>
            <div class="col">
                <label data-bind="text:selectedDocument().citation"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Description:</h6></label>
            </div>
            <div class="col">
                <label data-bind="text:selectedDocument().description"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Date uploaded:</h6></label>
            </div>
            <div class="col">
                <label id="dateCreated" data-bind="text:selectedDocument().transients.dateCreated"/>
            </div>
        </div>

        <div class="row">
            <div class="col-2">
                <label><h6>Date last modified:</h6></label>
            </div>
            <div class="col">
                <label id="lastUpdated" data-bind="text:selectedDocument().transients.lastUpdated"/>
            </div>
        </div>

    </div>
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

        if (useExistingModel) {
            var allDocListViewModel = new AllDocListViewModel();
            ko.cleanNode(document.getElementById('${containerId}'));
            ko.applyBindings(allDocListViewModel, document.getElementById('${containerId}'));
        }
    });

</asset:script>