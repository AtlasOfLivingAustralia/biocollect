<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 8 of 9 - Dataset Contact and Author(s)</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactDetails"><g:message code="aekos.contact.title"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <select id="datasetContactDetails" data-bind="options: transients.titleOptions,
                                                      value: aekosModalView().datasetContactDetails,
                                                      optionsCaption: '--Please Select--'"></select>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactName"><g:message code="aekos.contact.name"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="datasetContactName" data-bind="value: aekosModalView().datasetContactName" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactRole"><g:message code="aekos.contact.role"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="datasetContactRole" data-bind="value: aekosModalView().datasetContactRole" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactPhone"><g:message code="aekos.contact.phone"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="datasetContactPhone" data-bind="value: aekosModalView().datasetContactPhone" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactEmail"><g:message code="aekos.contact.email"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="datasetContactEmail" data-bind="value: aekosModalView().datasetContactEmail" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetContactAddress"><g:message code="aekos.contact.address"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="datasetContactAddress" data-bind="value: aekosModalView().datasetContactAddress" style="width: 90%" ></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="organisationName"><g:message code="aekos.contact.organisation"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="organisationName" data-bind="text: aekosModalView().projectViewModel.organisationName" ></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="authorGivenNames"><g:message code="aekos.dataset.author.name"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="authorGivenNames" data-bind="value: aekosModalView().authorGivenNames" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="authorSurname"><g:message code="aekos.contact.authorSurname"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="authorSurname" data-bind="value: aekosModalView().authorSurname" >
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="authorAffiliation"><g:message code="aekos.contact.authorAffiliation"/>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="authorAffiliation" data-bind="value: aekosModalView().authorAffiliation" >
            </div>
        </div>
    </div>

</div>