<label><b>Project Issues <span style="color: red;"><b>*</b></span></b></label>
<g:render template="/shared/restoredData"
          model="[id: 'restoredIssueData', saveButton: 'Save issues', cancelButton: 'Cancel edits to issues']"/>

<div class="row space-after">
    <div class="col-sm-12 required">
        <p>Please enter project issues and the mitigation strategies being used to manage them:</p>

        <div class="project-issues">
            <table class="table table-bordered">
                <thead class="thead-dark">
                <tr>
                    <th class="required type">Type of issue </th>
                    <th class="required">Date </th>
                    <th class="required status">Status </th>
                    <th class="required priority">Priority </th>
                    <th class="required description">Description </th>
                    <th class="required actionPlan">Action plan </th>
                    <th class="required impact">Impact </th>
                    <th></th>
                </tr>
                </thead>
                <tbody data-bind="foreach : issues">
                <tr>
                    <td class="type">
                        <input data-validation-engine="validate[required]" data-bind="value:type">
                    </td>
                    <td class="date input-group-append mt-5" style="border: none !important;">
                        <fc:datePicker targetField="date.date" name="date" data-validation-engine="validate[required]"/>
                    </td>

                    <td class="status">
                        <select data-validation-engine="validate[required]" data-bind="value:status, options: status.options"></select>
                    </td>
                    <td class="priority">
                        <select data-validation-engine="validate[required]" data-bind="value:priority, options: priority.options, optionsCaption:'Please select'"></select>
                    </td>
                    <td class="description">
                        <textarea data-validation-engine="validate[required]" class="input-xlarge"
                                  data-bind="value: description" rows="5"></textarea>
                    </td>
                    <td class="actionPlan">
                        <textarea data-validation-engine="validate[required]" class="input-xlarge"
                                  data-bind="value: actionPlan" rows="5"></textarea>
                    </td>
                    <td class="impact">
                        <select data-validation-engine="validate[required]"
                                data-bind="options: impact.options, value: impact,  optionsCaption: 'Please select'"></select>
                    </td>

                    <td width="4%">
                        <span><i class="fas fa-times" data-bind="click: $parent.removeIssue"></i></span>
                    </td>
                </tr>
                </tbody>
                <tfoot>
                <tr>
                    <td colspan="0" style="text-align:left;">
                        <button type="button" class="btn btn-dark btn-sm" data-bind="click: addIssue">
                            <i class="fas fa-plus"></i> Add an issue</button></td>
                </tr>
                </tfoot>

            </table>
            <br/>
        </div>
    </div>
</div>
