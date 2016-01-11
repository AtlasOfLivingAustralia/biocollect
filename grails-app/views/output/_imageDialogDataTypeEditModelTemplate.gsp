<g:set var="modalId" value="${name?.replace('.','')}Modal"></g:set>
<a role="button" class="btn" data-toggle="modal" data-bind="attr: {href: '#'+ '${modalId}' + $index() }"> <i class="icon-plus"></i> View saved photos</a>
<div id="" class="modal hide fade large" data-bind="attr:{id: '${modalId}' + $index()}">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Dialog for adding photos</h3>
    </div>
    <div class="modal-body">
        <g:render template="/output/imageDataTypeEditModelTemplate" model="${[name: name]}"/>
    </div>
    <div class="modal-footer">
        <a href="#" class="btn" data-dismiss="modal" aria-hidden="true">Close</a>
        <a href="#" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">Save</a>
    </div>
</div>