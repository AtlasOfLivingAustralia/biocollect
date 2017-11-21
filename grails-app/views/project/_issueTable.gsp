<label><b>Project Issues <span style="color: red;"><b>*</b></span></b></label>
<g:render template="/shared/restoredData"
          model="[id: 'restoredIssueData', saveButton: 'Save issues', cancelButton: 'Cancel edits to issues']"/>

<div class="row-fluid space-after">
    <div class="required">
        <p>Please enter project issues and the mitigation strategies being used to manage them:</p>

        <div class="project-issues margin-bottom-10 margin-right-20">
            <table style="width:100%;">
                <thead>
                <tr>
                    <th class="required type">Type of issue </th>
                    <th class="required">Date</th>
                    <th class="required status">Status </th>
                    <th class="required priority">Priority </th>
                    <th class="required description">Description</th>
                    <th class="required actionPlan">Action plan </th>
                    <th class="required impact">Impact</th>
                    <th></th>
                </tr>
                </thead>
                <tbody data-bind="foreach : issues">
                <tr>
                    <td class="type">
                        <input data-validation-engine="validate[required]" data-bind="value:type">
                    </td>
                    <td class="date">
                        <fc:datePicker class="input-small" targetField="date.date" name="date" data-validation-engine="validate[required]"/>
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
                        <span><i class="icon-remove" data-bind="click: $parent.removeIssue"></i></span>
                    </td>
                </tr>
                </tbody>
                <tfoot>
                <tr>
                    <td colspan="0" style="text-align:left;">
                        <button type="button" class="btn btn-small" data-bind="click: addIssue">
                            <i class="icon-plus"></i> Add an issue</button></td>
                </tr>
                </tfoot>

            </table>
            <br/>
        </div>
    </div>
</div>
