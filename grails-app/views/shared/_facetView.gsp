%{--<div class="row-fluid">--}%
%{--    <div class="span12">--}%
%{--        <!-- ko foreach: facets -->--}%
%{--        <!-- ko if: $data instanceof FacetViewModel && $data.state() !== 'Hidden' -->--}%
%{--        <div class="row-fluid" data-bind="visible: showTermPanel">--}%
%{--            <button data-bind="click: toggleState" class="btn btn-block btn-text-left">--}%
%{--                &nbsp;--}%
%{--                <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}"></i>--}%
%{--                <strong data-bind="text: displayName"></strong>--}%
%{--                <a href="#" tabindex="-1"--}%
%{--                   data-bind="visible: helpText, popover: {placement:'right', content: helpText }">--}%
%{--                    <i class="icon-question-sign">&nbsp;</i>--}%
%{--                </a>--}%
%{--            </button>--}%

%{--            <div data-bind="slideVisible: state() == 'Expanded'" class="margin-top-10">--}%
%{--                <div class=" facet-display-height">--}%
%{--                    <!-- ko foreach: terms -->--}%
%{--                    <label class="control-label checkbox" data-bind="visible: !refined()">--}%
%{--                        <input type="checkbox" data-bind="checked: checked" style="display: inline-block;">--}%
%{--                        <span class="label-ellipsis"--}%
%{--                              data-bind="text:displayName, click: filterNow, attr:{title: displayName}"></span>--}%
%{--                    </label>--}%
%{--                    <!-- /ko -->--}%
%{--                </div>--}%
%{--                <a href="#" role="button" class="moreFacets tooltips" data-toggle="modal" title=""--}%
%{--                   data-target="#${modalName}"--}%
%{--                   data-original-title="View full list of values"--}%
%{--                   data-bind="click: loadMoreTerms, visible: showChooseMore()">--}%
%{--                    <i class="fa fa-hand-o-right"></i> choose more...--}%
%{--                </a>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--        <!-- /ko -->--}%
%{--        <!-- ko if: $data instanceof DatePickerViewModel && $data.state() !== 'Hidden' -->--}%
%{--        <div class="row-fluid">--}%
%{--            <button data-bind="click: toggleState" class="btn btn-block btn-text-left">--}%
%{--                &nbsp;--}%
%{--                <i data-bind="css: {'icon-plus': state() == 'Collapsed', 'icon-minus': state() == 'Expanded'}"></i>--}%
%{--                <strong data-bind="text: displayName"></strong>--}%
%{--                <a href="#" tabindex="-1"--}%
%{--                   data-bind="visible: helpText, popover: {placement:'right', content: helpText }">--}%
%{--                    <i class="icon-question-sign">&nbsp;</i>--}%
%{--                </a>--}%
%{--            </button>--}%

%{--            <div data-name="projectDates" class="margin-top-10 form-horizontal facetDates validationEngineContainer"--}%
%{--                 data-bind="slideVisible: state() == 'Expanded', independentlyValidated: true">--}%
%{--                <div class="row-fluid">--}%
%{--                    <label class="input-label"><span class="span2">From:</span>--}%

%{--                        <div class="input-append">--}%
%{--                            <input data-bind="value: fromDate.formattedDate, datepicker: fromDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"--}%
%{--                                   id="fromDate" name="fromDate" type="text" size="16" class="input-small"--}%
%{--                                   placeholder="dd/mm/yyyy"--}%
%{--                                   targetfield="fromDate.date"--}%
%{--                                   data-validation-engine="validate[date]">--}%
%{--                            <span class="add-on open-datepicker">--}%
%{--                                <i class="icon-calendar">&nbsp;</i>--}%
%{--                            </span>--}%
%{--                        </div>--}%
%{--                    </label>--}%
%{--                </div>--}%

%{--                <div class="">--}%
%{--                    <label class="input-label"><span class="span2">To:</span>--}%

%{--                        <div class="input-append">--}%
%{--                            <input data-bind="value: toDate.formattedDate, datepicker: toDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"--}%
%{--                                   id="toDate" type="text" size="16" class="input-append input-small"--}%
%{--                                   targetfield="toDate.date"--}%
%{--                                   placeholder="dd/mm/yyyy" data-validation-engine="validate[date,future[fromDate]]">--}%
%{--                            <span class="add-on open-datepicker">--}%
%{--                                <i class="icon-calendar">&nbsp;</i>--}%
%{--                            </span>--}%
%{--                        </div>--}%
%{--                    </label>--}%
%{--                </div>--}%

%{--                <div><span class="span2"></span><button data-bind="click: clearDates, enable: showClearButton"--}%
%{--                                                        class="btn btn-small"><i class="icon-remove"></i> Clear dates--}%
%{--                </button></div>--}%
%{--            </div>--}%
%{--        </div>--}%
%{--        <!-- /ko -->--}%
%{--        &nbsp;--}%
%{--        <!-- /ko -->--}%
%{--    </div>--}%
%{--</div>--}%

<!-- ko foreach: facets -->
<!-- ko if: $data instanceof FacetViewModel && $data.state() !== 'Hidden'-->
<button class="accordion-header" type="button" data-toggle="collapse"
        data-bind="attr: { 'data-target': '#' + name()}, css: {collapsed: state() === 'Collapsed'}, visible: showTermPanel"
        aria-expanded="true" aria-controls="types">
    <!-- ko text: displayName --><!-- /ko -->
    <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'top', content: helpText }">
        <i class="fas fa-info-circle"></i>
    </a>
</button>

<div class="collapse accordion-body" data-bind="attr: { id: name}, css: {show: state() == 'Expanded'}, visible: showTermPanel">
    <!-- ko foreach: terms -->
    <label class="form-check-label d-block form-check text-truncate"
           data-bind="attr: {title:displayName, for: term}">
        <input class="form-check-input" type="checkbox" data-bind="checked: checked, attr: {id: term}">
        <span data-bind="click: filterNow, text: displayName"></span>
    </label>
    <!-- /ko -->
    <a href="#" role="button" class="moreFacets tooltips" data-toggle="modal" title="" data-target="#${modalName}"
       data-original-title="View full list of values" data-bind="click: loadMoreTerms, visible: showChooseMore()">
        <i class="far fa-hand-point-right"></i> choose more...
    </a>
</div>
<!-- /ko -->

<!-- ko if: $data instanceof DatePickerViewModel -->
<button class="accordion-header" type="button" data-toggle="collapse"
        data-bind="attr: { 'data-target': '#' + name()}, css: {collapsed: state() === 'Collapsed'}"
        aria-expanded="true" aria-controls="types">
    <!-- ko text: displayName --><!-- /ko -->
    <a href="#" tabindex="-1" data-bind="visible: helpText, popover: {placement:'top', content: helpText }">
        <i class="fas fa-info-circle"></i>
    </a>
</button>
<div class="collapse accordion-body form-horizontal validationEngineContainer" data-name="projectDates"
     data-bind="css: {show: state() == 'Expanded'}, independentlyValidated: true, attr: {id: name()}">
    <div class="row form-group">
        <label class="input-label col-md-3 col-form-label" for="fromDate">From:</label>

        <div class="col-md-9 input-group input-group-sm">
            <input class="form-control"
                   data-bind="value: fromDate.formattedDate, datepicker: fromDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"
                   id="fromDate" name="fromDate" type="text" placeholder="dd/mm/yyyy" targetfield="fromDate.date"
                   data-validation-engine="validate[date]">

            <div class="input-group-append open-datepicker">
                <button class="btn btn-outline-dark" type="button">
                    <i class="far fa-calendar-alt"></i>
                </button>
            </div>
        </div>
    </div>

    <div class="row form-group">
        <label class="input-label col-md-3 col-form-label" for="toDate">To:</label>

        <div class="col-md-9 input-group input-group-sm">
                <input class="form-control"
                       data-bind="value: toDate.formattedDate, datepicker: toDate.date, datePickerOptions: { format: 'dd/mm/yyyy'}, event: {blur: setContext($element)}"
                       id="toDate" type="text" targetfield="toDate.date" placeholder="dd/mm/yyyy"
                       data-validation-engine="validate[date,future[fromDate]]">

                <div class="input-group-append open-datepicker">
                    <button class="btn btn-outline-dark" type="button">
                        <i class="far fa-calendar-alt"></i>
                    </button>
                </div>
        </div>
    </div>

    <div class="row form-group">
        <div class="offset-md-3 col-md-9">
            <button class="btn btn-sm btn-danger" data-bind="click: clearDates, enable: showClearButton">
                <i class="far fa-trash-alt"></i> Clear dates</button>
        </div>
    </div>
</div>
<!-- /ko -->
<!-- /ko -->
