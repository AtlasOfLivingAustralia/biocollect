<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 2 of 9 - Dataset Description</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" %{--for="datasetTitle"--}%><g:message code="aekos.dataset.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.info.name"/>',
                              content:'<g:message code="aekos.dataset.info.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                %{--<span class="req-field"></span>--}%
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="datasetTitle" data-bind="text: datasetTitle" />
                %{--<input id="datasetTitle" data-bind="value: datasetTitle" data-validation-engine="validate[required]" style="width: 90%">--}%
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetObjective"><g:message code="aekos.project.objective"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.objective"/>',
                          content:'<g:message code="aekos.project.objective.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="datasetObjective" data-bind="text: projectViewModel.aim()"></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetSummary"><g:message code="aekos.dataset.summary"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.summary"/>',
                          content:'<g:message code="aekos.dataset.summary.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="datasetSummary" data-bind="value: description"  data-validation-engine="validate[required]" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="datasetVersion"><g:message code="aekos.dataset.version"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.version"/>',
                          content:'<g:message code="aekos.dataset.version.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                %{--<span id="datasetVersion" data-bind="text: currentDatasetVersion()"></span>--}%
                <span id="datasetVersion" data-bind="text: currentSubmissionRecord.datasetVersion()"></span>

            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="projectKeywords"><g:message code="aekos.project.keywords"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.keywords"/>',
                          content:'<g:message code="aekos.project.keywords.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="projectKeywords" data-bind="value: projectViewModel.keywords()"rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="usageGuide"><g:message code="aekos.activity.usageGuide"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.usageGuide"/>',
                          content:'<g:message code="aekos.activity.usageGuide.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="usageGuide" data-bind="value: usageGuide" rows="3" style="width: 90%"></textarea>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="relatedDatasets"><g:message code="aekos.activity.relatedDatasets"/>
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
                    <div id="relatedDatasets" class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">

                        <!-- ko foreach: parentProjectActivities -->

                        <!-- ko if: $data.projectActivityId != $parent.projectActivityId -->
                        <input type="checkbox" name="relatedDatasets" class="multiselect" data-bind="checkedValue: name, checked: relatedDatasets" />

                        <span class="multiselect" data-bind="text: name"></span>

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
            <label class="control-label" for="urlImage"><g:message code="aekos.activity.urlImage"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.urlImage"/>',
                          content:'<g:message code="aekos.activity.urlImage.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <img id="urlImage" class="image-logo" data-bind="attr:{alt:transients.getImageUrl(), src: transients.getImageUrl(), onload: findLogoScalingClass(urlImage, aekosModal)}" />
            </div>
        </div>
    </div>




</div>