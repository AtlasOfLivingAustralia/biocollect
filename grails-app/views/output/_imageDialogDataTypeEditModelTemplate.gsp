<g:set var="modalId" value="${name?.replace('.','')}Modal"></g:set>
<a href="#${modalId}" role="button" class="btn" data-toggle="modal"> <i class="icon-plus"></i> View photos</a>
<div id="${modalId}" class="modal hide fade large">
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