<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 8 of 9 - Dataset Contact and Author(s)</h4>
        </div>
    </div>
    <div class="container">
    <div class="panel panel-default" class="well">
        <div class="panel-heading"><h5 class="strong">Dataset Contact</h5></div>
        <div class="panel-body">
        %{--<div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">--}%

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="datasetContactDetails"><g:message code="aekos.contact.title"/>
                    <span class="req-field"></span></label>
                </label>
            </div>

            <div class="span8">
                <div class="controls">
                    <select id="datasetContactDetails" data-validation-engine="validate[required]" data-bind="options: transients.titleOptions,
                                                          value: datasetContactDetails,
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
                    <input id="datasetContactName" data-bind="value: datasetContactName" data-validation-engine="validate[required]">
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
                    <input id="datasetContactRole" data-bind="value: datasetContactRole" data-validation-engine="validate[required]">
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
                    <input id="datasetContactPhone" data-bind="value: datasetContactPhone" data-validation-engine="validate[required]">
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
                    <input id="datasetContactEmail" data-bind="value: datasetContactEmail" data-validation-engine="validate[required]">
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
                    <textarea id="datasetContactAddress" data-bind="value: datasetContactAddress" style="width: 90%" data-validation-engine="validate[required]"></textarea>
                </div>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="organisationName"><g:message code="aekos.contact.organisation"/>
                    %{--<span class="req-field"></span></label>--}%
                </label>
            </div>

            <div class="span8">
                <div class="controls">
                    <span id="organisationName" data-bind="text: projectViewModel.organisationName" ></span>
                </div>
            </div>
        </div>
    </div>
    </div>

    <br/><br/><br/>

    <div class="panel panel-default" >
        <div class="panel-heading"><h5 class="strong">Dataset Author</h5></div>
        <div class="panel-body">

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label" for="authorGivenNames"><g:message code="aekos.dataset.author.name"/>

                    </label>
                </div>

                <div class="span8">
                    <div class="controls">
                        <input id="authorGivenNames" data-bind="value: authorGivenNames" >
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
                        <input id="authorSurname" data-bind="value: authorSurname" data-validation-engine="validate[required]">
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
                        <input id="authorAffiliation" data-bind="value: authorAffiliation" data-validation-engine="validate[required]">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</div>