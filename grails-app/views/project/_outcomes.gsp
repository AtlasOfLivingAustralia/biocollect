<h3>Progress against outcomes</h3>
<table class="outcomes-progress table table-striped">
    <thead>
    <tr>
        <td class="date">Date</td>
        <td class="type">Interim / Final</td>
        <td class="outcome-progress">Progress</td>
        <td class="controls"></td>
    </tr>
    </thead>
    <tbody>
    <!-- ko foreach:details.outcomeProgress -->
    <tr>
        <td class="date">
            <fc:datePicker class="input-small" targetField="date.date" name="date" data-validation-engine="validate[required]" printable="${printView}"/>
        </td>
        <td class="type">
            <select data-bind="options:type.options, value:type"></select>
        </td>
        <td class="outcome-progress">
            <textarea data-bind="value:progress" rows="3"></textarea>
        </td>
        <td class="controls">
            <span><i class="icon-remove" data-bind="click: $parent.removeOutcomeProgress"></i></span>
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <tfoot>
    <tr>

        <td>
            <button type="button" class="btn btn-small" data-bind="click: addOutcomeProgress">
                <i class="icon-plus"></i> Add a row</button>
        </td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
    </tfoot>
</table>

<div class="row-fluid space-after">
    <div class="span12">
        <div class="form-actions">

            <button type="button" data-bind="click: saveMeriPlan" id="project-details-save" class="btn btn-primary">Save changes</button>
            <button type="button" id="details-cancel" class="btn" data-bind="click: cancelMeriPlanEdits">Cancel</button>
        </div>

    </div>
</div>