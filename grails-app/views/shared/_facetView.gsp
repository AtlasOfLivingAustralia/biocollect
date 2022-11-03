<!-- ko foreach: facets -->
<!-- ko if: $data instanceof FacetViewModel && $data.state() !== 'Hidden'-->
%{--<!-- ko if: !adminOnly() -->--}%
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
%{--<!-- /ko -->--}%
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
