<g:set var="modalName" value="${modalId?:'chooseMore'}"></g:set>
<div class="row-fluid">
    <div class="span12">
        <!-- ko foreach: facets -->
            <!-- ko if: $data instanceof FacetViewModel -->
            <div class="row-fluid" data-bind="visible: showTermPanel">
                <button data-bind="click: toggleState" class="btn btn-block btn-text-left">
                    &nbsp;
                    <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}"></i>
                    <strong data-bind="text: displayName"></strong>
                    <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'right', content: helpText }">
                        <i class="icon-question-sign">&nbsp;</i>
                    </a>
                </button>
                <div data-bind="slideVisible: state() == 'Expanded'" class="margin-top-10">
                    <div class=" facet-display-height">
                        <!-- ko foreach: terms -->
                        <label class="control-label checkbox" data-bind="visible: !refined()">
                            <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                            <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}"></span>
                        </label>
                        <!-- /ko -->
                    </div>
                    <a href="#" role="button" class="moreFacets tooltips" data-toggle="modal" title="" data-target="#${modalName}"
                       data-original-title="View full list of values" data-bind="click: loadMoreTerms, visible: showChooseMore()">
                        <i class="fa fa-hand-o-right"></i> choose more...
                    </a>
                </div>
            </div>
            <!-- /ko -->
            <!-- ko if: $data instanceof DatePickerViewModel -->
            <div class="row-fluid">
                <button data-bind="click: toggleState" class="btn btn-block btn-text-left">
                    &nbsp;
                    <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}"></i>
                    <strong data-bind="text: displayName"></strong>
                    <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'right', content: helpText }">
                        <i class="icon-question-sign">&nbsp;</i>
                    </a>
                </button>
                <div data-name="projectDates" class="margin-top-10 form-horizontal facetDates validationEngineContainer" data-bind="slideVisible: state() == 'Expanded', independentlyValidated: true">
                    <div class="row-fluid">
                        <label class="input-label"><span class="span2">From:</span>
                            <div class="input-append">
                                <input data-bind="value: fromDate.formattedDate, datepicker: fromDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"
                                       id="fromDate" name="fromDate" type="text" size="16" class="input-small" placeholder="dd/mm/yyyy"
                                        targetfield="fromDate.date"
                                       data-validation-engine="validate[date]">
                                <span class="add-on open-datepicker">
                                    <i class="icon-calendar">&nbsp;</i>
                                </span>
                            </div>
                        </label>
                    </div>
                    <div class="">
                        <label class="input-label"><span class="span2">To:</span>
                            <div class="input-append">
                                <input data-bind="value: toDate.formattedDate, datepicker: toDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"
                                     id="toDate" type="text" size="16" class="input-append input-small"
                                       targetfield="toDate.date"
                                     placeholder="dd/mm/yyyy" data-validation-engine="validate[date,future[fromDate]]">
                                <span class="add-on open-datepicker">
                                    <i class="icon-calendar">&nbsp;</i>
                                </span>
                            </div>
                        </label>
                    </div>
                    <div><span class="span2"></span><button data-bind="click: clearDates, enable: showClearButton" class="btn btn-small"><i class="icon-remove"></i> Clear dates</button></div>
                </div>
            </div>
            <!-- /ko -->
            &nbsp;
        <!-- /ko -->
    </div>
</div>
<!-- Modal -->
%{--inline style is required as the first time so the modal does not block other components on screen--}%
%{--Looks like a bug in Bootstrap--}%
<div id="${modalName}" class="modal fade" role="dialog" style="">
    <div class="modal-dialog ">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <span class="modal-title" data-bind="text: displayTitle('<g:message code="facet.dialog.more.title" default="Filter by"/>')"></span>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="input-append control-label pull-right">
                        <input type="text" placeholder="Search" data-bind="value: searchText"><button class="btn"><i class="icon-filter"></i></button>
                    </div>
                </div>
                <!-- ko foreach: showMoreTermList -->
                <label class="control-label checkbox" data-bind="visible: !refined(), visible: showTerm">
                    <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">
                    <span class="label-ellipsis" data-bind="text:displayName, click: filterNow, attr:{title: displayName}" data-dismiss="modal"></span>
                </label>
                <!-- /ko -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-small" data-bind="click: includeSelection"
                        data-dismiss="modal">
                    <i class="icon-plus"></i>
                    <g:message code="facet.dialog.more.include" default="INCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-small" data-bind="click: excludeSelection"
                        data-dismiss="modal">
                    <i class="icon-minus"></i>
                    <g:message code="facet.dialog.more.exclude" default="EXCLUDE selected items"/>
                </button>
                <button type="button" class="btn btn-danger btn-small" data-dismiss="modal">
                        <i class="icon-remove icon-white"></i>
                        <g:message code="facet.dialog.more.close" default="Close"/>
                </button>
            </div>
        </div>

    </div>
</div>