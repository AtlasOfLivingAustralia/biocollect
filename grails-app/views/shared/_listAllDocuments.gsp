<div id="projectResources" class="my-4 my-md-5">

    <div id="${containerId}" class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6 col-lg-3">
                <div class="input-group search-resources">
                    <label id="lblSearchResources" for="searchResources" class="sr-only">Search ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}</label>
                    <input class="form-control" id="searchResources" type="text" data-bind="value:searchDoc, hasFocus: searchHasFocus, valueUpdate:'keyup'"
                           placeholder="Search ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}..." aria-label="Search ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}..." aria-describedby="lblSearchResources"/>
                    <div class="input-group-append">
                        <button id="search" class="btn btn-primary-dark" data-bind="click: refreshPage(0)">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="searchType" class="input-group-text">Search in</label>
                    </div>
                    <select id="searchType" class="custom-select" data-bind="options: documentFilterFieldOptions, value: documentFilterField, optionsText: 'label'" aria-label="Filter"></select>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label for="searchInRole" class="input-group-text">Filter by type</label>
                    </div>
                    <select id="searchInRole" class="custom-select" data-bind="options:roleFilterFieldOptions, optionsText: 'name', optionsValue: 'id', value:roleFilterField"></select>
                </div>
            </div>
            <div class="col-sm-6 col-lg-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <label class="input-group-text"  for="sortBy">Sort by</label>
                    </div>
                    <select id="sortBy" class="custom-select" data-bind="value: sortBy" aria-label="Sort Order">
                        <option value="dateCreated">Recently uploaded</option>
                        <option value="lastUpdated">Recently modified</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="row mb-2">
            <div class="col-12">
                <div class="border-top border-bottom border-dark py-3">
                    <div class="row">
                        <div class="col-9">
                            <h6 class="m-0">Found <!-- ko text:pagination.totalResults --> <!-- /ko --> ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}</h6>
                        </div>
                        <div class="col-3">
                            <g:if test="${fc.userIsLoggedIn()}">
                            <div class="btn btn-default float-right" data-bind="click: downloadDocuments">
                                <i class="fas fa-download"></i> <g:message code="g.download"/>
                            </div>
                            </g:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-12 col-md-12 col-lg-4 col-xl-4">

                <div class="search-results">
                    <!-- ko if: allDocuments().length == 0 -->
                    <h4 class="text-center">No ${hubConfig.getTextForResources(grailsApplication.config.content.defaultOverriddenLabels)}</h4>

                    <!-- /ko -->
                    <!-- ko foreach: { data: allDocuments, afterAdd: showListItem, beforeRemove: hideListItem } -->
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
        <g:render template="/shared/pagination" model="[bs: 4]"/>

    </div>

</div>

<script id="htmlViewer" type="text/html">

<div class="w-100 h-100" style="padding:20px;">
    <div class="row">
        <div class="col">
            <h4 data-bind="text:selectedDocument().name()"></h4>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Project:</h6></label>
        </div>
        <div class="col">
            <a data-bind="attr:{'href': selectedDocument().transients.projectUrl()}" rel="noopener">
                <span data-bind="text: transients.truncatedName ? transients.truncatedName : selectedDocument().projectName()"></span>
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Document type:</h6></label>
        </div>
        <div class="col">
            <label id="documentType" data-bind="text:mapDocument(selectedDocument().role())"/>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Keywords:</h6></label>
        </div>
        <div class="col">
            <label id="labels" data-bind="text:selectedDocument().labels()"/>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>DOI:</h6></label>
        </div>
        <div class="col">
            <a data-bind="attr: { href: selectedDocument().doiLink() }, text: selectedDocument().doiLink()"></a>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>External Url:</h6></label>
        </div>
        <div class="col">
            <a data-bind="attr: { href: selectedDocument().externalUrl() }, text: selectedDocument().externalUrl()"></a>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Attribution:</h6></label>
        </div>
        <div class="col">
            <label id="attribution" data-bind="text:selectedDocument().attribution()"/>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Citation:</h6></label>
        </div>
        <div class="col">
            <label data-bind="text:selectedDocument().citation()"/>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>Description:</h6></label>
        </div>
        <div class="col">
            <label data-bind="text:selectedDocument().description()"/>
        </div>
    </div>

    <div class="row">
        <div class="col-2">
            <label><h6>ISBN:</h6></label>
        </div>
        <div class="col">
            <label data-bind="text:selectedDocument().isbn()"/>
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
</script>

<script id="iframeViewer" type="text/html">
<div class="w-100 h-100">
    <iframe class="w-100 h-100 border-0 fc-resource-preview" data-bind="attr: {src: selectedDocumentFrameUrl}">
        <p>Your browser does not support iframes <i class="fa fa-frown-o"></i>.</p>
    </iframe>
</div>
</script>

<script id="xssViewer" type="text/html">
<div class="w-100 text-center" data-bind="html: selectedDocument().embeddedVideo"></div>
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
        useExistingModel = ${useExistingModel},
        projectId = "${projectId}";

    $(window).on('load', function () {

        if (!useExistingModel) {
            var allDocListViewModel = new AllDocListViewModel(projectId);
            ko.cleanNode(document.getElementById('${containerId}'));
            ko.applyBindings(allDocListViewModel, document.getElementById('${containerId}'));
        }
    });

</asset:script>
