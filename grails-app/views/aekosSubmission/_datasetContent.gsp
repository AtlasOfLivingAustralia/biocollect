<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 3 of 9 - Dataset Content</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.fos"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.fos.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-width:500px; overflow: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().listFos -->
                            <div>
                                <input type="checkbox" data-bind="checkedValue: value, checked: $parent.typeFor" />

                                <span data-bind="text: name"></span>
                            </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <br/>
            <div>
                <label class="control-label"><g:message code="aekos.dataset.content.fos.extra"/></label>
                <input data-bind="value: aekosModalView().extraFos" />
                <button class="btn btn-small" data-bind="click: aekosModalView().addExtraFos">Add</button>
            </div>
            <br/>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.seo"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.seo.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-width:500px; overflow: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().listSeo -->
                        <div>
                            <input type="checkbox" data-bind="checkedValue: value, checked: $parent.typeSeo" />

                            <span data-bind="text: name"></span>
                        </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <br/>
            <div>
                <label class="control-label"><g:message code="aekos.dataset.content.seo.extra"/></label>
                <input data-bind="value: aekosModalView().extraSeo" />
                <button class="btn btn-small" data-bind="click: aekosModalView().addExtraSeo">Add</button>
            </div>
            <br/>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.research"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.research.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-width:500px; overflow: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().listResearch -->
                        <div>
                            <input type="checkbox" data-bind="checkedValue: value, checked: $parent.typeResearch" />

                            <span data-bind="text: name"></span>
                        </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <br/>
            <div>
                <label class="control-label"><g:message code="aekos.dataset.content.research.extra"/></label>
                <input data-bind="value: aekosModalView().extraResearch" />
                <button class="btn btn-small" data-bind="click: aekosModalView().addExtraResearch">Add</button>
            </div>
            <br/>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.threat"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.threat.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-width:500px; overflow: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().listThreat -->
                        <div>
                            <input type="checkbox" data-bind="checkedValue: value, checked: $parent.typeThreat" />

                            <span data-bind="text: name"></span>
                        </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <br/>
            <div>
                <label class="control-label"><g:message code="aekos.dataset.content.threat.extra"/></label>
                <input data-bind="value: aekosModalView().extraThreat" />
                <button class="btn btn-small" data-bind="click: aekosModalView().addExtraThreat">Add</button>
            </div>
            <br/>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label"><g:message code="aekos.dataset.content.conservation"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'',
                          content:'<g:message code="aekos.dataset.content.conservation.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-width:500px; overflow: scroll; background:#ffffff;">

                        <!-- ko foreach: aekosModalView().listConservation -->
                        <div>
                            <input type="checkbox" data-bind="checkedValue: value, checked: $parent.typeConservation" />

                            <span data-bind="text: name"></span>
                        </div>
                        <!-- /ko -->

                    </div>
                </div>
            </div>
            <br/>
            <div>
                <label class="control-label"><g:message code="aekos.dataset.content.conservation.extra"/></label>
                <input data-bind="value: aekosModalView().extraConservation" />
                <button class="btn btn-small" data-bind="click: aekosModalView().addExtraConservation">Add</button>
            </div>
            <br/>
        </div>
    </div>
</div>