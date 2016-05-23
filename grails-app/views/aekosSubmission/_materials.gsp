<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 6 of 9 - Environmental Features and Associated/Supplementary Materials</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="environmentFeatures"><g:message code="aekos.environment.features"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.environment.features"/>',
                              content:'<g:message code="aekos.environment.features.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
        </label>
        </div>

        <div class="span8">
            <div class="controls">

            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="otherEnvironmentFeatures"><g:message code="aekos.other.environment.features"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.other.environment.features"/>',
                              content:'<g:message code="aekos.other.environment.features.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
        </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="otherEnvironmentFeatures" data-bind="value: aekosModalView().otherEnvironmentFeatures" rows="1" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <select id="materialType" data-bind="options: associatedMaterialTypes,
                                                      value: aekosModalView().selectedMaterialType,
                                                      optionsCaption: 'N/A'"></select>
            </div>
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
            <div class="controls">
                <input id="otherMaterials" data-bind="value: aekosModalView().otherMaterials">
            </div>
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
            <div class="controls">
                <textarea id="associatedMaterialName" data-bind="value: aekosModalView().associatedMaterialNane" rows="3" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <select id="materialIdentifier" data-bind="options: aekosModalView().materialIdentifierTypes,
                                                      value: aekosModalView().selectedMaterialIdentifier,
                                                      optionsCaption: 'N/A'"></select>
            </div>
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
            <div class="controls">
                <input id="associatedMaterialIdentifier" data-bind="value: aekosModalView().associatedMaterialIdentifier">
            </div>
        </div>
    </div>

</div>