<div id="fileupload" data-url="<g:createLink controller='image' action='upload'/>" data-bind="${databindAttrs}"
     class="fileupload-buttonbar">

    <table><tbody class="files"></tbody></table>
    <!-- The fileinput-button span is used to style the file input field as button -->
    <span class="btn fileinput-button">
        <i class="icon-plus"></i>
        <input type="file" name="files" multiple/>
        <span data-bind="visible:${source}().length">Add more images</span>
        <span data-bind="visible:!${source}().length">Add images</span>
    </span>

</div>