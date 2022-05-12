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
        <td class="date align-top">
            <div class="input-group">
            <fc:datePicker class="form-control" targetField="date.date" name="date" data-validation-engine="validate[required]" printable="${printView}"
            bs4="true" theme="btn-dark"/>
            </div>
        </td>
        <td class="type align-top">
            <select class="form-control" data-bind="options:type.options, value:type"></select>
        </td>
        <td class="outcome-progress align-top">
            <textarea class="form-control" data-bind="value:progress" rows="3"></textarea>
        </td>
        <td class="controls align-top">
            <span class="btn btn-sm btn-danger"><i class="far fa-trash-alt" data-bind="click: $parent.removeOutcomeProgress"></i></span>
        </td>
    </tr>
    <!-- /ko -->
    </tbody>
    <tfoot>
    <tr>

        <td>
            <button type="button" class="btn btn-dark btn-sm" data-bind="click: addOutcomeProgress">
                <i class="fas fa-plus"></i> Add a row</button>
        </td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
    </tfoot>
</table>

<div class="row space-after no-gutters">
    <div class="col-sm-12">
        <div class="form-actions">

            <button type="button" data-bind="click: saveMeriPlan" id="project-details-save" class="btn btn-primary-dark"><i class="fas fa-hdd"></i> Save changes</button>
            <button type="button" id="details-cancel" class="btn btn-dark" data-bind="click: cancelMeriPlanEdits"><i class="far fa-times-circle"></i> Cancel</button>
        </div>

    </div>
</div>