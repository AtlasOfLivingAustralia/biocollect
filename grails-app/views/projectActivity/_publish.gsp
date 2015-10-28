
<div class="row-fluid">
    <div class="span12 label-" >
        <div class="span6 text-left">
            <label>Survey status: <span data-bind="attr:{'class': published() ? 'badge badge-success' : 'badge badge-important'}, text: published() ? 'Published' : 'Unpublished'"></span></label>
        </div>
        <div class="span6 text-right">
            <button data-bind="attr:{'class': published() ? 'btn btn-primary btn-small' : 'btn btn-success btn-small'}, click: $root.updateStatus, text: published() ? 'Unpublish' : 'Publish',disable: !transients.saveOrUnPublishAllowed()"></button>
        </div>
    </div>

</div>

