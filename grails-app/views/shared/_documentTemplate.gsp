<script id="imageDocTmpl" type="text/html">
<span class="pull-left" style="width:32px;height:32px;">
    <img class="media-object img-rounded span1" data-bind="attr:{src:thumbnailUrl}, alt:name" style="width:32px;height:32px;" width="32" height="32" alt="image preview icon">
</span>
<div class="media-body">
    <a class="btn btn-mini pull-right" data-bind="attr:{href:url}, clickBubble: false" target="_blank">
        <i class="fa fa-download"></i>
    </a>
    <span>
        <small class="media-heading" data-bind="text:name"></small>
    </span>
    <span class="muted" data-bind="if:$data.attribution">
        <small data-bind="text:attribution"></small>
    </span>
</div>
</script>

<script id="objDocTmpl" type="text/html">
<span class="pull-left">
    <img class="media-object" data-bind="attr:{src:filetypeImg(), alt:name}" alt="document icon">
</span>
<div class="media-body">
    <a class="btn btn-mini pull-right" data-bind="attr:{href:url}, clickBubble: false" target="_blank">
        <i class="fa fa-download"></i>
    </a>
    <span>
        <small class="media-heading" data-bind="text:name"></small>
    </span>
    <span class="muted" data-bind="if:$data.attribution">
        <small data-bind="text:attribution"></small>
    </span>
</div>
</script>

<script id="imageDocEditTmpl" type="text/html">
<div class="btn-group pull-left" style="margin-top:4px;">
    <button class="btn btn-mini" type="button" data-bind="enable:!readOnly,click:$root.deleteDocument"><i class="icon-remove"></i></button>
    <button class="btn btn-mini" type="button" data-bind="enable:!readOnly,click:$root.editDocumentMetadata"><i class="icon-edit"></i></button>
</div>
<a class="pull-left" style="width:32px;height:32px;" data-bind="attr:{href:url}" target="_blank">
    <img class="media-object img-rounded span1" data-bind="attr:{src:thumbnailUrl, alt:name}" style="width:32px;height:32px;"  alt="image preview icon">
</a>
<div data-bind="template:'imgMediaBody'"></div>
</script>

<script id="objDocEditTmpl" type="text/html">
<div class="btn-group pull-left" style="margin-top:4px;">
    <button class="btn btn-mini" type="button" data-bind="enable: !readOnly && role() != 'methodDoc',click:$root.deleteDocument"><i class="icon-remove"></i></button>
    <button class="btn btn-mini" type="button" data-bind="enable: !readOnly && role() != 'methodDoc',click:$root.editDocumentMetadata"><i class="icon-edit"></i></button>
</div>
<a class="pull-left" data-bind="attr:{href:url}">
    <img class="media-object" data-bind="attr:{src:filetypeImg(), alt:name}" alt="document icon">
</a>
<div data-bind="template:'docMediaBody'"></div>
</script>

<script id="docMediaBody" type="text/html">
<div class="media-body">
    <a class="btn btn-mini pull-right" data-bind="attr:{href:url}" target="_blank">
        <i class="fa fa-download"></i>
    </a>
    <a data-bind="attr:{href:url}">
        <small class="media-heading" data-bind="text:name"></small>
    </a>
    <span class="muted" data-bind="if:$data.attribution">
        <small data-bind="text:attribution"></small>
    </span>
</div>
</script>

<script id="imgMediaBody" type="text/html">
<div class="media-body">
    <a class="btn btn-mini pull-right" data-bind="attr:{href:url}" target="_blank">
        <i class="fa fa-download"></i>
    </a>
    <a data-bind="attr:{href:url}" target="_blank">
        <small class="media-heading" data-bind="text:name"></small>
    </a>
    <span class="muted" data-bind="if:$data.attribution">
        <small data-bind="text:attribution"></small>
    </span>
</div>
</script>


<script id="documentEditTemplate" type="text/html">
    <div class="clearfix space-after media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocEditTmpl' : 'objDocEditTmpl'"></div>
</script>
<script id="documentViewTemplate" type="text/html">
    <div class="clearfix space-after media" data-bind="template:ko.utils.unwrapObservable(type) === 'image' ? 'imageDocTmpl' : 'objDocTmpl'"></div>
</script>

