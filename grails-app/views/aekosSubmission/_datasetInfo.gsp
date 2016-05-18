<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 2 of 9 - Dataset Description</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetTitle"><g:message code="aekos.dataset.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.info.name"/>',
                              content:'<g:message code="aekos.dataset.info.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <input id="datasetTitle" data-bind="value: aekosModalView().datasetTitle" style="width: 90%">
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="projectAim"><g:message code="aekos.project.objective"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.objective"/>',
                          content:'<g:message code="aekos.project.objective.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="projectAim" data-bind="value: aekosModalView().projectViewModel.aim()" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.dataset.summary"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.summary"/>',
                          content:'<g:message code="aekos.dataset.summary.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="activityDescription" data-bind="value: aekosModalView().description" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.dataset.version"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.version"/>',
                          content:'<g:message code="aekos.dataset.version.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="datasetVersion" data-bind="value: aekosModalView().currentDatasetVersion"></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.project.keywords"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.keywords"/>',
                          content:'<g:message code="aekos.project.keywords.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="projectKeywords" data-bind="value: aekosModalView().projectViewModel.keywords()"rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.activity.usageGuide"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.usageGuide"/>',
                          content:'<g:message code="aekos.activity.usageGuide.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="usageGuide" data-bind="value: aekosModalView().usageGuide" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.activity.relatedDatasets"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.relatedDatasets"/>',
                          content:'<g:message code="aekos.activity.relatedDatasets.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: $parent.projectActivities -->

                        <!-- ko if: $parent.projectActivityId != aekosModalView().projectActivityId -->
                        <input type="checkbox" data-bind="checkedValue: projectActivityId, checked: $parent.relatedDatasets" />

                        <span data-bind="text: name"></span>

                    </br>

                        <!-- /ko -->

                        <!-- /ko -->

                    </div>
                </div>
            </div>
        </div>
    </div>

    <br>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="activityDescription"><g:message code="aekos.activity.urlImage"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.urlImage"/>',
                          content:'<g:message code="aekos.activity.urlImage.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <!--textarea id="urlImage" data-bind="value: aekosModalView().project.urlImage" rows="3" style="width: 90%"></textarea-->
                <textarea></textarea>
            </div>
        </div>
    </div>




</div>