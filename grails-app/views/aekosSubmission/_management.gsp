<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 9 of 9 - Dataset Conditions of Use and Management</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="dataSharingLicense"><g:message code="aekos.management.datasharing.license"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.management.datasharing.license"/>',
                              content:'<g:message code="aekos.management.datasharing.license.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <select id="dataSharingLicense" data-bind="options: dataSharingLicenseOptions,
                                                      value: aekosModalView().dataSharingLicense,
                                                      optionsCaption: '--Please select--'"></select>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="acknowledgement"><g:message code="aekos.acknowledgement"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.acknowledgement"/>',
                              content:'<g:message code="aekos.acknowledgement.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="acknowledgement" data-bind="value: aekosModalView().acknowledgement" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="embargoOption"><g:message code="aekos.embargoOption"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.embargoOption"/>',
                              content:'<g:message code="aekos.embargoOption.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="embargoOption" data-bind="value: aekosModalView().embargoOption" >
            </div>
        </div>
    </div>


</div>