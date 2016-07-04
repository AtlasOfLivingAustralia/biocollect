<div id="datasetInfo" >

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
            <div class="controls">
                <div id="samplingDesign" class="panel panel-default" >
                    <div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().samplingDesignList -->

                        <input type="checkbox" data-bind="checkedValue: $data, checked: $parent.samplingDesign" />

                        <span data-bind="text: $data"></span>

                        <br/>

                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>
    </div>
    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="samplingDesignSuggest"><g:message code="aekos.other.sampling.design"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.other.sampling.design"/>',
                              content:'<g:message code="aekos.other.sampling.design.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="samplingDesignSuggest" data-bind="value: aekosModalView().samplingDesignSuggest" rows="1" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <div id="measurementTheme" class="panel panel-default" >
                    <div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().measurementThemeList -->

                        <input type="checkbox" data-bind="checkedValue: $data, checked: $parent.measurementTheme" />

                        <span data-bind="text: $data"></span>

                        <br/>

                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>
    </div>

    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="measurementThemeSuggest"><g:message code="aekos.measurement.theme.suggest"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.measurement.theme.suggest"/>',
                              content:'<g:message code="aekos.measurement.theme.suggest.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="measurementThemeSuggest" data-bind="value: aekosModalView().measurementThemeSuggest" rows="1" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <div id="measurement" class="panel panel-default" >
                    <div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().measurementList -->

                        <input type="checkbox" data-bind="checkedValue: $data, checked: $parent.measurement" />

                        <span data-bind="text: $data"></span>

                        <br/>

                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>
    </div>

    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="measurementSuggest"><g:message code="aekos.method.measurement.suggest"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.measurement.suggest"/>',
                              content:'<g:message code="aekos.method.measurement.suggest.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="measurementSuggest" data-bind="value: aekosModalView().measurementSuggest" rows="1" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <input id="methodName" data-bind="value: aekosModalView().methodName" data-validation-engine="validate[required]" style="width: 95%">
            </div>
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
            <div class="controls">
                <textarea id="methodAbstract" data-bind="value: aekosModalView().methodAbstract" data-validation-engine="validate[required]" rows="3" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <textarea id="methodDriftDescription" data-bind="value: aekosModalView().methodDriftDescription" rows="3" style="width: 90%"></textarea>
            </div>
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
            <div class="controls">
                <div id="artefacts" class="panel panel-default" >
                    <div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().artefactsList -->

                        <input type="checkbox" data-bind="checkedValue: $data, checked: $parent.artefacts" />

                        <span data-bind="text: $data"></span>

                        <br/>

                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>
    </div>

    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="artefactsSuggest"><g:message code="aekos.method.drift.description"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.method.drift.description"/>',
                              content:'<g:message code="aekos.method.drift.description.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="artefactsSuggest" data-bind="value: aekosModalView().artefactsSuggest" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

</div>