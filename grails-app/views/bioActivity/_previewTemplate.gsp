<div class="modal fade previewModal hide h-100" id="previewModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" >
    <div class="modal-dialog modal-xl h-100">
        <div class="modal-content h-100">
            <div class="modal-header">
                    <h3 class="w-100">
                        <span data-bind="text: pActivityFormName()"></span> Template
                        <button type="button" class="close float-right" data-bind="click: hideModal" aria-hidden="true">&times;</button>
                    </h3>
            </div>

            <div class="modal-body" id="previewModalBody">
                <iFrame data-bind="attr: {src: previewUrl}" frameborder="0" width="100%" height="100%" >
                </iFrame>
            </div>

            <div class="modal-footer" id="footer">
                <button type="button" id="cancel" class="btn btn-dark" data-bind="click: hideModal"><i class="far fa-times-circle"></i> Cancel</button>
            </div>
        </div>
   </div>
</div>
