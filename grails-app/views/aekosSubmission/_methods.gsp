<div id="collectionMethods" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 7 of 9 - Data Collection Methods</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="samplingDesign"><g:message code="aekos.sampling.design"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.sampling.design"/>',
                              content:'<g:message code="aekos.sampling.design.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div id="samplingDesign" data-bind="treeView: {data: transients.samplingDesign,
                                                           extraFieldLabel: '<g:message code="aekos.sampling.design.suggest"/>'}" ></div>
       </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="measurementTheme"><g:message code="aekos.measurement.theme"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.measurement.theme"/>',
                              content:'<g:message code="aekos.measurement.theme.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

         <div class="span8">
             <div id="measurementTheme" data-bind="treeView: {data: transients.observationMeasurements,
                                       extraFieldLabel: '<g:message code="aekos.measurement.theme.suggest"/>'}" ></div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="measurement"><g:message code="aekos.method.measurement"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.measurement"/>',
                              content:'<g:message code="aekos.method.measurement.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div id="measurement" data-bind="treeView: {data: transients.observedAttributes,
                                       extraFieldLabel: '<g:message code="aekos.method.measurement.suggest"/>'}" ></div>

        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="methodName"><g:message code="aekos.method.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.name"/>',
                              content:'<g:message code="aekos.method.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8">
            <input id="methodName" data-bind="value: methodName" data-validation-engine="validate[required]" style="width: 95%">
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="methodAbstract"><g:message code="aekos.method.description"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.description"/>',
                              content:'<g:message code="aekos.method.description.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8">
           <textarea id="methodAbstract" data-bind="value: methodAbstract" data-validation-engine="validate[required]" rows="3" style="width: 90%"></textarea>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="methodDriftDescription"><g:message code="aekos.method.drift.description"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.drift.description"/>',
                              content:'<g:message code="aekos.method.drift.description.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <textarea id="methodDriftDescription" data-bind="value: currentSubmissionPackage.methodDriftDescription" rows="3" style="width: 90%"></textarea>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="artefacts"><g:message code="aekos.other.artefacts"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.other.artefacts"/>',
                              content:'<g:message code="aekos.other.artefacts.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div id="artefacts" data-bind="treeView: {data: transients.identificationMethod,
                                       extraFieldLabel: '<g:message code="aekos.other.artefacts.suggest"/>'}" ></div>
        </div>
    </div>



</div>