<div id="projectInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 1 of 9 - Describe the project</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="submissionName"><g:message code="aekos.submission.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.submission.info.name"/>',
                              content:'<g:message code="aekos.submission.info.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="submissionName" data-bind="text: aekosModalView().submissionName"></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="submissionName"><g:message code="aekos.project.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.info.name"/>',
                              content:'<g:message code="aekos.project.info.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="projectName" data-bind="text: aekosModalView().projectName"></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="projectDescription"><g:message code="aekos.project.info.description"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.info.description"/>',
                              content:'<g:message code="aekos.project.info.description.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
        </div>

        <div class="span8">
            <div class="controls">
                <textarea id="projectDescription" data-bind="value: aekosModalView().projectDescription" rows="6" style="width:90%;" ></textarea>
            </div>
        </div>
    </div>

    <!--div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="projectStatus"><g:message code="aekos.project.info.status"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.info.status"/>',
                              content:'<g:message code="aekos.project.info.status.content"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="projectStatus" data-bind="text: aekosModalView().projectStatus"></span>
            </div>
        </div>
    </div-->

</div>