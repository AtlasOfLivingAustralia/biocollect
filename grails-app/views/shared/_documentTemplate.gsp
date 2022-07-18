<script id="imageDocTmpl" type="text/html">
<div class="image" data-bind="style:{'background-image':'url(' + thumbnailUrl + ')'}, alt:name" data-preview="filename.jpg">
    <div class="hover">
        <i class="far fa-eye fa-2x"></i>
        <span>Preview</span>
    </div>
</div>
<div class="content">
    <h4 style="font-weight: normal" data-bind="text:name"></h4>
    <div>
        <div class="author" data-bind="if:$data.attribution">Author Name: <!-- ko text:attribution --> <!-- /ko --></div>
        <a href="#" class="btn btn-sm btn-primary-dark mt-1" data-bind="attr:{href:url}, clickBubble: false"><i class="fas fa-download"></i> Download</a>
    </div>
</div>
</script>

<script id="objDocTmpl" type="text/html">
<div>
    <div class="image" data-bind="style:{'background-image': 'url(' + filetypeImg() + ')'}, alt:name" data-preview="filename.jpg">
        <div class="hover" data-bind="visible:!transients.isPreviewVisible()">
            <i class="far fa-eye fa-2x"></i>
            <span>Preview</span>
        </div>
    </div>
    <div class="role" data-bind="if:$data.role"><!-- ko text:$parent.mapDocument(role()) --> <!-- /ko --></div>
</div>
<div class="content">
    <h4 style="font-weight: normal" data-bind="text:name"></h4>
    <div>
        <div class="author" data-bind="if:$data.attribution">Author Name: <!-- ko text:attribution --> <!-- /ko --></div>
        <a href="#" class="btn btn-sm btn-primary-dark mt-1" data-bind="click:$parent.isHtmlViewer"><i class="far fa-eye"></i> Description</a>
        <a href="#" class="btn btn-sm btn-primary-dark mt-1" data-bind="click:'url(' + filetypeImg() + ')', visible:!transients.isPreviewVisible()"><i class="far fa-eye"></i> Preview</a>
        <a href="#" class="btn btn-sm btn-primary-dark mt-1" data-bind="attr:{href:url}, visible:!transients.isDownloadVisible(), clickBubble: false"><i class="fas fa-download"></i> Download</a>
    </div>
</div>
</script>

<script id="imageDocEditTmpl" type="text/html">
<div class="resource mb-1 align-items-start overflow-hidden">
    <div class="image" data-bind="style:{'background-image':'url(' + thumbnailUrl + ')'}, alt:name"></div>
    <div class="content" data-bind="template: 'resourceDetailsTmpl'"></div>
</div>
</script>

<script id="objDocEditTmpl" type="text/html">
<div class="resource mb-1 align-items-start overflow-hidden">
    <div class="image" data-bind="style:{'background-image':'url(' + filetypeImg() + ')'}, alt:name"></div>
    <div class="content" data-bind="template: 'resourceDetailsTmpl'"></div>
</div>
</script>

<script id="resourceDetailsTmpl" type="text/html">
<a data-bind="attr:{href:url}, text:name"></a>
<div>
    <div class="author" data-bind="if:$data.attribution">Author Name: <!-- ko text:attribution --><!-- /ko --></div>
    <div class="btn-space">
        <a class="btn btn-sm btn-primary-dark" data-bind="attr:{href:url}" target="_blank">
            <i class="fas fa-download"></i>
        </a>
        <button class="btn btn-sm btn-dark" type="button" data-bind="enable:!readOnly,click:$root.editDocumentMetadata"><i class="fas fa-pencil-alt"></i></button>
        <button class="btn btn-sm btn-danger" type="button" data-bind="enable:!readOnly,click:$root.deleteDocument"><i class="far fa-trash-alt"></i></button>
    </div>
</div>
</script>


<script id="documentEditTemplate" type="text/html">
    <div data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocEditTmpl' : 'objDocEditTmpl'"></div>
</script>
<script id="documentViewTemplate" type="text/html">
    <div data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocTmpl' : 'objDocTmpl'"></div>
</script>

