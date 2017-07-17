<div id="environmentFeaturesAndMaterials" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 6 of 9 - Environmental Features and Associated/Supplementary Materials</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="environmentFeaturesSelection"><g:message code="aekos.environment.features"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.environment.features"/>',
                              content:'<g:message code="aekos.environment.features.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div id="environmentFeaturesSelection" data-bind="treeView: {data: transients.environmentalFeatures,
                                       extraFieldLabel: '<g:message code="aekos.other.environment.features"/>'}" ></div>

        </div>
    </div>
    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="materialType"><g:message code="aekos.supplementary.material.type"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.supplementary.material.type"/>',
                              content:'<g:message code="aekos.supplementary.material.type.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <select id="materialType" data-bind="options: transients.associatedMaterialTypes,
                                                      value: currentSubmissionPackage.selectedMaterialType,
                                                      optionsCaption: 'N/A'"></select>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="otherMaterials"><g:message code="aekos.other.materials"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.other.materials"/>',
                              content:'<g:message code="aekos.other.materials.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
        </label>
        </div>

        <div class="span8">
            <input id="otherMaterials" data-bind="value: currentSubmissionPackage.otherMaterials">
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="associatedMaterialName"><g:message code="aekos.associated.material.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.associated.material.name"/>',
                          content:'<g:message code="aekos.associated.material.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <textarea id="associatedMaterialName" data-bind="value: currentSubmissionPackage.associatedMaterialNane" rows="3" style="width: 90%"></textarea>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="materialIdentifier"><g:message code="aekos.material.identifier"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.material.identifier"/>',
                          content:'<g:message code="aekos.material.identifier.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <select id="materialIdentifier" data-bind="options: transients.materialIdentifierTypes,
                                                      value: currentSubmissionPackage.selectedMaterialIdentifier,
                                                      optionsCaption: 'N/A'"></select>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="associatedMaterialIdentifier"><g:message code="aekos.associated.material.identifier"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.associated.material.identifier"/>',
                              content:'<g:message code="aekos.associated.material.identifier.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <input id="associatedMaterialIdentifier" data-bind="value: currentSubmissionPackage.associatedMaterialIdentifier">
        </div>
    </div>

</div>