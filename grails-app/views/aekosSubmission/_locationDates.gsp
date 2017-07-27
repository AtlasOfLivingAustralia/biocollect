<div id="spatialInfoCollectionDates">

    <div class="row-fluid">
        <div class="span12">
            <h4 class="strong">Step 4 of 9 - Study Locations and Dates</h4>
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="geographicalExtentDescription"><g:message code="aekos.dataset.site"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.site"/>',
                              content:'<g:message code="aekos.dataset.site.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8">
           %{-- <span data-bind="visible: transients.loadingMap()">
                <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
            </span>
            <span data-bind="visible: transients.totalPoints() == 0 && !transients.loadingMap()">
                <span class="text-left margin-bottom-five">
                    <span data-bind="if: transients.loading()">
                        <span class="fa fa-spin fa-spinner"></span>&nbsp;Loading...
                    </span>
                    <span data-bind="if: !transients.loading()">No Results</span>
                </span>
            </span>--}%
            %{--<span id="recordOrActivityMap" data-bind="visible: transients.totalPoints() > 0 && !transients.loadingMap() ">--}%
            <textarea id="geographicalExtentDescription" data-bind="value: currentSubmissionPackage.geographicalExtentDescription"  data-validation-engine="validate[required]" rows="3" style="width: 90%"></textarea>
            <br>
            <div id="recordOrActivityMap">
                <m:map id="aekosDatasetMap" width="100%"/>
            </div>
        </div>


        %{--<div class="span8">
            <div class="controls">
                <div class="panel panel-default" >
                    <div id="sites" class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">
                        <!-- ko foreach: sites() -->

                        <a class="btn-link" target="_blank" data-bind="attr:{href: siteUrl()}, text: name"></a><br>

                        <!-- /ko -->
                    </div>
                 </div>
            </div>
        </div>--}%
    </div>

    <br/>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" ><g:message code="aekos.dataset.site.ibra"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.site.ibra"/>',
                              content:'<g:message code="aekos.dataset.site.ibra.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>


       <div class="span8">
            <span id="selectedIbraRegion" data-bind="text: selectedIbraRegion" />
%{--                    <div class="controls">
                        <div class="panel panel-default" >
                            <div id="ibraRegion" class="panel-body" style="max-height: 355px; max-width: 500px; overflow-y: scroll; overflow-x: scroll; background:#ffffff;">
                                <!-- ko foreach: transients.ibraRegions -->
                                <input type="checkbox" data-bind="attr:{'id': name, 'name': name}, checkedValue: name, checked: $parent.selectedIbraRegion" /><br>
                                <span data-bind="text: name"></span>
                                <!-- /ko -->
                            </div>
                        </div>
                    </div>--}%
%{--
                </div>
            </div>
--}%
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" ><g:message code="aekos.dataset.site.coordinate"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.dataset.site.coordinate"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
            </label>
        </div>


        <div class="span8">
            <span id="siteCoordinates" data-bind="text: siteCoordinates" />
         </div>
    </div>

    <br>
 %{--   </div>

<div id="collectionDates">
--}%
    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="collectionStartDate"><g:message code="aekos.activity.startDate"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.startDate"/>',
                              content:'<g:message code="aekos.activity.startDate.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8 input-append">
            <input id="collectionStartDate" class="datepicker" data-bind="datepicker: currentSubmissionPackage.collectionStartDate.date, value: currentSubmissionPackage.collectionStartDate" type="text"/>
            <span class="add-on open-datepicker"><i class="icon-calendar"></i></span>
            %{--<span id="collectionStartDate" data-bind="value: startDate"></span>--}%
        </div>
    </div>

    <div class="row-fluid">
        <div class="span4 text-right">
            <label class="control-label" for="collectionEndDate"><g:message code="aekos.activity.endDate"/>
                <a href="#" class="helphover"
                   data-bind="popover: {title:'<g:message code="aekos.activity.endDate"/>',
                              content:'<g:message code="aekos.activity.endDate.help"/>'}">
                    <i class="icon-question-sign"></i>
                </a>
                <span class="req-field"></span>
            </label>
        </div>

        <div class="span8 input-append">
            <input id="collectionEndDate" class="datepicker" data-bind="datepicker: currentSubmissionPackage.collectionEndDate.date, value: currentSubmissionPackage.collectionEndDate" type="text"/>
            <span class="add-on open-datepicker"><i class="icon-calendar"></i> </span>
           %{-- <span id="collectionEndDate" data-bind="value: endDate"></span>--}%
        </div>
    </div>




</div>