<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 3 of 9 - Dataset Content</h4>
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
                <input type="file" accept="text/csv" data-bind="" />
                    %{--<input type="file" accept="text/csv" name="projectData" />--}%
                <!--div id="nav-bar" data-bind="template: { name: 'tree-template', data: aekosModalView().pageModel.treeData }"></div-->
                %{--<g:render template="/aekosSubmission/treeviewTemplate" />--}%
                <!--input id="datasetTitle" data-bind="value: aekosModalView().datasetTitle" -->
            </div>
        </div>
    </div>



</div>