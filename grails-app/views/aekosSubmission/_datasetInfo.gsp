<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h2 class="strong">Step 2 of 9 - Dataset Description</h2>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="submissionName"><g:message code="aekos.dataset.info.name"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.info.name"/>',
                              content:'<g:message code="aekos.dataset.info.name.content"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="submissionName" data-bind="text: aekosModalView().name"></span>
            </div>
        </div>
    </div>


</div>