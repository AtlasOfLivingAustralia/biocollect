
<style>

.previewModal{
    width: 90%; /* desired relative width */
    min-height:80%;
    left: 5%; /* (100%-width)/2 */
    margin: auto auto auto auto; /* place center */}

.previewModal .modal-body{overflow-y:scroll;max-height:none;position:absolute;top:50px;bottom:50px;right:0px;left:0px;}

.previewModal .modal-footer {position: absolute;bottom: 0;right: 0;left: 0;}


</style>

<div class="modal fade previewModal hide" id="previewModal" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" >
    <div class="modal-dialog">
        <div class="modal-header">
            <div>
                <h3 align="center">
                    <span data-bind="text: pActivityFormName()"></span> Template
                    <button type="button" class="close" data-bind="click: hideModal" aria-hidden="true">&times;</button>
                </h3>
            </div>
        </div>

        <div class="modal-body" id="previewModalBody">
            <iFrame data-bind="attr: {src: previewUrl}" frameborder="0" width="100%" height="100%" >
            </iFrame>
        </div>

        <div class="modal-footer" id="footer">
        <button type="button" id="cancel" class="btn" data-bind="click: hideModal">Cancel</button>
        </div>
   </div>
</div>
