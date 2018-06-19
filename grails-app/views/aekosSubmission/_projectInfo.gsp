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
            %{--<div class="controls">--}%
                <span id="submissionName" data-bind="text: submissionName"></span>
            %{--</div>--}%
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="projectName"><g:message code="aekos.project.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.info.name"/>',
                              content:'<g:message code="aekos.project.info.name.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            %{--<div class="controls">--}%
                <span id="projectName" data-bind="text: projectViewModel.name"></span>
            %{--</div>--}%
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" %{--for="projectDescription"--}%><g:message code="aekos.project.info.description"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.project.info.description"/>',
                              content:'<g:message code="aekos.project.info.description.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                %{--<span class="req-field"></span>--}%</label>
        </div>

        <div class="span8">
           %{-- <div class="controls">--}%
                <span id="projectDescription" data-bind="text: projectViewModel.description"></span>
%{--                <textarea id="projectDescription" data-bind="value: projectViewModel.description"
                          data-validation-engine="validate[required]" rows="20" style="width:90%;" class="input-xlarge"></textarea>--}%
           %{-- </div>--}%
        </div>
    </div>


</div>
%{--

<asset:script type="text/javascript">
    $(window).load(function () {
        AekosViewModel.isProjectInfoValidated = function () {
            return self.projectName;
        }
    });
</asset:script>--}%
