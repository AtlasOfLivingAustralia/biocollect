<div id="datasetContact" >

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
                <select id="datasetContactDetails" data-validation-engine="validate[required]" data-bind="options: transients.titleOptions,
                                                          value: currentSubmissionPackage.datasetContact.title,
                                                          optionsCaption: '--Please Select--'"></select>
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="datasetContactName"><g:message code="aekos.contact.name"/>
                    <span class="req-field"></span></label>
                </label>
            </div>

            <div class="span8">
               <input id="datasetContactName" data-bind="value: currentSubmissionPackage.datasetContact.name" data-validation-engine="validate[required]">
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="datasetContactRole"><g:message code="aekos.contact.role"/>
                    <span class="req-field"></span></label>
                </label>
            </div>

            <div class="span8">
               <input id="datasetContactRole" data-bind="value: currentSubmissionPackage.datasetContact.role" data-validation-engine="validate[required]">
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="datasetContactPhone"><g:message code="aekos.contact.phone"/>
                    <span class="req-field"></span></label>
                </label>
            </div>

            <div class="span8">
               <input id="datasetContactPhone" data-bind="value: currentSubmissionPackage.datasetContact.phone" data-validation-engine="validate[required]">
            </div>
        </div>

        <div class="row-fluid">
            <div class="span4 text-right">
                <label class="control-label" for="datasetContactEmail"><g:message code="aekos.contact.email"/>
                    <span class="req-field"></span></label>
                </label>
            </div>

            <div class="span8">
               <input id="datasetContactEmail" data-bind="value: currentSubmissionPackage.datasetContact.email" data-validation-engine="validate[required]">
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
                    <textarea id="datasetContactAddress" data-bind="value: currentSubmissionPackage.datasetContact.address" style="width: 90%" data-validation-engine="validate[required]"></textarea>
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
               <span id="organisationName" data-bind="text: projectViewModel.organisationName" ></span>
            </div>
        </div>
    </div>
    </div>

    <br/><br/><br/>

    <div class="panel panel-default" >
        <div class="panel-heading"><h5 class="strong">Dataset Authors</h5></div>
        <div class="panel-body">

            <!-- ko foreach: currentSubmissionPackage.datasetAuthors() -->
            <div style="border: 1px solid lightgrey;" data-bind="attr: {id: 'datasetAuthors-' + $index()}" >
            <br>
            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label"><g:message code="aekos.dataset.author.name"/>

                    </label>
                </div>

                <div class="span8">
                   <input class="multiInput" name="authorGivenNames" data-bind="value: authorInitials" >
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label"><g:message code="aekos.contact.authorSurname"/>
                        <span class="req-field"></span></label>
                    </label>
                </div>

                <div class="span8" >
                    <input  class="multiInput" name="authorSurname" data-bind="value: authorSurnameOrOrgName" data-validation-engine="validate[required]">
                </div>
            </div>

            <div class="row-fluid">
                <div class="span4 text-right">
                    <label class="control-label"><g:message code="aekos.contact.authorAffiliation"/>
                        <span class="req-field"></span></label>
                    </label>
                </div>

                <div class="span8">
                   <input class="multiInput" name="authorAffiliation" data-bind="value: authorAffiliation" data-validation-engine="validate[required]">
                </div>
            </div>
            <div class="row-fluid" data-bind="visible: $index() > 0">
                <div class="span10">
                    <div class="text-right">
                        <button class="btn btn-small block" data-bind="click: function() {$root.removeAuthorRow($index())}">Remove Author%{--<i class="icon-black icon-tasks" ></i>--}%</button>
                    </div>
                </div>
            </div>

            <br>

        </div>

            <!-- /ko -->

        </div>
        <div class="text-right">
            <button class="btn-info btn btn-small block" data-bind="click: function() {addAuthorRow()}">Add Author%{--<i class="icon-black icon-tasks" ></i>--}%</button>
        </div>
    </div>
</div>

</div>