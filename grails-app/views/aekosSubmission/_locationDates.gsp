<div id="datasetInfo" >

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 4 of 9 - Study Locations and Dates</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="sites"><g:message code="aekos.dataset.site"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.site"/>',
                              content:'<g:message code="aekos.dataset.site.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span></label>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div id="sites" class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">
                        <!-- ko foreach: aekosModalView().sites() -->

                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl()}, text: name"></a><br>

                        <!-- /ko -->
                    </div>
                 </div>
            </div>
        </div>
    </div>

    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="ibraRegion"><g:message code="aekos.dataset.site.ibra"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.site.ibra"/>',
                              content:'<g:message code="aekos.dataset.site.ibra.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <div class="span8">
                    <div class="controls">
                        <div class="panel panel-default" >
                            <div id="ibraRegion" class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">
                                <!-- ko foreach: aekosModalView().sites() -->
                                <span data-bind="text: ibra"></span><br>
                                <!-- /ko -->
                            </div>
                        </div>
                    </div>
                </div>


            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="startDate"><g:message code="aekos.activity.startDate"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.startDate"/>',
                              content:'<g:message code="aekos.activity.startDate.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="startDate" data-bind="value: aekosModalView().startDate"></span>
            </div>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="startDate"><g:message code="aekos.activity.endDate"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.endDate"/>',
                              content:'<g:message code="aekos.activity.endDate.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>

        <div class="span8">
            <div class="controls">
                <span id="endDate" data-bind="value: aekosModalView().endDate"></span>
            </div>
        </div>
    </div>




</div>