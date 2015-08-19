<!-- ko stopBinding: true -->
<div id="declaration" class="modal hide fade">
    <g:set var="legalDeclaration"><fc:getSettingContent settingType="${au.org.ala.biocollect.merit.SettingPageType.DECLARATION}"/></g:set>
    <div class="modal-header hide">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h3>Declaration</h3>
    </div>
    <div class="modal-body">
        ${legalDeclaration}
    </div>
    <div class="modal-footer">
        <label for="acceptTerms" class="pull-left">
            <g:checkBox name="acceptTerms" data-bind="checked:termsAccepted" style="margin:0;"/>&nbsp;
            I agree with the above declaration.
        </label>
        <button class="btn btn-success" data-bind="click:submitReport, enable:termsAccepted" data-dismiss="modal" aria-hidden="true">Submit</button>
        <button class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>
    </div>
</div>
<!-- /ko -->